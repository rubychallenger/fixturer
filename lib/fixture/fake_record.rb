require 'base'
require 'dbclasses'

class FakeRecord
  extend Base
  extend DBClasses


  Base.table_names.flatten.each do |table|
    create_class_for_table(table)
  end
end