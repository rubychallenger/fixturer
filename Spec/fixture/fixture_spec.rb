require 'spec_helper'

module Fixturer
  describe "fixture" do
    before(:each) do
      File.open(File.expand_path('../../../fixtures', __FILE__)+"/human.ini","w+") do |f|
        f.write("data['alias1']['name'] = 'San' \ndata['alias1']['last_name'] = 'Bom' \ndata['alias1']['age'] = 20")
      end

      DBconnect.instance().connect
      DBconnect.instance().query("
        CREATE TABLE HUMANS (
        ID BIGSERIAL PRIMARY KEY  NOT NULL,
        NAME           TEXT,
        LAST_NAME      TEXT )
      ")
      require 'fake_record'
      require 'fixture'
    end

    after(:each) do
      DBconnect.instance().query("
        DROP TABLE humans
      ")
      File.delete(File.expand_path('../../../fixtures', __FILE__)+"/human.ini")
    end

    it "initializes a factory on new" do
      fix = Fixture.new("human",IniFactory)
      expect(fix.instance_variable_get("@info")).to be_a IniFactory::IniFile
    end

    it "parses file to array of hashes through factory" do
      fix = Fixture.new("human",IniFactory)
      info = fix.instance_variable_get("@info").parse('human')
      expect(info).to be_a Array
      info.each do |i|
        expect(i).to be_a Hash
      end
    end

    it "saves file to db" do
      fix = Fixture.new("human",IniFactory)
      fix.save_to_db

      expect(Humans.find(1).name).to eq 'San'
      expect(Humans.find(1).last_name).to eq 'Bom'
      expect(Humans.find(1)).to_not respond_to :age, :age=
    end
  end 
end