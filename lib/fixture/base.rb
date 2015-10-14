require 'dbconnect'

module FakeRecord
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

      sql_query =  "INSERT INTO #{self.class.name.downcase}s (#{keys}) VALUES (#{values.join(',')}) "
      Base.connection.query(sql_query)
    end

    def get_or_set_method?()
     /^([a-zA-Z][-_\w]*)[[^?]=]*$/
    end

    def method_missing(method,*args)
      if method.to_s =~ get_or_set_method? && @attr.include?($1)
        self.class.create_get_and_set_method($1)
        self.send method, args[0]
      else
        super
      end    
    end

    def self.method_missing(method,*args)
      super unless method.to_s =~ find_by_method? && !(column_names - (list = $1.split('_and_'))).empty?
      args.map! {|arg| "'#{arg}'"}
      sql_query = list.map.with_index {|name, index| "#{name} = #{args[index]}"} .join(' AND ')
      parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s WHERE " + sql_query ))
    end

    def self.respond_to_missing?(method, include_private = false)
      (method.to_s =~ find_by_method? && !(column_names - (list = $1.tr('_','').split('and'))).empty?) || super
    end

    def self.where(hash_or_sql_string,*args)
      if hash_or_sql_string.is_a? Hash
        look_by_hash(hash_or_sql_string)
      elsif hash_or_sql_string.is_a? String
        look_by_sql_string(hash_or_sql_string, args)
      else
        raise 'bad arguments'
      end
    end

    def self.last
      parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s ORDER BY ID DESC LIMIT 1"))
    end

    def self.first
      parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s LIMIT 1"))
    end

    def self.find(id)
      if id.is_a?(Integer)
        parse_db_result(Base.connection.query("SELECT #{column_names.join(',')} FROM #{self.name}s WHERE ID = #{id}"))
      else
        puts "Only integer id's are supported"
        return false
      end
    end

    def self.column_names
      DBconnect.instance().query("
        select column_name
        from information_schema.columns 
        where table_name = '#{self.name.downcase}s'
        ").values.flatten
    end

    def self.create_get_and_set_method(attr_name)
      class_eval("def #{attr_name}=(new_value); @#{attr_name}=new_value;end;def #{attr_name}; @#{attr_name} ;end;", __FILE__, __LINE__)
    end

    def self.parse_db_result(pg_result_object)
      values = pg_result_object.values.flatten
      return if values.empty?
      rec = self.new
      (0..(column_names.length-1)).each do |index|
        rec.instance_eval "self.#{column_names[index]}=values[index]"
      end
      rec
    end

    def self.find_by_method?()
      /^find_by_([_a-zA-Z]*)[^=?]*$/
    end

    private 

      def self.look_by_hash(hash)
        keys = hash.keys
        values = hash.values
        sql_query = keys.inject([]){|arr,item| arr << "#{item} = ?"}.join('')
        
        parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s WHERE " + sql_query,values))
      end

      def self.look_by_sql_string(sql_string,*args)
        args = args[0] if args.length == 1
        parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s WHERE "+sql_string ,args ))
      end
  end
end