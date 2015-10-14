require 'spec_helper'

module Fixturer
  describe "dbconnect instance" do
    before(:each) {  @dbconnect_class = DBconnect.clone  }

    it "throws error if connected with wrong info" do
      begin
        @dbconnect_class.instance().reconnect('loc')
      rescue => @error
      end
      expect(@error.class.to_s).to eq "PG::ConnectionBad"
    end
    
    it "got connection to at least default db" do
      expect(@dbconnect_class.instance().conn).to be_a PG::Connection
    end

    it "can perform sql query after connect" do
      expect(@dbconnect_class.instance().query("SELECT * FROM posts")).to be
    end
  end 
end