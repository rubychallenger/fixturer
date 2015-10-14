require 'dbconnect'

module DBClasses
  def table_names
    DBconnect.instance().query("
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema='public'
      AND table_type='BASE TABLE';
      ").map {|e| e.values}
  end

  def create_class_for_table(table_name)
    name = table_name.capitalize
    name[table_name.length-1]=""
    Object.const_set( name, Class.new(Base))
  end

  def delete_class(class_name)
    Object.send :remove_const, class_name.to_sym
  end
end