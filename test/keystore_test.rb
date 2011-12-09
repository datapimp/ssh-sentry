require File.dirname(__FILE__) + '/test_helper'

describe Sentry::Keystore do
  before do
    @keystore = Sentry::Keystore.new(:authorized_keys_file=> Tempfile.new("blahblahblah").path, :export_location => Tempfile.new("blah").path )
  end
  
  it "should start off with empty storage" do
    @keystore.storage.must_be_empty
  end

  it "should allow me to add multiple keys with the same signature" do
    keys = [
      "boobooboo jonathan@thinktank", 
      "harharhar jonathan@thinktank", 
      "yesyesyes jonathan@thinktank"
    ] 
    
    keys.each do |key|
      name = key.split.last
      @keystore.add_key(name, key)
    end

    @keystore.storage.keys.must_equal ["jonathan@thinktank","jonathan@thinktank:1","jonathan@thinktank:2"]
  end

  it "should allow me to find a key's id by the value" do
    @keystore.add_key("jonathan@thinktank","blahblahblah")
    @keystore.send(:find_key_name,"blahblahblah").must_equal "jonathan@thinktank"
  end

  it "should allow me to remove a key by the key name" do
    @keystore.add_key("jonathan@thinktank","blahblahblah")
    @keystore.remove_keys("jonathan@thinktank").must_equal 1
  end

  it "should allow me to remove a key by the key contents" do
    @keystore.add_key("jonathan@thinktank","blahblahblah")
    @keystore.remove_keys("blahblahblah").must_equal 1
  end

  it "should allow me to remove all keys for a given machine id" do
    @keystore.add_key("jonathan@thinktank","blahblahblah")
    @keystore.add_key("jonathan@thinktank","yoyoyoyoyoyo")
    @keystore.remove_by_machine("jonathan@thinktank").must_equal 2
  end

  it "should allow me to export the key store to disk" do
    @keystore.add_key("jonathan@thinktank","blahblahblah")
    @keystore.export
    IO.read(@keystore.send(:export_location)).chomp.must_equal JSON.generate( @keystore.storage )
  end

  it "should allow me to import a key store" do
    @keystore.import('{"jonathan@thinktank":"blahblah"}')
    @keystore.storage.wont_be_empty
  end

end
