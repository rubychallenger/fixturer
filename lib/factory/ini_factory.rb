class IniFactory < FixtureFactory
  def initialize(table_name)
    @table_name = table_name
  end

  def parse
    data = Hash.recursive
    eval(get_data_from_fixture(@table_name,'ini'))

    data.values
  end
end