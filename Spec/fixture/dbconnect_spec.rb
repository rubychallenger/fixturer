require 'spec_helper'

module Fixturer
  describe "dbconnect" do
    before(:each) {  @dbconnect_class = DBconnect.clone  }

    it "throws error if connected with wrong info" do
      begin
        @dbconnect_class.instance().connect('loc')
      rescue => @error
      end
      @error.class.to_s.should == "PG::ConnectionBad"
    end
    it "dont have con if not connected" do
      @dbconnect_class.instance().con.should be_nil
    end
    
    it "got con after first connection" do
      @dbconnect_class.instance().connect
      @dbconnect_class.instance().con.should be
    end

    it "can perform sql query after connect" do
      @dbconnect_class.instance().connect
      @dbconnect_class.instance().query("SELECT * FROM posts").should be
    end
  end 
end