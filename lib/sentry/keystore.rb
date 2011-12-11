require 'json'

module Sentry
  class Keystore
    attr_accessor :storage, :options, :users, :ssh_config

    def initialize options={}
      @options = options
      @storage = {}
      @ssh_config = Sentry::Config.new()
      @users = {}

      puts "Initializing Keystore With #{ options }" if debug?

      load_config unless options[:action] == "install"
    end
    
    # add a user to the key store
    def authorize options={}
      user = options[:user] || `whoami`

      key_contents = options[:key] || options[:with]
      key_contents = IO.read( key_contents ) if File.exists?( key_contents )

      name = key_contents.split.last  
      key_id = add_key(name, key_contents)

      associate_key_with_user( key_id, user )
      
      puts "Authorized #{ key_id } from #{ user }" if debug?

      save_config
    end

    # revoke a users access from the key store
    def revoke options={}
      user = options[:user] || `whoami` 

      if(options[:key] || options[:with] || options[:using])
      
      else
        key_ids = users.delete( user )
        key_ids.each {|key_id| storage.delete(key_id)}
      end

      save_config
    end
  
    def uninstall options={}
      restore_authorized_keys
      ssh_config.restore
    end

    def install options={}
      backup_authorized_keys
      ssh_config.backup

      options[:from] ||= File.join( ENV['HOME'], '.ssh', 'authorized_keys' ) 

      File.open( send(:keystore_config_location), 'w+' ) {|fh| fh.puts JSON.generate(default_config) }
      
      IO.read( send :authorized_keys_file ).lines.each do |key|
        authorize(:user=>`whoami`, :key => key)
      end
    end

    def show_config options={}
      @users.each do |user, key_ids|
        puts "keys for user: #{ user }"
        key_ids.each do |key_id| 
          puts "  --"
          puts "    id: #{ key_id}"
          puts "    contents: #{ storage[key_id] }"
          puts "  --"
        end
      end
    end

    private

    def debug?
      options[:debug]
    end

    def restore_authorized_keys
      require 'fileutils'
      backup = send(:authorized_keys_file) + '.sentry-original'
      FileUtils.cp(backup,send(:authorized_keys_file))
    end

    def backup_authorized_keys
      require 'fileutils'
      backup = send(:authorized_keys_file) + '.sentry-original'
      FileUtils.cp( send(:authorized_keys_file), backup ) unless File.exists?(backup)
    end
    
    def key_ids_for_user user
      @users[ user ] 
    end

    def associate_key_with_user key_id, user
      user = user.chomp

      @users[ user ] ||= []
      @users[ user ] << key_id unless @users[user].include? key_id
    end

    def add_key name, data=nil
      # allow a user to pass a path to a public key
      if data and File.exists?(data)
        data = IO.read(data)
      end

      # allow to pass a ssh key as a complete string
      if data.nil?
        data = name
        name = data.split.last
      end

      # if it already exists, don't mess with it
      return name if storage[name] == data

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
      update_authorized_keys
    end

    def load_config from=nil

      unless File.exists?( keystore_config_location )
        puts "Sentry has not been configured on this machine. type 'sentry install'" 
        exit
      end

      if !from
        from = IO.read( keystore_config_location )
      end

      data = JSON.parse( from ) rescue default_config 

      raise "Invalid Import Data" unless data.is_a?(Hash) and @storage = data.delete('storage') and @users = data.delete('users')
    end

    def default_config
      {"storage"=>{}, "users"=>{} }
    end

    def update_authorized_keys
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
      options[:config_file] || File.join( ENV['HOME'], '.ssh', 'sentry.keystore')
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
