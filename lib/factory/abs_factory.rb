#require 'hash'
class FixtureFactory
  def initialize(format)
    @format_class = self.class.const_get(format.capitalize+"Factory")
  end

  def new_file(name)
    @format_class.new(name)
  end

  def parse
    raise "Not yet implemented: parse for #{self.name}"
  end

  def get_data_from_fixture(base_name,format)
    data = ""
    File.open(File.expand_path('../../../fixtures', __FILE__)+"/#{base_name}.#{format}", 'r') do |file|
      while (line = file.gets)
        data << line
      end
    end

    data
  end

  #class ModelFactory
  #  def initialize(name)
  #    @name = name
  #    Object.const_set(@name.capitalize, Class.new(Base)) unless Object.const_defined? @name.capitalize
  #  end
  #end
end
