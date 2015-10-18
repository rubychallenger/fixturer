module Search
  def method_missing(method,*args)
    super unless find_by_method?(method)
    use_find_by_method(method,args)
  end

  def respond_to_missing?(method, include_private = false)
    find_by_method?(method) || super
  end

  def where(hash_or_sql_string,*args)
    case hash_or_sql_string
    when Hash
      query_with_hash(hash_or_sql_string)
    when String
      query_with_sql_string(hash_or_sql_string, args)
    else
      raise 'where accepts only hash or string arguments'
    end
  end

  def last
    parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s ORDER BY ID DESC LIMIT 1"))[0]
  end

  def first
    parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s LIMIT 1"))[0]
  end

  def find(id)
    parse_db_result(DBconnect.instance.query("SELECT #{self.column_names.join(',')} FROM #{self.name}s WHERE ID = #{id}"))[0]
  end

  private

    def find_by_method?(method)
      method.to_s =~ /^find_by_([_a-zA-Z]*)[^=?]*$/ && ($1.split('_and_') - column_names).empty?
    end

    def use_find_by_method(method,*args)
      args = args[0] if args.length == 1
      res = where(Hash[method.to_s[8..-1].split('_and_').zip(args)])
      method.to_s[8..-1].split('_and_').include?("id") ? res[0] : res
    end

    def parse_db_result(pg_result_object)
      result = []
      pg_result_object.values.each do |value|
        rec = self.new

        (0..(column_names.length-1)).each do |index|
          rec.instance_eval "self.#{column_names[index]}=value[index]"
        end

        result << rec
      end
      result.sort_by {|res| res.id.to_i}
    end
   

    def query_with_hash(hash)
      sql_query = hash.keys.inject([]){|arr,item| arr << "#{item} = ?"}.join(' AND ')
      parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s WHERE " + sql_query,hash.values))
    end

    def query_with_sql_string(sql_string,*args)
      args = args[0] if args.length == 1
      parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s WHERE " + sql_string ,args ))
    end
end