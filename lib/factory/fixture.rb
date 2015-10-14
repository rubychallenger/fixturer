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
    @fixture.each do |record|
      record.each {|hash| rec.instance_eval "self.#{hash[0]}=hash[1]"}
      rec.save
    end
  end
end