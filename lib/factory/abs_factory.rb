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

  require 'ini_factory'
  require 'json_factory'
  #class ModelFactory
  #  def initialize(name)
  #    @name = name
  #    Object.const_set(@name.capitalize, Class.new(Base)) unless Object.const_defined? @name.capitalize
  #  end
  #end
end
