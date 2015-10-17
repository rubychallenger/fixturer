require 'spec_helper'

describe "fixturer" do
  describe "db_connection" do
    it "DBconnect.instance() got connection" do
      expect(DBconnect.instance().instance_variable_get("@conn")).to be_a PG::Connection
    end
  end

  describe "FixtureFactory" do
    it "creates factory with supported format given" do
      expect(FixtureFactory.new('ini').new_file('post')).to be_instance_of IniFactory
    end

    it "raises error if format unsupported" do
      expect{FixtureFactory.new('dat').new_file('test')}.to raise_error(NameError)
    end

    it "parses file to array of hashes if everything passed good" do
      expect(h = FixtureFactory.new('json').new_file('post').parse).to be_a Array
      h.each do |hash|
        expect(hash).to be_a Hash
      end
    end
  end

  describe "save_to_db" do
    it "adds a record to DB table corresponding to the given model" do
      a = Test.last
      (f1 = Fixture.new('Test',FixtureFactory.new('json'))).save_to_db
      b = Test.last
      (f2 = Fixture.new('Test',FixtureFactory.new('json'))).save_to_db
      expect(b).to_not equal a
      c = Test.last
      f1.clear_associated_records
      f2.clear_associated_records
      expect(c.name).to eq b.name
      expect(c.last_name).to eq b.last_name
      expect(c).to_not equal b
      a.destroy if a
      b.destroy
      c.destroy
    end

    it "raises NameError if there is no such model given" do
      expect{Fixture.new('car',FixtureFactory.new('ini')).save_to_db}.to raise_error(NameError)
    end

    it "raises 'no such file or directory' if there is model of the name given but no fixture provided" do
      expect{Fixture.new('Test',FixtureFactory.new('ini')).save_to_db}.to raise_error(Errno::ENOENT)
    end
  end

  describe "model" do
    it "Can find record in db after uploading it" do
      rec = Test.new
      rec.name = "Sam"
      rec.last_name = "Hit"

      rec.save
      expect(Test.last.name).to eq "Sam"
      expect(Test.last.last_name).to eq "Hit"
      expect(Test.where(name: "Sam").last.last_name).to eq "Hit"
      expect(Test.find_by_name("Sam").last.last_name).to eq "Hit"

      Test.last.destroy
    end

    it "can pull record from db, update it and save back" do
      rec = Test.last
      name = rec.name
      rec.name = "Chessie"
      rec.save

      expect(Test.last.name).to_not eq name
      expect(Test.last.name).to eq "Chessie"
    end
  end
end 