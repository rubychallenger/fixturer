task :find_by do
  con = DBconnect.instance()
  puts Post.find_by_name_and_id("Sam",33)
  Post.find_by_name_and_id("Sam",33).instance_eval '@attr.each {|a| puts "#{a}: #{self.send a.to_sym}"}'
end