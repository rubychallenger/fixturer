task :create_table, :table_name do |t,args| 

  unless File.exist?(File.expand_path("../../models/#{args[:table_name]}s.rb", __FILE__))

    File.open(File.expand_path("../../models/#{args[:table_name]}s.rb", __FILE__),"w+") do |f|
      f.write("require 'fake_record'\nclass #{args[:table_name].to_s.capitalize}s < FakeRecord::Base\nend")
    end

  else 

    puts "This model already exists."

  end

  con = Base.connection

  con.query("DROP TABLE #{(args[:table_name].to_s).upcase}S")

  con.query("CREATE TABLE #{args[:table_name].to_s.upcase}S (
    ID BIGSERIAL PRIMARY KEY  NOT NULL," + args.extras[0].upcase + ")")

  FakeRecord.create_class_for_table(args[:table_name]+'s') unless Object.const_defined? "#{args[:table_name].capitalize}s"
end