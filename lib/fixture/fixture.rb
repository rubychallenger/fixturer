require 'abstract_factory'

class Fixture < FakeRecord
  def initialize(table_name,factory)
    @table_name = table_name
    @info = factory.parsed_info
  end

  def save_to_db
    begin
      rec = (Object.const_get((@table_name+'s').capitalize)).new
    rescue NameError
      puts "NO SUCH DB TABLE: #{@table_name+'s'}"
      return
    end
    
    atr = rec.instance_variable_get("@attr") 
    @info = @info.parse(@table_name).each do |element|
      element.delete_if {|k,v| !(atr.include? k.to_s)}
    end
    @info.each do |record|
      record.each {|hash| rec.instance_eval "self.#{hash[0]}=hash[1]"}
      rec.save
    end
    
  end
end