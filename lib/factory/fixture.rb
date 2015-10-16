require 'factory/abs_factory'

class Fixture < FixtureFactory
  def initialize(table_name,fixture_factory)
    @model = Object.const_get(table_name.capitalize)
    @fixture = fixture_factory.new_file("#{table_name}").parse
  end

  def save_to_db
    len = @fixture.length

    (0..len-1).each do |index|
      save_element_to_db_and_update_fixture(index)
    end
  end

  def clear_records
    @fixture.each {|rec| rec.destroy} if @fixture[0].is_a? @model
  end

  private

    def save_element_to_db_and_update_fixture(index)
      record = @model.new
      @fixture[index].each {|k,v| record.instance_eval "self.#{k}=v" if record.attributes.include? k.to_s }
      record.save
      @fixture[index] = record
    end

end