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