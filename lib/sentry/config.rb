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

    def save

    end

    private

    def read_config
      host_id = nil
      found_hosts = false
      config_data = IO.read( File.join( ENV['HOME'], '.ssh','config') )

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
