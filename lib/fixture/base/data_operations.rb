module DataOperations
  def save
    record_exists? ? update_record : save_record
  end

  #def update_attributes(hash)
  #  update_instance(hash)
  #  DBconnect.instance.query(update_sql_query)
  #end

  def destroy
    DBconnect.instance.query("DELETE FROM #{self.class.name}s WHERE ID = #{self.id};")
  end

  #def update_instance(hash)
  #  puts hash
  #  hash["id"].is_a? String
  #  hash.each do |k,v|
  #    self.instance_eval "self.#{k}=#{convert(v)} if (@attr-['id']).include?(#{k})"
  #  end
  #end
  #def get_or_set_method?()
  # /^([a-zA-Z][-_\w]*)[[^?]=]*$/
  #end

  #def method_missing(method,*args)
  #  if method.to_s =~ get_or_set_method? && @attr.include?($1)
  #    self.class.create_get_and_set_method($1)
  #    self.send method, args[0]
  #  else
  #   super
  #  end    
  #end

  # def self.create_get_and_set_method(attr_name)
  #   class_eval("def #{attr_name}=(new_value); @#{attr_name}=new_value;end;def #{attr_name}; @#{attr_name} ;end;", __FILE__, __LINE__)
  # end
  private
    def update_record
      DBconnect.instance.query(update_sql_query)
    end

    def save_record
      DBconnect.instance.query(create_sql_query)
      self.id = self.class.last.id.to_i
    end

    def record_exists?
      self.class.find(self.id) != nil
    end

    def create_sql_query
      "INSERT INTO #{self.class.name}s (#{keys.join(',')}) VALUES (#{values.join(',')}) "
    end

    def update_sql_query
      "UPDATE #{self.class.name}s SET " + key_value_sql_string + "WHERE ID = #{self.id}"
    end

    def hash_params
      Hash[keys.zip(values)]
    end

    def key_value_sql_string
      (0..(keys.length - 1)).inject(""){|str,index| str << (index == 0 ? "" : ", ") + "#{keys[index]} = #{values[index]}"  }
    end

    def keys
      (self.class.column_names - ["id"])
    end

    def values
      (self.class.column_names - ["id"]).map {|column| convert_for_sql_query((self.send(column.to_sym) if self.respond_to? column.to_sym)) }
    end

    def convert_for_sql_query(convertible)
      if convertible.is_a? String or convertible.is_a? NilClass
        "'" + convertible.to_s + "'"
      else
        convertible
      end
    end
end