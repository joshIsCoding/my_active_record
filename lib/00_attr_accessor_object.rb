class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      define_method(name) { self.instance_variable_get("@#{name.to_s}") } 
      # @-prefix required by method for 'regular instance variables'
    end
  end
end
