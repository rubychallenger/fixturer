require 'spec_helper'

module Fixturer
  describe "dbconnect instance" do
    before(:each) {  @dbconnect_class = DBconnect.clone  }

    it "throws error if connected with wrong info" do
      begin
        @dbconnect_class.instance().reconnect('loc')
      rescue => @error
      end
      @error.class.to_s.should == "PG::ConnectionBad"
    end
    
    it "got connection to at least default db" do
      @dbconnect_class.instance().conn.should be_a PG::Connection
    end

    it "can perform sql query after connect" do
      @dbconnect_class.instance().query("SELECT * FROM posts").should be
    end
  end 
end