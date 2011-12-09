module Sentry
  class Remote
    attr_accessor :host

    def initialize options={}
      @host = options[:host]
    end
  end
end
