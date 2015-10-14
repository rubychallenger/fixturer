require 'spec_helper'

module Fixturer
  describe "search" do
    before(:all) do
      @v = Test.new
      @v.last_name = "Dan"
      @v.save
    end

    after(:all) { @v.destroy }
    it "finds a record in db using find" do
      expect(Test.find(@v.id)).to be_instance_of(Test)
      expect(Test.find(@v.id).last_name).to eq "Dan"
    end

    it "finds a record in db using find_by" do
      expect(a = Test.find_by_last_name("Dan").last).to be_instance_of(Test)
      expect(b = Test.find_by_id(@v.id)).to be_instance_of(Test)
      expect(c = Test.find_by_last_name_and_id("Dan",@v.id)).to be_instance_of(Test)
      expect(a.last_name).to eq "Dan"
      expect(b.id).to eq "#{@v.id}"
      expect(c.last_name).to eq "Dan"
    end

    it "finds a record in db using where" do
      expect(Test.where(last_name: 'Dan').last).to be_instance_of(Test)
      expect(Test.where("last_name = ?",'Dan').last).to be_instance_of(Test)
      expect(Test.where("last_name = 'Dan'").last).to be_instance_of(Test)

      expect(Test.where("last_name = ?",'Dan').last.last_name).to eq 'Dan'
      expect(Test.where("last_name = 'Dan'").last.last_name).to eq 'Dan'
      expect(Test.where(last_name: 'Dan').last.last_name).to eq 'Dan'
    end
  end
end