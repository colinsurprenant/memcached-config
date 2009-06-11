# A memcache.yml cache_fu/acts_as_memcached config file parser. 
# The options attribute contains the config hash which can be used to
# initialize a memcache client.
#
# Author: Colin Surprenant, colin.surprenant@praizedmedia.com, http://github.com/colinsurprenant/, @colinsurprenant on Twitter
#
class MemcachedConfig
  
  attr_reader :options
  
  # Creates a new MemcachedConfig object. append_rails_env controls wether the current 
  # RAILS_ENV should be appended to the configured namespace
  def initialize(append_rails_env = true)
    @options = MemcachedConfig.read_yaml
    @append_rails_env = append_rails_env
  end
  
  def disabled?
    @options[:disabled]
  end
  
  private
  
  def self.read_yaml
    memcached_config_file = File.join(RAILS_ROOT, 'config', 'memcached.yml')
    raise("cannot read #{memcached_config_file}") unless File.exists? memcached_config_file
    
    memcached_config = YAML.load(ERB.new(IO.read(memcached_config_file)).result)
    raise("cannot load #{memcached_config_file}") unless memcached_config
    
    # merge defaults options with RAILS_ENV specific options
    memcached_env_config = memcached_config['defaults'] || {}
    memcached_env_config.merge!(memcached_config[RAILS_ENV]) if memcached_config[RAILS_ENV].is_a?(Hash)
    memcached_env_config.symbolize_keys!
    memcached_env_config[:namespace] << "-#{RAILS_ENV}" if memcached_env_config.has_key?(:namespace) && @append_rails_env
    
    return memcached_env_config
  end
end