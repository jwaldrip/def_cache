require 'set'

class Class

  protected

  def inherited_attribute_defined?(attr)
    __inherited_attributes_with_hierarchy__.include? attr
  end

  private

  def __inherited_attributes_with_hierarchy__
    __inherited_attributes__ + superclass.send(__method__)
  rescue NoMethodError
    __inherited_attributes__
  end

  def __inherited_attributes__
    @__inherited_attributes__ ||= Set.new
  end

  def inherited_attribute(*attrs)
    attrs.each do |attr|
      __inherited_attributes__ << attr
    end
  end

  def define_inherited_attribute_class_setter(attr)
    define_singleton_method("#{attr}=") do |val|
      instance_variable_set("@#{attr}", val)
    end
  end

  def define_inherited_attribute_class_getter(attr)
    define_singleton_method(attr) do
      if instance_variable_defined?("@#{attr}")
        instance_variable_get("@#{attr}")
      elsif superclass.inherited_attribute_defined?(attr)
        superclass.send(attr)
      else
        nil
      end
    end
  end

  def define_inherited_attribute_instance_getter(attr)
    define_method(attr) do
      self.class.send(attr)
    end
  end

end