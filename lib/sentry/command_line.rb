require 'optparse'

module Sentry
  class CommandLine
    BANNER = <<-EOS
Usage sentry [command] [options] 

Options:
  EOS
      
    attr_accessor :keystore

    def initialize
      parse_options

      @keystore = Sentry::Keystore.new( @options )
    end


    def parse_options
      @options = {
      }

      @option_parser = OptionParser.new do |opts|
        opts.on_tail('-v','--version','display Sidecar version') do
          puts "Sentry Version #{Sentry::VERSION}"
          exit
        end
      end
      
      arguments = ARGV.dup
      
      @option_parser.banner = BANNER
      @option_parser.parse!(arguments)
    end
  end
end
