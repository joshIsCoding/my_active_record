require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize # creates the declared constant class name from the class_name string
  end

  def table_name
    model_class.table_name # calls the class method ::table_name for the target class
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key, @primary_key, @class_name = options[:foreign_key], options[:primary_key], options[:class_name]
    
    @foreign_key ||= "#{name}_id".to_sym
    @primary_key ||= :id
    @class_name ||= name.to_s.camelcase  
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key, @primary_key, @class_name = options[:foreign_key], options[:primary_key], options[:class_name]
    
    # association name passed as plural by definition of having many ______
    @foreign_key ||= "#{self_class_name.underscore.downcase}_id".to_sym
    @primary_key ||= :id
    @class_name ||= name.to_s.camelcase.singularize
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    belongs_to_options = BelongsToOptions.new(name, options)
    define_method(name) do
      foreign_key = self.send(belongs_to_options.foreign_key)
      sql_rec = DBConnection.execute(<<-SQL, foreign_key).first
        SELECT
          *
        FROM
          #{belongs_to_options.table_name}
        WHERE
          id = ?
        LIMIT
          1
      SQL
      return sql_rec.nil? ? nil : belongs_to_options.model_class.new(sql_rec)
    end
      
  end

  def has_many(name, options = {})
    has_many_options = HasManyOptions.new(name, self.name, options)
    define_method(name) do
      primary_key = self.send(has_many_options.primary_key)
      records = DBConnection.execute(<<-SQL, primary_key)
        SELECT
          *
        FROM
          #{has_many_options.table_name}
        WHERE
          #{has_many_options.foreign_key} = ?
      SQL
      has_many_options.model_class.parse_all(records)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
