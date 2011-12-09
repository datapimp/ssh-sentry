require 'optparse'

module Sentry
  class CommandLine
    BANNER = <<-EOS
Usage sentry [command] [options] 

Examples:

To initialize sentry on a server:

  sentry start from ~/.ssh/authorized_keys

To add or remove users from a host:

  sentry authorize jonathan on staging with ~/.ssh/id_rsa.pub

  sentry revoke jonathan on staging

To manage a remote ssh box with sentry:

  sentry manage remote sshuser@sshhost with ~/.ssh/id_rsa.pub

Options ( for the neckbeards ):
    EOS

    attr_accessor :keystore, :arguments

    GRAMMAR = %w{authorize revoke on with manage remote}

    def initialize arguments=[]
      arguments = arguments.split if arguments.is_a? String
      parse_options arguments
      
      if !@options[:action]
        @keystore = Sentry::Keystore.new( @options )
        @keystore.send( @options.delete(:action), @options )
      end
    end
    
    def options
      @options
    end

    def parse_options arguments=[]
      @options = {

      }

      @option_parser = OptionParser.new do |opts|
        
        opts.on('-s','--start','Initialize sentry from an existing authorized keys file') do |s|
          @options[:action] = "start"
        end

        opts.on('-c','--config FILE','Path to sentry.keystore DEFAULT: ~/.ssh/sentry.keystore') do |c|
          @options[:config_file] = c
        end

        opts.on('-a','--authorize USER','Authorize a user') do |user,val|
          @options[:action] = "authorize"
          @options[:user] = user
        end

        opts.on('-r','--revoke USER','Revoke authorization for a user') do |user|
          @options[:action] = "revoke"
          @options[:user] = user
        end

        opts.on('-m','--manage','add a remote sentry to manage') do |m|
          @options[:action] = "manage" if m
        end

        opts.on('-w','--with KEY','Which with which key') do |key|
          @options[:key] = key
        end

        opts.on('-R','--remote SSH_HOST','Which SSH host do you want to connect to') do |host|
          @options[:host] = host
        end

        opts.on('-o','--on SSH_HOST','run this action on a remote sentry') do |host|
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
