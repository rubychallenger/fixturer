require 'hash'

class FixtureFactory
  def initialize(format)
    @format = self.class.const_get(format.capitalize+"Factory")
  end

  def new_file(name)
    @format.new(name)
  end

  def parse
    raise "Not yet implemented: parse for #{self.name}"
  end

  class IniFactory
    def initialize(table_name)
      @table_name = table_name
    end

    def parse
      ini = ""
      data = Hash.recursive
      File.open(File.expand_path('../../../fixtures', __FILE__)+"/#{@table_name}.ini", 'r') do |file|
        while (line = file.gets)
          ini << line
        end
      end

      eval(ini)
      data.values
    end
  end

  class JsonFactory
    def initialize(table_name)
      @table_name = table_name
    end

    def parse
      json = ""
      File.open(File.expand_path('../../../fixtures', __FILE__)+"/#{@table_name}.json", 'r') do |file|        
        while (line = file.gets)
          json << line
        end
      end

      eval(json.gsub(':','=>'))
    end
  end

  #class ModelFactory
  #  def initialize(name)
  #    @name = name
  #    Object.const_set(@name.capitalize, Class.new(Base)) unless Object.const_defined? @name.capitalize
  #  end
  #end
end

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
