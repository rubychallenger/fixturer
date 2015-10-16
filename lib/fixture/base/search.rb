module Search
  def method_missing(method,*args)
    super unless find_by_method?(method)
    res = where(list = Hash[method.to_s[8..-1].split('_and_').zip(args)])
    list.include?("id") ? res[0] : res
  end

  def find_by_method?(method)
    method.to_s =~ /^find_by_([_a-zA-Z]*)[^=?]*$/ && ($1.split('_and_') - column_names).empty?
  end

  def respond_to_missing?(method, include_private = false)
    find_by_method?(method) || super
  end

  def where(hash_or_sql_string,*args)
    if hash_or_sql_string.is_a? Hash
      query_with_hash(hash_or_sql_string)
    elsif hash_or_sql_string.is_a? String
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
    begin
      parse_db_result(DBconnect.instance.query("SELECT #{self.column_names.join(',')} FROM #{self.name}s WHERE ID = #{id}"))[0]
    rescue => error
      puts error
      return false
    end
  end

  private

    def parse_db_result(pg_result_object)
      result = []
      pg_result_object.values.each do |value|
        rec = self.new

        (0..(column_names.length-1)).each do |index|
          rec.instance_eval "self.#{column_names[index]}=value[index]"
        end

        result << rec
      end
      result
    end
   

    def query_with_hash(hash)
      sql_query = hash.keys.inject([]){|arr,item| arr << "#{item} = ?"}.join(' AND ')
      parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s WHERE " + sql_query,hash.values))
    end

    def query_with_sql_string(sql_string,*args)
      args = args[0] if args.length == 1
      parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s WHERE "+sql_string ,args ))
    end
end