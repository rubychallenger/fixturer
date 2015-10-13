require 'dbconnect'

module Base
  def self.establish_connection
    DBconnect.instance().connect
  end

  def self.connection
    establish_connection unless DBconnect.instance().con
    DBconnect.instance()
  end

  def self.table_names
    connection.query("
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema='public'
      AND table_type='BASE TABLE';
      ").map {|e| e.values}
  end 
end