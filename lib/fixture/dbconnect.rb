require 'singleton'
require 'pg'

class DBconnect
  include Singleton

  def initialize()
    @connection = PG.connect("localhost",5432,'','',"testapp","postgres","123456")
  end

  def reconnect(host="localhost",port=5432,dbname="testapp",master_user="postgres",password="123456")
    @connection = PG.connect(host,port,'','',dbname,master_user,password)
  end

  def connection
    @connection
  end
  
  def query(query,safe_params=[])
    query = convert_question_marks_to_dollar_pg_signs(query,safe_params) if safe_params != [] # dollar pg signs = $1, $2 etc
    
    @connection.exec_params(query,safe_params)
  end

  private

  def convert_question_marks_to_dollar_pg_signs(query,params)
    (1..params.length).each do |index|
      query = query.sub('?',"$#{index} ")
    end
    query
  end
end