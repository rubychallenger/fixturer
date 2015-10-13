require 'spec_helper'
require 'fake_record'

module Fixturer
  describe "FakeRecord" do
    before(:all) do
      DBconnect.instance().connect
      DBconnect.instance().query("
        CREATE TABLE HUMANS (
        ID BIGSERIAL PRIMARY KEY  NOT NULL,
        NAME           TEXT,
        LAST_NAME      TEXT)
      ")
      FakeRecord.create_class_for_table('humans') unless Object.const_defined? 'Humans'
    end

    after(:all) do
      DBconnect.instance().query("
        DROP TABLE HUMANS
      ")
    end

    it "creates class for every db table" do 
      v = Humans.new     
      v.should be
      v.instance_variable_get("@attr").should include("name","last_name")
    end

    it "creates getter and setter method on call of db columns(e.g. .name, .name=)" do
      v = Humans.new
      v.name="text"
      v.last_name="cmon"
      v.name.should == "text"
      v.last_name.should == "cmon"
      v.should respond_to(:name,:name=,:last_name,:last_name=)
    end

    it "allows save and find of db records" do
      v = Humans.new
      v.name="testtext"
      v.last_name="cmontest"
      v.save
      Humans.find(1).name.should == "testtext"
      Humans.find(1).last_name.should == "cmontest"
    end
  end 
end