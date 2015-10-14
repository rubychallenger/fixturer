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

      FakeRecord::DBClasses.create_class_for_table('humans') unless Object.const_defined? 'Human'
    end

    after(:all) do
      FakeRecord::DBClasses.delete_class('Human')
      DBconnect.instance().query("
        DROP TABLE humans
      ")
      File.delete(File.expand_path('../../../fixtures', __FILE__)+"/human.ini")
    end

    it "initializes a factory on new" do
      fact = FixtureFactory.new('ini')
      expect(fact).to be_instance_of FixtureFactory
      expect(fact.new_file('human')).to be_instance_of FixtureFactory::IniFactory
      expect(Fixture.new("human",fact)).to be
    end

    it "parses file to array of hashes through factory" do
      fact = FixtureFactory.new('ini')
      fix = Fixture.new("human",fact).instance_variable_get("@fixture")
      expect(fix).to be_a Array
      fix.each do |i|
        expect(i).to be_a Hash
      end
    end

    it "saves file to db" do
      fact = FixtureFactory.new('ini')
      fix = Fixture.new("human", fact)
      fix.save_to_db

      expect(Human.find(1).name).to eq 'San'
      expect(Human.find(1).last_name).to eq 'Bom'
      expect(Human.find(1)).to_not respond_to :age, :age=
    end
  end 
end