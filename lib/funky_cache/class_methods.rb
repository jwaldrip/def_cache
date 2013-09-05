module FunkyCache::ClassMethods

  def inherited(subclass)
    subclass.setup_for_caching!
    super
  end

  def setup_for_caching!
    # Copy the superclass handler
    base_handler   = superclass.instance_variable_get(:@cache_handler) || FunkyCache::CacheHandlerBase
    @cache_handler = const_set :CacheHandler, Class.new(base_handler)
  end

  def cache_handler
    @cache_handler
  end

  private

  def cache_method(method, options = {})
    cache_handler.define_cache_method method, options
  end

  def cache_with(sym, options={})
    cache_handler.cache_store = sym, options
  end

  def cache_keys(*keys)
    cache_handler._cache_keys += keys
  end

end