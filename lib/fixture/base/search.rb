module Search
  def method_missing(method,*args)
    super unless method.to_s =~ find_by_method? && !(column_names - (list = $1.split('_and_'))).empty?
    res = where(Hash[list.zip(args)])
    return res[0] if list.include? "id"
    res
  end

  def respond_to_missing?(method, include_private = false)
    (method.to_s =~ find_by_method? && !(column_names - (list = $1.tr('_','').split('and'))).empty?) || super
  end

  def where(hash_or_sql_string,*args)
    if hash_or_sql_string.is_a? Hash
      look_by_hash(hash_or_sql_string)
    elsif hash_or_sql_string.is_a? String
      look_by_sql_string(hash_or_sql_string, args)
    else
      raise 'bad arguments'
    end
  end

  def last
    parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s ORDER BY ID DESC LIMIT 1"))[0]
  end

  def first
    parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s LIMIT 1"))[0]
  end

  def find(id)
    if id.is_a?(Integer)
      parse_db_result(DBconnect.instance.query("SELECT #{self.column_names.join(',')} FROM #{self.name}s WHERE ID = #{id}"))[0]
    else
      puts "Only integer id's are supported"
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
        rec
        result << rec
      end
      result
    end

    def find_by_method?()
      /^find_by_([_a-zA-Z]*)[^=?]*$/
    end

    def look_by_hash(hash)
      sql_query = hash.keys.inject([]){|arr,item| arr << "#{item} = ?"}.join(' AND ')
      parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s WHERE " + sql_query,hash.values))
    end

    def look_by_sql_string(sql_string,*args)
      args = args[0] if args.length == 1
      parse_db_result(DBconnect.instance.query("SELECT * FROM #{self.name}s WHERE "+sql_string ,args ))
    end
end