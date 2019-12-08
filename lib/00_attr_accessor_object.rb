class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) { self.instance_variable_get("@#{name.to_s}") } 
      # @-prefix required by method for 'regular instance variables'
      setter_name = name.to_s + "=" # setters are called as 'instance_var='
      define_method(setter_name) { |new_val| self.instance_variable_set("@#{name.to_s}", new_val) }
      # parameters of new method defined as parameters of attached block
    end
  end
end
