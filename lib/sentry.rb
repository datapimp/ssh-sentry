require 'net/ssh'

module Sentry
  VERSION = "0.0.1"

  autoload :CommandLine,  'sentry/command_line'
  autoload :Keystore,     'sentry/keystore'
  autoload :Config,       'sentry/config'
end
