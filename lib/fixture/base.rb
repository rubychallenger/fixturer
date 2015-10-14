require 'dbconnect'

class Base

  def self.connection
    DBconnect.instance()
  end

  def initialize
   @attr = self.class.column_names
  end

  def save
    keys = (self.class.column_names - ["id"]).join(',')

    values = (self.class.column_names - ["id"]).map {|column| "'" + (self.send(column.to_sym) if self.respond_to? column.to_sym).to_s + "'" }

    puts sql_querys =  "INSERT INTO #{self.class.name.downcase} (#{keys}) VALUES (#{values.join(',')}) "
    begin
      Base.connection.query(sql_querys)
      true
    rescue PG::SyntaxError
      puts "SQL SYNTAX ERROR"
      false 
    end
  end

  def get_or_set_method?()
   /^([a-zA-Z][-_\w]*)[[^?]=]*$/
  end

  def method_missing(method,*args)
    if method.to_s =~ get_or_set_method? && @attr.include?($1)
      #puts $1
      #puts method.to_s
      self.class.create_get_and_set_method($1)
      self.send method, args[0]
    else
      super
    end    
  end

  def self.method_missing(method,*args)
    super unless method.to_s =~ find_by_method? && !(column_names - (list = $1.tr('_','').split('and'))).empty?
    args.map! {|arg| "'#{arg}'"}
    sql_query = list.map.with_index {|name, index| "#{name} = #{args[index]}"} .join(' AND ')
    self.parse_db_result(Base.connection.query("SELECT * FROM #{self.name} WHERE " + sql_query ))
  end

  def self.respond_to_missing?(method, include_private = false)
    (method.to_s =~ find_by_method? && !(column_names - (list = $1.tr('_','').split('and'))).empty?) || super
  end

  def self.where(hash_or_sql_string,*args)
    if hash_or_sql_string.is_a? Hash
      keys = hash_or_sql_string.keys
      values = hash_or_sql_string.values
      sql_query = keys.inject([]){|arr,item| arr << "#{item} = ?"}.join('')
      
      self.parse_db_result(Base.connection.query("SELECT * FROM #{self.name} WHERE " + sql_query,values))
    elsif hash_or_sql_string.is_a? String
      self.parse_db_result(Base.connection.query("SELECT * FROM #{self.name} WHERE "+hash_or_sql_string ,args ))
    else
      raise 'bad arguments'
    end
  end

  def self.find(id)
    if id.is_a?(Integer)
      self.parse_db_result(Base.connection.query("SELECT #{column_names.join(',')} FROM #{self.name} WHERE ID = #{id}"))
    else
      puts "Only integer id's are supported"
      return false
    end
  end

  def self.column_names
    DBconnect.instance().query("
      select column_name
      from information_schema.columns 
      where table_name = '#{self.name.downcase}'
      ").values.flatten
  end

  def self.create_get_and_set_method(attr_name)
    class_eval("def #{attr_name}=(new_value); @#{attr_name}=new_value;end;def #{attr_name}; @#{attr_name} ;end;", __FILE__, __LINE__)
  end

  def self.parse_db_result(pg_result_object)
    values = pg_result_object.values.flatten
    rec = self.new
    (0..(column_names.length-1)).each do |index|
      rec.instance_eval "self.#{column_names[index]}=values[index]"
    end
    rec
  end

  def self.find_by_method?()
    /^find_by([_a-zA-Z]*)[^=?]*$/
  end
end