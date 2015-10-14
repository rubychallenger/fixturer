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
      FakeRecord::DBClasses.create_class_for_table('humans') unless Object.const_defined? 'Human'
      v = Human.new
      v.last_name = "Dan"
      v.save
    end

    after(:all) do
      FakeRecord::DBClasses.delete_class('Human')

      DBconnect.instance().query("
        DROP TABLE humans
      ")
    end

    it "finds a record in db using find" do
      expect(Human.find(1)).to be_instance_of(Human)
      expect(Human.find(1).last_name).to eq "Dan"
    end

    it "finds a record in db using find_by" do
      expect(a = Human.find_by_last_name("Dan")).to be_instance_of(Human)
      expect(b = Human.find_by_id(1)).to be_instance_of(Human)
      expect(c = Human.find_by_last_name_and_id("Dan",1)).to be_instance_of(Human)
      expect(a.last_name).to eq "Dan"
      expect(b.id).to eq "1"
      expect(c.last_name).to eq "Dan"
    end

    it "finds a record in db using where" do
      expect(Human.where(last_name: 'Dan')).to be_instance_of(Human)
      expect(Human.where("last_name = ?",'Dan')).to be_instance_of(Human)
      expect(Human.where("last_name = 'Dan'")).to be_instance_of(Human)

      expect(Human.where("last_name = ?",'Dan').last_name).to eq 'Dan'
      expect(Human.where("last_name = 'Dan'").last_name).to eq 'Dan'
      expect(Human.where(last_name: 'Dan').last_name).to eq 'Dan'
    end
  end
end