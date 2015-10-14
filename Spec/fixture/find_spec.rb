require 'spec_helper'

module Fixturer
  describe "search" do
    before(:all) do
      DBconnect.instance().query("
        CREATE TABLE humans (
        ID BIGSERIAL PRIMARY KEY  NOT NULL,
        NAME           TEXT,
        LAST_NAME      TEXT)
      ")
      FakeRecord.create_class_for_table('humans') unless Object.const_defined? 'Human'
      v = Human.new
      v.last_name = "Dan"
      v.save
    end

    after(:all) do
      FakeRecord.delete_class('Human')

      DBconnect.instance().query("
        DROP TABLE humans
      ")
    end

    it "finds a record in db using find" do
      (Human.find(1)).should be_instance_of(Human)
      (Human.find(1).last_name).should == "Dan"
    end

    it "finds a record in db using find_by" do
      (a = Human.find_by_last_name("Dan")).should be_instance_of(Human)
      (b = Human.find_by_id(1)).should be_instance_of(Human)
      (c = Human.find_by_last_name_and_id("Dan",1)).should be_instance_of(Human)
      a.last_name.should == "Dan"
      b.id.should == "1"
      c.last_name.should == "Dan"
    end

    it "finds a record in db using where" do
      (Human.where("last_name = 'Dan'")).should be_instance_of(Human)
      (Human.where("last_name = ?",'Dan')).should be_instance_of(Human)
      (Human.where(last_name: 'Dan')).should be_instance_of(Human)
      Human.where("last_name = ?",'Dan').last_name.should == 'Dan'
      Human.where("last_name = 'Dan'").last_name.should == 'Dan'
      Human.where(last_name: 'Dan').last_name.should == 'Dan'
    end
  end
end