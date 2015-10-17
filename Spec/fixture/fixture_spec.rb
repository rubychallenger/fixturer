require 'spec_helper'

module Fixturer
  describe "fixture" do
    it "initializes a factory on new" do
      fact = FixtureFactory.new('json')
      expect(fact).to be_instance_of FixtureFactory
      expect(fact.new_file('Test')).to be_instance_of JsonFactory
      expect(Fixture.new("Test",fact)).to be
    end

    it "parses file to array of hashes through factory" do
      fact = FixtureFactory.new('json')
      fix = Fixture.new("Test",fact).instance_variable_get("@fixture")
      expect(fix).to be_a Array
      fix.each do |i|
        expect(i).to be_a Hash
      end
    end

    it "saves file to db" do
      fix = Fixture.new("Test", FixtureFactory.new('json'))
      fix.save_to_db

      expect(Test.last.name).to eq 'Sam'
      expect(Test.last.last_name).to eq 'Winchester'
      expect(Test.last).to_not respond_to :age, :age=

      fix.clear_associated_records
    end
  end 
end