require 'spec_helper'

module Fixturer
  describe "fixture" do
    before(:all) do
      File.open(File.expand_path('../../../fixtures', __FILE__)+"/human.ini","w+") do |f|
        f.write("data['alias1']['name'] = 'San' \ndata['alias1']['last_name'] = 'Bom' \ndata['alias1']['age'] = 20")
      end
      DBconnect.instance().query("
        CREATE TABLE HUMANs (
        ID BIGSERIAL PRIMARY KEY  NOT NULL,
        NAME           TEXT,
        LAST_NAME      TEXT )
      ")

      FakeRecord.create_class_for_table('humans') unless Object.const_defined? 'Human'
    end

    after(:all) do
      FakeRecord.delete_class('Human')
      DBconnect.instance().query("
        DROP TABLE humans
      ")
      File.delete(File.expand_path('../../../fixtures', __FILE__)+"/human.ini")
    end

    it "initializes a factory on new" do
      fact = FixtureFactory.new('ini')
      fact.should be_instance_of FixtureFactory
      fact.new_file('human').should be_instance_of FixtureFactory::IniFactory
      Fixture.new("human",fact).should be
    end

    it "parses file to array of hashes through factory" do
      fact = FixtureFactory.new('ini')
      fix = Fixture.new("human",fact).instance_variable_get("@fixture")
      fix.should be_a Array
      fix.each do |i|
        i.should be_a Hash
      end
    end

    it "saves file to db" do
      fact = FixtureFactory.new('ini')
      fix = Fixture.new("human", fact)
      fix.save_to_db

      Human.find(1).name.should == 'San'
      Human.find(1).last_name.should == 'Bom'
      Human.find(1).should_not respond_to :age, :age=
    end
  end 
end