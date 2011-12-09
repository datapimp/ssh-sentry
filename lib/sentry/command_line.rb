require 'optparse'

module Sentry
  class CommandLine
    BANNER = <<-EOS
Usage sentry [command] [options] 

Examples:

  sentry authorize jonathan on staging with ~/.ssh/id_rsa.pub

  sentry revoke jonathan on staging

  sentry manage remote sshuser@sshhost with ~/.ssh/id_rsa.pub

Options ( for the neckbeards ):
    EOS

    attr_accessor :keystore, :arguments

    GRAMMAR = %w{authorize revoke on with manage remote}

    def initialize arguments=[]
      arguments = arguments.split if arguments.is_a? String
      parse_options arguments

      puts options.inspect
    end
    
    def options
      @options
    end

    def parse_options arguments=[]
      @options = {

      }

      @option_parser = OptionParser.new do |opts|

        opts.on('-a','--authorize','Authorize a user') do |user|
          @options[:action] = "authorize"
          @options[:user] = user
        end

        opts.on('-r','--revoke','Revoke authorization for a user') do |user|
          @options[:action] = "revoke"
          @options[:user] = user
        end

        opts.on('-m','--manage','add a remote sentry to manage') do
          @options[:action] = "manage"
        end

        opts.on('-w','--with','Which with which key') do |key|
          @options[:key] = key
        end

        opts.on('-k','--key','Which with which key') do |key|
          @options[:key] = key
        end

        opts.on('-R','--remote','Which SSH host do you want to connect to') do |host|
          @options[:host] = host
        end

        opts.on('-o','--on','run this action on a remote sentry') do |host|
          @options[:host] = host
        end

        opts.on_tail('-v','--version','display Sentry version') do
          puts "Sentry Version #{Sentry::VERSION}"
          exit
        end
      end

      @option_parser.banner = BANNER
      
      arguments.collect! do |arg|
        GRAMMAR.include?(arg.downcase) ? "--#{ arg.downcase }" : arg
      end

      @option_parser.parse!( arguments )
    end

  end
end
