require 'dbclasses'

class FakeRecord
  require 'base'

  extend DBClasses

  table_names.flatten.each do |table|
    create_class_for_table(table)
  end
end