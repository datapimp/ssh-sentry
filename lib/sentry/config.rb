module Sentry
  class Config
    attr_accessor :hosts

    def initialize options={}
      @hosts = {}
      read_config
    end

    def add_host host_id, config={}
      raise unless config['Hostname']
      @hosts[host_id] = config
    end

    def update_host host_id, setting, value
      @hosts[host_id][ setting ] = value
    end

    def remove_host host_id
      @hosts.delete(host_id)
    end

    def backup
      FileUtils.cp( config_file, original_config ) unless File.exists?(original_config)
    end

    def save
      backup
    end

    private
    
    def original_config
      config_file + '.sentry-original'
    end

    def config_file
      File.join( ENV['HOME'], '.ssh','config')
    end

    def read_config
      host_id = nil
      found_hosts = false
      config_data = IO.read( config_file ) 

      self.hosts = config_data.lines.inject( {} ) do |config, line|
        if line.match /^Host /
          found_hosts = true
          host_id = line.split.last
          config[host_id] ||= {}
        elsif found_hosts and config[host_id]
          entry = line.strip.split
          setting, value = entry
          config[host_id][setting] = value if setting and value
        else
          host_id = nil
        end

        config
      end
    end
  end
end
