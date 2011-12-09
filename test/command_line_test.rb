require File.dirname(__FILE__) + '/test_helper'

describe Sentry::CommandLine do
  it "should parse english command to authorize with a user and key" do
    cmd = Sentry::CommandLine.new("authorize jonathan with ~/.ssh/id_rsa.pub")
    cmd.options.must_equal ({:action=>"authorize",:user=>"jonathan",:key=>"~/.ssh/id_rsa.pub"})
  end

  it "should parse english command to authorize with a user and key on a remote host" do
    cmd = Sentry::CommandLine.new("authorize jonathan on staging with ~/.ssh/id_rsa.pub")
    cmd.options.must_equal ({:action=>"authorize",:user=>"jonathan",:key=>"~/.ssh/id_rsa.pub", :host => "staging",:remote=>true})
  end

  it "should parse english command to revoke access from a user on a remote host " do
    cmd = Sentry::CommandLine.new("revoke jonathan on staging")
    cmd.options.must_equal ({:action=>"revoke",:user=>"jonathan",:host=>"staging",:remote=>true})
  end

  it "should parse english commands to manage remote hosts" do
    cmd = Sentry::CommandLine.new("manage remote sshuser@sshhost")
    cmd.options.must_equal ({:action=>"manage",:user=>"sshuser",:host=>"sshhost",:remote=>true})
  end

  it "should parse english commands to show the current config" do
    cmd = Sentry::CommandLine.new("show config")
    cmd.options.must_equal ({:action=>"show_config"})
  end

  it "should parse english commands to show the current config on a remote" do
    cmd = Sentry::CommandLine.new("show config on staging")
    cmd.options.must_equal ({:action=>"show_config",:remote=>true,:host=>"staging"})
  end

end
