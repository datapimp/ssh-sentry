module Sentry
  class Remote
    attr_accessor :host

    def initialize options={}
      @host = options[:host]
			@ssh_user = options[:ssh_user]
    end
  end
end
