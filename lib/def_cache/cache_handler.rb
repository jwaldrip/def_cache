class DefCache::CacheHandler

  delegate :lookup_store, to: ActiveSupport::Cache
  attr_reader :method, :instance, :keys, :cache_store, :cache_options

  def initialize(method, instance, options={})
    cached_target, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
    @cache_options             = options.except(:with, :keys)
    @logger                    = options[:logger]
    @cache_store               = fetch_store options[:with]
    @method                    = instance.method(method)
    @cache_method              = "#{cached_target}_with_cache#{punctuation}"
    @miss_method               = "#{cached_target}_without_cache#{punctuation}"
    @keys                      = Array.wrap(options[:keys]) || []
    @instance                  = instance
  end

  def cache_key(*values)
    keys.map { |key| instance.send(key) || '*' }
    [instance_cache_key, method.name, keys, values].flatten.select(&:present?).join('/')
  end

  def instance_cache_key
    instance.cache_key
  rescue NoMethodError
    instance.class.name
  end

  def logger
    @logger ||= defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  end

  def method_cache_key(*args, &block)
    params = method.parameters.each_with_index do |(req, param), n|
      send "#{req}_parameter_key", param, args[n], &block
    end.compact.join(',')
    cache_key *params
  end

  def index_cache_key
    cache_key(:__index__)
  end

  def index
    cache_store.fetch(index_cache_key){[]}
  end

  def remove_reference(cache_key)
    new_index = index.delete(cache_key)
    cache_store.write index_cache_key, new_index
  end

  def add_reference(cache_key)
    unless index.include? cache_key
      logger.info "adding cache ref: #{cache_key}"
      new_index = index << cache_key
      cache_store.write index_cache_key, new_index
    end
  end

  def flush!
    index.each do |subkey|
      logger.info "removing cache ref: #{subkey}"
      cache_store.delete subkey
      remove_reference subkey
    end
  end

  private :lookup_store

  def fetch_store(store, options = {})
    (store.is_a?(Symbol) ? lookup_store(store, options) : store) || default_store
  end

  def default_store
    defined?(Rails) ? Rails.cache : ActiveSupport::Cache.lookup_store(:memory_store)
  end

  def req_parameter_key(param, value)
    "#{param}=#{value.inspect}"
  end

  def opt_parameter_key(param, value)
    "#{param}=#{value.inspect}" if value.present?
  end

  def rest_parameter_key(param, values)
    "*#{param}=#{values.map(&:inspect)}" if values.present?
  end

  def block_parameter_key(param, value, &block)
    "&#{param}(#{Digest::MD5.hexdigest(block.source)})" if block_given?
  end

end
