require 'spec_helper'

describe "fixturer" do
  describe "db_connection" do
    it "DBconnect.instance() got connection" do
      expect(DBconnect.instance().instance_variable_get("@conn")).to be_a PG::Connection
    end
  end

  describe "FixtureFactory" do
    it "creates factory with supported format given" do
      expect(FixtureFactory.new('ini').new_file('post')).to be_instance_of FixtureFactory::IniFactory
    end

    it "raises error if format unsupported" do
      expect{FixtureFactory.new('dat').new_file('user')}.to raise_error(NameError)
    end

    it "parses file to array of hashes if everything passed good" do
      expect(h = FixtureFactory.new('json').new_file('post').parse).to be_a Array
      h.each do |hash|
          expect(hash).to be_a Hash
      end
    end
  end

  describe "save_to_db" do
    it "save_to_db adds a record to DB table corresponding to the given model" do
      a = User.last
      Fixture.new('user',FixtureFactory.new('ini')).save_to_db
      b = User.last
      expect(b).to_not equal a
      Fixture.new('user',FixtureFactory.new('ini')).save_to_db
      c = User.last

      expect(c.name).to eq b.name
      expect(c.last_name).to eq b.last_name
      expect(c.age).to eq b.age
      expect(c).to_not equal b
    end

    it "save_to_db raises NameError if there is no such model given" do
      expect{Fixture.new('car',FixtureFactory.new('ini')).save_to_db}.to raise_error(NameError)
    end

    it "save_to_db raises 'no such file or directory' if there is model of the name given but no fixture provided" do
      expect{Fixture.new('user',FixtureFactory.new('json')).save_to_db}.to raise_error(Errno::ENOENT)
    end
  end

  describe "model" do
    it "Can find record in db after uploading it" do
      rec = Post.new
      rec.name = "New_name_123"
      rec.text = "New_comment_123"

      rec.save

      expect(Post.last.name).to eq "New_name_123"
      expect(Post.last.text).to eq "New_comment_123"
      expect(Post.where(name: "New_name_123").text).to eq "New_comment_123"
      expect(Post.find_by_name("New_name_123").text).to eq "New_comment_123"
    end
  end
end 