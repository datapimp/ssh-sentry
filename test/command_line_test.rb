require File.dirname(__FILE__) + '/test_helper'

describe Sentry::CommandLine do
  it "should english motherfucker, do you speak it?" do
    @cmd = Sentry::CommandLine.new("authorize jonathan with ~/.ssh/id_rsa.pub")
  end
end
