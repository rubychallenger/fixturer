require 'spec_helper'

module Fixturer
  describe "FakeRecord" do

    it "creates class for every db table" do  
      v = Test.new       
      expect(v).to be
      expect(v.instance_variable_get("@attr")).to include("name","last_name","id")
    end

    it "creates getter and setter method on create of clasess" do      
      v = Test.new
      v.name="text"
      v.last_name="cmon"
      expect(v.name).to eq "text"
      expect(v.last_name).to eq "cmon"
      expect(v).to respond_to(:name,:name=,:last_name,:last_name=)
    end

    it "ensures that created classes respond to .where .find .find_by_name" do
      expect(Test).to respond_to(:where,:find,:find_by_name)
    end

    it "allows save and find of db records" do 
      v = Test.new
      v.name="testtext"
      v.last_name="cmontest"
      v.save
      expect(Test.last).to be_instance_of(Test)
      expect(Test.last.name).to eq "testtext"
      expect(Test.last.last_name).to eq "cmontest"
      Test.last.destroy
    end
  end 
end