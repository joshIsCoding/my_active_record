require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    @columns ||= DBConnection.execute2(<<-SQL).first.map(&:to_sym)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
  end

  def self.finalize!
    self.columns.each do |attribute|
      define_method(attribute) { attributes[attribute] } # attribute getter methods
      define_method(attribute.to_s + "=") { |value| attributes[attribute] = value } # attribute setter methods
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.name.to_s.tableize
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    results.map do |record_hash|
      self.new(record_hash)
    end
  end

  def self.find(id)
    object_params = DBConnection.execute(<<-SQL).first
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = #{id}
    LIMIT
      1
    SQL
    return self.new(object_params) if object_params
    nil
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_sym = attr_name.to_sym # ensure attr_name is passed as a symbol
      raise "unknown attribute '#{attr_sym}'" unless self.class.columns.include?(attr_sym)
      self.send(("#{attr_sym}=").to_sym, value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map do |attr|
      self.send(attr)
    end
  end

  def insert
    column_names = self.class.columns # array of target fields to be joined later
    interpolation_markers = (["?"] * column_names.length).join(", ") # number of "?"s determined by number of target fields for insertion
    # splat ensures attribute values passed as individual arguments
    DBConnection.execute(<<-SQL, *attribute_values) 
    INSERT INTO
      #{self.class.table_name} (#{column_names.join(", ")})
    VALUES
      (#{interpolation_markers})
    SQL

    self.id = DBConnection.last_insert_row_id # id generated upon insertion and must be stored within the instance
  end

  def update
    set_columns = self.class.columns.map{ |col| "#{col} = ?"} # generate column names in SQL-interpolation-ready format
    DBConnection.execute(<<-SQL, *attribute_values, self.id)
    UPDATE
      #{self.class.table_name}
    SET
      #{set_columns.join(", ")}
    WHERE
      id = ?
    SQL
  end

  def save # user-accessible method to update/insert a record as determined by the program
    self.id.nil? ? self.insert : self.update
  end
end
