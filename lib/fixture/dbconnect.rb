require 'singleton'
class DBconnect
  require 'pg'
  include Singleton

  def connect(host="localhost",port=5432,dbname="testapp",master_user="postgres",password="123456")
    @conn = PG.connect(host,port,'','',dbname,master_user,password)
  end

  def con
    @conn
  end

  def query(sql_query)
    @conn.exec_params(sql_query)
  end
end