require 'abs_factory'

class Fixture < FixtureFactory
  def initialize(table_name,fixture_factory)
    @model = Object.const_get(table_name.capitalize)
    @fixture = fixture_factory.new_file("#{table_name}").parse
  end

  def save_to_db
    rec = @model.new

    atr = rec.instance_variable_get("@attr")  
    @fixture = @fixture.each do |element|
      element.delete_if {|k,v| !(atr.include? k.to_s)}
    end
    @fixture.map! do |record|
      record.each {|hash| rec.instance_eval "self.#{hash[0]}=hash[1]"}
      rec.save
      rec
    end
  end

  def clear_records
    @fixture.each {|rec| rec.destroy} if @fixture[0].is_a? @model
  end
end