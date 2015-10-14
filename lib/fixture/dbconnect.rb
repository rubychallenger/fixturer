require 'singleton'
require 'pg'

class DBconnect
  include Singleton

  def connect(host="localhost",port=5432,dbname="testapp",master_user="postgres",password="123456")
    @conn = PG.connect(host,port,'','',dbname,master_user,password)
  end

  def con
    @conn
  end

  def query(query,safe_params=[])
    (1..safe_params.length).each do |index|
      query = query.sub('?',"$#{index} ")
    end
    @conn.exec_params(query,safe_params)
  end
end