require File.dirname(__FILE__) + '/test_helper'

describe Sentry::Keystore do
  before do
    @keyfile = Tempfile.new("public_key")
    @keyfile.print "ssh-rsa blahblahblahblahblahblahblah== jonathan@thinktank"
    @keyfile.flush

    @keystore = Sentry::Keystore.new(:authorized_keys_file=> Tempfile.new("blahblahblah").path, :config_file => Tempfile.new("blah").path )
  end

  it "should start off with empty storage" do
    @keystore.storage.must_be_empty
  end
  
  describe "authorizing users" do
    it "should allow me to add a key for a user named jonathan" do
      @keystore.authorize :user => "jonathan", :with => @keyfile.path  
      @keystore.storage.keys.must_equal ["jonathan@thinktank"]
      @keystore.users.keys.must_equal ["jonathan"]
      @keystore.send(:key_ids_for_user,"jonathan").must_equal ["jonathan@thinktank"]
    end
  end
  
  it "should allow me to authorize a user with a key" do
    @keystore.authorize(:user=>"jonathan",:with=>"ssh-rsa blahblahblah jonathan@thinktank")
    IO.read( @keystore.send(:authorized_keys_file) ).lines.to_a.must_include "ssh-rsa blahblahblah jonathan@thinktank"
  end

  describe "revoking access from users" do
    it "should allow me to revoke access from a user named jonathan" do
      @keystore.authorize :user => "jonathan", :with => @keyfile.path  
      @keystore.revoke :user => "jonathan"
      @keystore.send(:key_ids_for_user,"jonathan").must_equal nil 
      @keystore.storage.keys.must_equal []
    end
  end

  describe "the lower level methods" do
    it "should allow me to add multiple keys with the same signature" do
      keys = [
        "boobooboo jonathan@thinktank", 
        "harharhar jonathan@thinktank", 
        "yesyesyes jonathan@thinktank"
      ] 

      keys.each do |key|
        name = key.split.last
        @keystore.send(:add_key,name,key)
      end

      @keystore.storage.keys.must_equal ["jonathan@thinktank","jonathan@thinktank:1","jonathan@thinktank:2"]
    end


    it "should allow me to find a key's id by the value" do
      @keystore.authorize(:user=>"jonathan",:with=>"blahblahblah jonathan@thinktank")
      @keystore.send(:find_key_name,"blahblahblah jonathan@thinktank").must_equal "jonathan@thinktank"
    end

    it "should allow me to remove a key by the key name" do
      @keystore.authorize(:user=>"jonathan",:with=>"blahblahblah jonathan@thinktank")
      @keystore.send(:remove_keys,"jonathan@thinktank").must_equal 1
    end

    it "should allow me to remove a key by the key contents" do
      @keystore.authorize(:user=>"jonathan",:with=>"blahblahblah jonathan@thinktank")
      @keystore.send(:remove_keys,"blahblahblah jonathan@thinktank").must_equal 1
    end

    it "should allow me to remove all keys for a given machine id" do
      @keystore.authorize(:user=>"jonathan",:with=>"blahblahblah jonathan@thinktank")
      @keystore.authorize(:user=>"jonathan",:with=>"yoyoyoyoyoyo jonathan@thinktank")
      @keystore.send(:remove_by_machine,"jonathan@thinktank").must_equal 2
    end
  end

  describe "the keystore setup" do
    it "should backup the config file" do
      @keystore.send(:backup_authorized_keys)
      File.exists?( @keystore.send(:authorized_keys_file) + '.sentry-original' ).must_equal true
    end

    it "should allow me to config the key store to disk" do
      @keystore.authorize(:user=>"jonathan",:with=>"blahblahblah jonathan@thinktank")
      @keystore.send :save_config
      @keystore.send(:to_keystore).must_equal JSON.parse( IO.read( @keystore.send(:keystore_config_location) ))
    end

    it "should allow me to import a key store from disk" do
      File.open( @keystore.send(:keystore_config_location), 'w+') {|f| f.puts '{"storage":{"jonathan@thinktank":"blahblahblah"},"users":{"jonathan":["jonathan@thinktank"]}}'}
      @keystore.send :load_config
      @keystore.storage.wont_be_empty
    end

    it "should allow me to import a key store by passing a JSON string as config" do
      @keystore.send :load_config, '{"storage":{"jonathan@thinktank":"blahblahblah"},"users":{"jonathan":["jonathan@thinktank"]}}'
      @keystore.storage.wont_be_empty
    end
  end

end
