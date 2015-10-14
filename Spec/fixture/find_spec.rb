require 'spec_helper'
require 'fake_record'

module Fixturer
  describe "search" do
    before(:all) do
      DBconnect.instance().query("
        CREATE TABLE HUMANS (
        ID BIGSERIAL PRIMARY KEY  NOT NULL,
        NAME           TEXT,
        LAST_NAME      TEXT)
      ")
      FakeRecord.create_class_for_table('humans') unless Object.const_defined? 'Humans'
      v = Humans.new
      v.last_name = "Dan"
      v.save
    end

    after(:all) do
      FakeRecord.delete_class('Humans')

      DBconnect.instance().query("
        DROP TABLE HUMANS
      ")
    end

    it "finds a record in db using find" do
      (Humans.find(1)).should be_instance_of(Humans)
      (Humans.find(1).last_name).should == "Dan"
    end

    it "finds a record in db using find_by" do
      (a = Humans.find_by_last_name("Dan")).should be_instance_of(Humans)
      (b = Humans.find_by_id(1)).should be_instance_of(Humans)
      (c = Humans.find_by_last_name_and_id("Dan",1)).should be_instance_of(Humans)
      a.last_name.should == "Dan"
      b.id.should == "1"
      c.last_name.should == "Dan"
    end

    it "finds a record in db using where" do
      (Humans.where("last_name = 'Dan'")).should be_instance_of(Humans)
      (Humans.where("last_name = ?",'Dan')).should be_instance_of(Humans)
      (Humans.where(last_name: 'Dan')).should be_instance_of(Humans)
      Humans.where("last_name = ?",'Dan').last_name.should == 'Dan'
      Humans.where("last_name = 'Dan'").last_name.should == 'Dan'
      Humans.where(last_name: 'Dan').last_name.should == 'Dan'
    end
  end
end