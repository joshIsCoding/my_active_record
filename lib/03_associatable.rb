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
    # ...
  end

  def table_name
    # ...
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
    # ...
  end

  def has_many(name, options = {})
    # ...
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
end
