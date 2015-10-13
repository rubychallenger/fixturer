require 'base'

module DBClasses
  Base.table_names.each do |table|
    Object.const_set( (table[0].capitalize), Class.new do
      def initialize
        @attr = self.class.column_names
      end

      def self.column_names
        DBconnect.instance().con.query("
          select column_name
          from information_schema.columns 
          where table_name = '#{self.name.downcase}'
          ").values.flatten - ["id"]
      end

      def get_or_set_method?()
       /^([a-zA-Z][-_\w]*)[[^=?]=]*$/
      end

      def self.create_get_and_set_method(attr_name)
        class_eval("def #{attr_name}=(new_value); @#{attr_name}=new_value;end;def #{attr_name}; @#{attr_name};end;", __FILE__, __LINE__)
      end

      def method_missing(method,*args)
        if method.to_s =~ get_or_set_method? && @attr.include?($1)
          self.class.create_get_and_set_method($1)
          self.send method, args[0]
        else 
          super
        end    
      end

      def save
        keys = self.class.column_names.join(',')
        values = self.class.column_names.map {|column| "'"+self.send(column.to_sym).to_s+"'"}
        puts sql_query =  "INSERT INTO #{self.class.name.downcase} (#{keys}) VALUES (#{values.join(',')}) "
        begin
          Base.connection.query(sql_query)
          true
        rescue PG::SyntaxError => error
          puts "SQL SYNTAX ERROR"
          false 
        end
      end

      def self.find(id)
        if id.is_a?(Integer)
          values = Base.connection.query("SELECT #{column_names.join(',')} FROM #{self.name} WHERE ID = #{id}").values
          
          rec = (Object.const_get(self.name.capitalize)).new

          (0..(column_names.length-1)).each do |index|
            rec.instance_eval "self.#{column_names[index]}=values.flatten[index]"
          end

          rec
        else

          puts "Only integer id's are supported"
          return false
        end
      end

    end)
  end
end