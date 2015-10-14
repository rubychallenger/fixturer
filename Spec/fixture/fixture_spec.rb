require 'spec_helper'
require 'fake_record'
require 'fixture'

module Fixturer
  describe "fixture" do
    before(:all) do
      File.open(File.expand_path('../../../fixtures', __FILE__)+"/human.ini","w+") do |f|
        f.write("data['alias1']['name'] = 'San' \ndata['alias1']['last_name'] = 'Bom' \ndata['alias1']['age'] = 20")
      end

      DBconnect.instance().query("
        CREATE TABLE HUMANS (
        ID BIGSERIAL PRIMARY KEY  NOT NULL,
        NAME           TEXT,
        LAST_NAME      TEXT )
      ")

      FakeRecord.create_class_for_table('humans') unless Object.const_defined? 'Humans'
    end

    after(:all) do
      FakeRecord.delete_class('Humans')
      DBconnect.instance().query("
        DROP TABLE humans
      ")
      File.delete(File.expand_path('../../../fixtures', __FILE__)+"/human.ini")
    end

    it "initializes a factory on new" do
      fix = Fixture.new("human",IniFactory)
      fix.instance_variable_get("@info").should be_a IniFactory::IniFile
    end

    it "parses file to array of hashes through factory" do
      fix = Fixture.new("human",IniFactory)
      info = fix.instance_variable_get("@info").parse('human')
      info.should be_a Array
      info.each do |i|
        i.should be_a Hash
      end
    end

    it "saves file to db" do
      fix = Fixture.new("human",IniFactory)
      fix.save_to_db

      Humans.find(1).name.should == 'San'
      Humans.find(1).last_name.should == 'Bom'
      Humans.find(1).should_not respond_to :age, :age=
    end
  end 
end