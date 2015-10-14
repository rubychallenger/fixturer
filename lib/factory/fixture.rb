require 'factory/abs_factory'

class Fixture < FixtureFactory
  def initialize(table_name,fixture_factory)
    @model = Object.const_get(table_name.capitalize)
    @fixture = fixture_factory.new_file("#{table_name}").parse
  end

  def save_to_db
    rec = @model.new

    atr = rec.instance_variable_get("@attr")  
    arr = []
    @fixture.each do |element|
      element.each {|k,v| rec.instance_eval "self.#{k}=v" if atr.include? k.to_s }
      rec.save
      arr << rec
      rec = @model.new
    end

    @fixture = arr
  end

  def clear_records
    @fixture.each {|rec| rec.destroy} if @fixture[0].is_a? @model
  end
end