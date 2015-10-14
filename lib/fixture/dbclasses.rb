module DBClasses
  def create_class_for_table(table_name)
    Object.const_set table_name.capitalize, Class.new
  end

  def delete_class(class_name)
    Object.send :remove_const, class_name.to_sym
  end
end