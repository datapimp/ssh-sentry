require File.dirname(__FILE__) + '/test_helper'

describe Sentry::CommandLine do
  
  describe "The English Interface" do
    it "allows me to authorize users with their key" do
      cmd = Sentry::CommandLine.new("authorize jonathan with ~/.ssh/id_rsa.pub")
      cmd.options.must_equal ({:action=>"authorize",:user=>"jonathan",:key=>"~/.ssh/id_rsa.pub"})
    end

    it "allows me to authorize a user on a remote host with their key" do
      cmd = Sentry::CommandLine.new("authorize jonathan on staging with ~/.ssh/id_rsa.pub")
      cmd.options.must_equal ({:action=>"authorize",:user=>"jonathan",:key=>"~/.ssh/id_rsa.pub", :host => "staging",:remote=>true})
    end

    it "revokes access from users on remote hosts" do
      cmd = Sentry::CommandLine.new("revoke jonathan on staging")
      cmd.options.must_equal ({:action=>"revoke",:user=>"jonathan",:host=>"staging",:remote=>true})
    end

    it "installs itself on remote hosts" do
      cmd = Sentry::CommandLine.new("install on sshuser@sshhost")
      cmd.options.must_equal ({:action=>"install",:ssh_user=>"sshuser",:host=>"sshhost",:remote=>true})
    end
  end
end
