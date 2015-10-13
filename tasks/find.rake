task :find, [:table_name, :id] do |t,args|
  con = DBconnect.instance().connect
  puts "Record #{args[:id]} of #{args[:table_name].upcase} is "
  puts (Object.const_get((args[:table_name]).capitalize)).find(args[:id].to_i)
  (Object.const_get((args[:table_name]).capitalize)).find(args[:id].to_i).instance_eval '@attr.each {|a| puts "#{a}: #{self.send a.to_sym}"}'
end