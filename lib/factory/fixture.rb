require 'factory/abs_factory'

class Fixture < FixtureFactory
  def initialize(table_name,fixture_factory)
    @model = Object.const_get(table_name.capitalize)
    @fixture = fixture_factory.new_file("#{table_name}").parse
  end

  def save_to_db
    if already_saved?
      puts "already saved this fixture to db"
    else
      save
    end
  end

  def clear_associated_records
    @fixture.each {|rec| rec.destroy} if already_saved?
  end

  private

    def already_saved?
      !(@fixture[0].is_a? Hash)
    end

    def save
      (0..@fixture.length-1).each do |index|
        save_element_to_db_and_update_fixture(index)
      end
    end

    def save_element_to_db_and_update_fixture(index)
      record = @model.new
      @fixture[index].each {|k,v| record.instance_eval "self.#{k}=v" if record.attributes.include? k.to_s }
      record.save
      @fixture[index] = record
    end

end