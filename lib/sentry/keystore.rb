require 'json'

module Sentry
  class Keystore
    attr_accessor :storage, :options, :users

    def initialize options={}
      @options = options
      @storage = {}
      @users = {}
    end
    
    # add a user to the key store
    def authorize options={}
      user = options[:user]
      key_contents = options[:key] || options[:with]
      key_contents = IO.read( key_contents ) if File.exists?( key_contents )
      
      key_id = add_key(key_contents)
      associate_key_with_user( key_id, user ) unless user.nil?
    end

    # revoke a users access from the key store
    def revoke options={}

    end

    private

    def associate_key_with_user key_id, user
      @users[ user ] ||= []
      @users[ user ] << key_id
    end

    def add_key name, data=nil
      # allow to pass a ssh key using its machine name as the key name
      if data.nil?
        name, data = name.split(' ').reverse
      end

      if storage[name].nil?
        storage[name] = data
      else
        id = name.split(/:/).last.to_i

        name = id > 0 ? name.gsub!(/:\d+$/, ":#{id + 1}") : "#{ name }:1"
        
        add_key(name, data)
      end
      
      find_key_name(data)
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
    
    def save_config
      File.open(keystore_config_location,'w+') {|fh| fh.puts to_json }
    end

    def load_config from=nil
      from ||= keystore_config_location
      data = JSON.parse( File.exists?(from) ? IO.read(from) : from  )
      raise "Invalid Import Data" unless data.is_a?(Hash) and @storage = data.delete('storage') and @users = data.delete('users')
    end

    def update_authorize_keys
      File.open(authorized_keys_file,'w+') {|fh| fh.puts to_keys_file }
    end

    def to_keys_file
      storage.values.join("\n")
    end

    def to_json
      require 'json'
      JSON.generate( to_keystore ) 
    end

    def to_keystore
      {"storage"=>storage,"users"=>users}
    end
      
    def keystore_config_location
      options[:config_location] || File.join( ENV['HOME'], '.ssh', 'sentry.keystore')
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

    def authorized_keys_file
      options[:authorized_keys_file] || File.join( ENV['HOME'], '.ssh', 'authorized_keys' )
    end
  end
end
