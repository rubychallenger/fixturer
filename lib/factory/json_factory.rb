class JsonFactory < FixtureFactory
  def initialize(table_name)
    @table_name = table_name
  end

  def parse
    eval(get_data_from_fixture(@table_name,'json').gsub(':','=>'))
  end
end