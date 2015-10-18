module FakeRecord
  class Base
    extend Search
    include DataOperations

    def initialize
      @attr = self.class.column_names
      @id = set_start_id

      create_accessors_for_attributes
    end

    def attributes
      @attr
    end
    
    private 

      def create_accessors_for_attributes
        @attr.each do |att|
          self.class.class_eval("attr_accessor :#{att}")
        end
      end

      def self.column_names
        DBconnect.instance.query("
          select column_name
          from information_schema.columns 
          where table_name = '#{self.name.downcase}s'
          ").values.flatten
      end

      def set_start_id
        DBconnect.instance.query("SELECT MAX(id) FROM #{self.class.name}s").values.flatten[0].to_i + 1
      end
  end
end