require 'dbconnect'

module FakeRecord
  class Base
    def self.connection
      DBconnect.instance()
    end

    def initialize
      @attr = self.class.column_names
      @attr.each do |att|
        self.class.class_eval("attr_accessor :#{att}")
      end
      @id = set_start_id
    end

    def save
      unless self.class.find(self.id).nil?
        Base.connection.query(update_sql_query)
      else
        Base.connection.query(create_sql_query)
        self.id = self.class.last.id.to_i
      end
    end

    def update_attributes(hash)
      hash.each do |k,v|
        self.instance_eval "self.#{k}=#{v} if @attr.include? #{k}"
      end
      Base.connection.query(update_sql_query)
    end

    def destroy
      Base.connection.query("DELETE FROM #{self.class.name}s WHERE ID = #{self.id};")
    end

    #def get_or_set_method?()
    # /^([a-zA-Z][-_\w]*)[[^?]=]*$/
    #end

    #def method_missing(method,*args)
      #if method.to_s =~ get_or_set_method? && @attr.include?($1)
      #  self.class.create_get_and_set_method($1)
      #  self.send method, args[0]
      #else
      #super
      #end    
    #end

    def self.method_missing(method,*args)
      super unless method.to_s =~ find_by_method? && !(column_names - (list = $1.split('_and_'))).empty?
      args.map! {|arg| "'#{arg}'"}
      sql_query = list.map.with_index {|name, index| "#{name} = #{args[index]}"} .join(' AND ')
      val = parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s WHERE " + sql_query ))
      return val[0] if val.length == 1
      val
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
      parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s ORDER BY ID DESC LIMIT 1"))[0]
    end

    def self.first
      parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s LIMIT 1"))[0]
    end

    def self.find(id)
      if id.is_a?(Integer)
        parse_db_result(Base.connection.query("SELECT #{column_names.join(',')} FROM #{self.name}s WHERE ID = #{id}"))[0]
      else
        puts "Only integer id's are supported"
        return false
      end
    end

    # def self.create_get_and_set_method(attr_name)
    #   class_eval("def #{attr_name}=(new_value); @#{attr_name}=new_value;end;def #{attr_name}; @#{attr_name} ;end;", __FILE__, __LINE__)
    # end

    private 
      def self.column_names
        DBconnect.instance().query("
          select column_name
          from information_schema.columns 
          where table_name = '#{self.name.downcase}s'
          ").values.flatten
      end

      def self.parse_db_result(pg_result_object)
        result = []
        pg_result_object.values.each do |value|
          rec = self.new

          (0..(column_names.length-1)).each do |index|
            rec.instance_eval "self.#{column_names[index]}=value[index]"
          end
          rec
          result << rec
        end
        result
      end

      def self.find_by_method?()
        /^find_by_([_a-zA-Z]*)[^=?]*$/
      end

      def self.look_by_hash(hash)
        sql_query = hash.keys.inject([]){|arr,item| arr << "#{item} = ?"}.join(' AND ')
        parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s WHERE " + sql_query,hash.values))
      end

      def self.look_by_sql_string(sql_string,*args)
        args = args[0] if args.length == 1
        parse_db_result(Base.connection.query("SELECT * FROM #{self.name}s WHERE "+sql_string ,args ))
      end

      def create_sql_query
        "INSERT INTO #{self.class.name}s (#{keys.join(',')}) VALUES (#{values.join(',')}) "
      end

      def update_sql_query
        "UPDATE #{self.class.name}s SET " + key_value_sql + "WHERE ID = #{self.id}"
      end

      def hash_params
        Hash[keys.zip(values)]
      end

      def key_value_sql
        result = ""
        (0..(keys.length - 1)).each do |index|
          result << ", " if index != 0
          result << "#{keys[index]} = #{values[index]}"
        end
        result
      end

      def keys
        (self.class.column_names - ["id"])
      end

      def values
        (self.class.column_names - ["id"]).map {|column| convert((self.send(column.to_sym) if self.respond_to? column.to_sym)) }
      end

      def convert(convertible)
        if convertible.is_a? String or convertible.is_a? NilClass
          "'" + convertible.to_s + "'"
        else
          convertible
        end
      end

      def set_start_id
        Base.connection.query("SELECT MAX(id) FROM #{self.class.name}s").values.flatten[0].to_i + 1
      end
  end
end