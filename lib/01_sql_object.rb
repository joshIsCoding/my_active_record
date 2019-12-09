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
    DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
    SQL
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
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
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
