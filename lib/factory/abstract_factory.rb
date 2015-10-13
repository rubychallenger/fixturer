require 'hash'

module IniFactory
  extend self

  def parsed_info
    return IniFile.new
  end

  class IniFile
    def parse(table_name)
      ini = ""
      data = Hash.recursive
      File.open(File.expand_path('../../../fixtures', __FILE__)+"/#{table_name}.ini", 'r') do |file|
        while (line = file.gets)
          ini << line
        end
      end

      eval(ini)
      @info = data.values
    end
  end
end

module JsonFactory
  extend self

  def parsed_info
    return JsonFile.new
  end

  class JsonFile
    def parse(table_name)
      json = ""
      File.open(File.expand_path('../../../fixtures', __FILE__)+"/#{table_name}.json", 'r') do |file|        
        while (line = file.gets)
          json << line
        end
      end

      @info = eval(json.gsub(':','=>'))
    end
  end
end