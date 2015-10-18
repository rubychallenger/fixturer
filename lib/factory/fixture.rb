class Fixture < FixtureFactory
  def initialize(table_name,fixture_factory)
    @model = Object.const_get(table_name.capitalize)
    @parsedData = fixture_factory.new_file("#{table_name}").parse
    @associated_objects = []
  end

  def save_to_db
    if already_saved?
      puts "already saved this fixture to db"
    else
      save
    end
  end

  def clear_associated_records
    @associated_objects.each {|rec| rec.destroy}
  end

  private

    def already_saved?
      @associated_objects != []
    end

    def save
      (0..@parsedData.length-1).each do |index|
        save_element_to_db_and_addto_objects(index)
      end
    end

    def save_element_to_db_and_addto_objects(index)
      record = @model.new
      @parsedData[index].each {|k,v| record.instance_eval "self.#{k}=v" if record.attributes.include? k.to_s }
      record.save
      @associated_objects << record
    end

end