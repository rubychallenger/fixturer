require 'spec_helper'

module Fixturer
  describe "FakeRecord" do
    before(:all) do
      DBconnect.instance().query("
        CREATE TABLE humans (
        ID BIGSERIAL PRIMARY KEY  NOT NULL,
        NAME           TEXT,
        LAST_NAME      TEXT)
      ")
      FakeRecord.create_class_for_table('humans') unless Object.const_defined? 'Human'
    end

    after(:all) do
      FakeRecord.delete_class('Human')

      DBconnect.instance().query("
        DROP TABLE humans
      ")
    end

    it "creates class for every db table" do 
      v = Human.new     
      v.should be
      v.instance_variable_get("@attr").should include("name","last_name")
    end

    it "creates getter and setter method on call of db columns(e.g. .name, .name=)" do
      v = Human.new
      v.name="text"
      v.last_name="cmon"
      v.name.should == "text"
      v.last_name.should == "cmon"
      v.should respond_to(:name,:name=,:last_name,:last_name=)
    end

    it "ensures that created classes respond to .where .find .find_by_name" do
      Human.should respond_to(:where,:find,:find_by_name)
    end

    it "allows save and find of db records" do
      v = Human.new
      v.name="testtext"
      v.last_name="cmontest"
      v.save
      Human.find(1).should be_instance_of(Human)
      Human.find(1).name.should == "testtext"
      Human.find(1).last_name.should == "cmontest"
    end
  end 
end