class DefCache::CacheHandler::MethodOptions

  delegate :lookup_store, to: ActiveSupport::Cache

  attr_reader :cache_options, :cache_options, :method, :cache_method, :miss_method, :cache_store, :keys

  def initialize(method, options = {})
    cached_target, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
    @cache_options             = options.except(:with, :keys)
    @cache_store               = fetch_store options[:with]
    @method                    = method
    @cache_method              = "#{cached_target}_with_cache#{punctuation}"
    @miss_method               = "#{cached_target}_without_cache#{punctuation}"
    @keys                      = Array.wrap(options[:keys]) || []
  end

  private :lookup_store

  def fetch_store(store, options = {})
    (store.is_a?(Symbol) ? lookup_store(store, options) : store) || default_store
  end

  def default_store
    defined?(Rails) ? Rails.cache : ActiveSupport.lookup_store(:memory_store)
  end

end