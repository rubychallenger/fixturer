task :check do
  con = DBconnect.instance().connect
  tables = con.query("
      SELECT table_name
      FROM information_schema.tables
      WHERE table_schema='public'
      AND table_type='BASE TABLE';
      ").map {|e| e.values}.flatten
  tables.each do |table|
    puts "#{table.upcase} RECORDS"
    puts con.query("SELECT * FROM #{table}").map {|k| "#{k} \n"}
  end
end