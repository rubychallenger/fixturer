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