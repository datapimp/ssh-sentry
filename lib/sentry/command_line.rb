require 'optparse'

module Sentry
  class CommandLine
    BANNER = <<-EOS
English, motherfucker.  Do you speak it?

  sentry install yourself on staging
  sentry authorize jonathan on staging using ~/.ssh/id_rsa.pub
  sentry revoke access from jonathan on staging
  sentry revoke access from anyone using ~/.ssh/expired_rsa_key.pub
  sentry show config on staging
  sentry show users on staging 
  sentry show keys for jonathan on staging

Commands:

authorize, revoke a USER 

install, manage 

show config

Options:

with a KEYFILE
for a USER
on a HOST

English gets translated into options:
    EOS

    attr_accessor :keystore, :arguments

    GRAMMAR = %w{authorize revoke on with manage remote show using for install}

    def initialize arguments=[]
      arguments = arguments.split if arguments.is_a? String
      parse_options arguments
      
      if !@options[:action]
        puts @option_parser.banner
        exit
      end
    end

    def run
      @keystore = Sentry::Keystore.new( @options )
      @keystore.send( @options[:action], @options )
    end
    
    def options
      @options
    end

    def parse_options arguments=[]
      @options = {}

      @option_parser = OptionParser.new do |opts|
        opts.separator ""
        opts.separator "Actions:"

        opts.on("-i",'--install','Initialize sentry from an existing authorized keys file') do |s|
          @options[:action] = "install"
        end

        opts.on("-a",'--authorize USER','Authorize a user') do |user,val|
          @options[:action] = "authorize"
          @options[:user] = user
        end

        opts.on("-r",'--revoke USER','Revoke a users keys from the authorized list') do |user|
          @options[:action] = "revoke"
          @options[:user] = user
        end

        opts.on("-s",'--show SETTING','Show config setting, default is to show full config') do |value|
          if value
            @options[:action] = "show_config"
            @options[:setting] = value
          end
        end
        
        opts.separator ""
        opts.separator "Parameters:"

        opts.on("-f",'--for USER','Do something for a user.') do |u|
          @options[:user] = u
        end

        opts.on("-w",'--with PATH','With a file.  Usually a public key, sometimes a config file') do |key|
          @options[:key] = key
        end

        opts.on("-R",'--remote SSH_HOST','Which SSH host do you want to connect to') do |host|
          if host
            @options[:remote] = true
            @options[:host] = host
          end

          if host and parts = host.split('@') and parts.length > 1
            @options[:host]     = parts.pop
            @options[:ssh_user] = parts.pop
          end
        end

        opts.on("-o",'--on SSH_HOST','run this action on a remote sentry') do |host|
          
          if host
            @options[:remote] = true
            @options[:host] = host
          end

          if host and parts = host.split('@') and parts.length > 1
            @options[:host]     = parts.pop
            @options[:ssh_user] = parts.pop
          end
        end

        opts.separator ""
        opts.separator "Common Options:"
        
        opts.on('-D','--debug') do |d|
          @options[:debug] = true if d
        end
        
        opts.on_tail("-h","--help",'You are looking at it') do
          puts opts
          exit
        end

        opts.on_tail('-v','--version','display Sentry version') do
          puts "Sentry Version #{ Sentry::VERSION }"
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
