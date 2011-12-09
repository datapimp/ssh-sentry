require 'json'

module Sentry
  class Keystore
    attr_accessor :keys, :storage, :options

    def initialize options={}
      @options = options
      @storage = {}

      build_keystore
    end

    def add_key name, data
      if storage[name].nil?
        storage[name] = data
      else
        id = name.split(/:/).last.to_i

        name = id > 0 ? name.gsub!(/:\d+$/, ":#{id + 1}") : "#{ name }:1"
        
        add_key(name, data)
      end
    end
    
    # deletes a key by its name, or by the value of the key
    def remove_keys names=[] 
      [names].flatten.select do |name_or_value|
        storage.delete(name_or_value) || storage.delete( find_key_name(name_or_value) )
      end.length
    end
    
    # removes a key by the machine id, e.g. jonathan@thinktank
    # useful for when there are multiple keys for a machine
    def remove_by_machine machine  
      remove_keys storage.keys.select {|key| key.downcase.include?( machine.downcase ) }
    end
    
    def export
      File.open(export_location,'w+') {|fh| fh.puts( to_json) }
    end

    def import from
      data = JSON.parse( File.exists?(from) ? IO.read(from) : from  )
      raise "Invalid Import Data" unless data.is_a?(Hash)
      @storage = data
    end

    private

    def to_json
      require 'json'
      JSON.generate( storage ) 
    end

    def export_location
      options[:export_location] || File.join( ENV['HOME'], '.ssh', 'sentry.keystore')
    end

    def find_key_name needle
      storage.keys.detect {|key| storage[key] == needle }
    end
   
    def keystore
      self
    end

    def my
      self
    end

    def build_keystore
      read_authorized_keys!
      keys.each do |key|
        name = key.split(' ').last
        keystore.add_key(name, key)
      end
    end

    def read_authorized_keys!
      @keys = IO.read( authorized_keys_file ).lines.to_a.map(&:chomp)
    end

    def authorized_keys_file
      options[:authorized_keys_file] || File.join( ENV['HOME'], '.ssh', 'authorized_keys' )
    end
  end
end
