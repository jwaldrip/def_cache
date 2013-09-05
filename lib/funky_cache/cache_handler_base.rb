class FunkyCache::CacheHandlerBase

  inherited_attribute :cache_store, :_cache_keys, :logger, :_cached_methods_with_options

  # Class methods

  class << self

    delegate :lookup_store, to: ActiveSupport::Cache
    alias base parent

    def cached_methods_with_options
      superclass_cached_methods = superclass.method_defined?(:cached_methods_with_options) ? superclass.cached_methods_with_options : {}
      _cached_methods_with_options.merge superclass_cached_methods
    end

    def cached_methods
      cached_methods_with_options.keys
    end

    def cache_store=(store, options={})
      store        = lookup_store(store, options) if store.is_a? Symbol
      @cache_store = store
    end

    def define_cache_method(method, options)
      register_cache_method method, options
      options = options_for_method method
      base.send(:define_method, options[:cached_method]) do |*args, &block|
        cache_handler.fetch_cache_method(method, *args, &block)
      end

      # Chain the uncached method
      base.alias_method_chain method, :cache
    end

    # Options for a single method
    def options_for_method(method)
      cached_methods_with_options[method]
    end

    # The cache class for a given method
    def cache_store_for_method(method)
      options_for_method(method)[:with] || cache_store
    end

    private

    # Register a cache method
    def register_cache_method(method, options={})
      cached_target, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
      options[:original_method]  = method
      options[:cached_method]    = "#{cached_target}_with_cache#{punctuation}"
      options[:miss_method]      = "#{cached_target}_without_cache#{punctuation}"
      options[:with]             = lookup_store(store, options) if options[:with].is_a? Symbol
      _cached_methods_with_options.merge! method => options
    end

  end

  # Attrs
  attr_reader :instance
  self._cached_methods_with_options = {}
  self._cache_keys                  = []
  self.cache_store                  = defined?(Rails) ? Rails.cache : :memory_store
  self.logger                       = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)

  # Delegations
  delegate :options_for_method, :cache_store_for_method, to: :class

  # Instance Methods

  def initialize(instance)
    @instance = instance
  end

  def cache_key(*args)
    values = self._cache_keys.map { |key| instance.send(key) || '*' }
    ([instance.cache_key] + values + args).select(&:present?).join('/')
  end

  def clear_all_references!
    self.class.cached_methods.each do |method|
      # Cache Class
      cache_store = cache_store_for_method(method)

      # Cache Key
      index_key   = index_key_for_method(method)

      # Clear each subkey in the index key
      return unless (index = cache_store.read(index_key) || []).present?
      index.each do |subkey|
        Rails.logger.info "removing cache ref: #{subkey}"
        cache_store.delete subkey
      end

      # Clear the index key
      Rails.logger.info "removing cache ref index: #{index_key}"
      cache_store.delete index_key
    end

  end

  def fetch_cache_method(method, *args)
    # Fetch the options
    options = options_for_method method

    # Return if a block is given
    return instance.send(options[:miss_method]) if block_given?

    # Register a method call
    add_reference(method, *args)

    # Load the cache class
    cache_store = cache_store_for_method(method)

    # Do the cache fetch
    cache_store.fetch(method_cache_key method, *args) do
      instance.send(options[:miss_method])
    end
  end

  def method_cache_key(method, *args)
    args = instance.method(method).parameters.each_with_index.map do |arg, i|
      "#{arg.last}=#{args[i].inspect}"
    end
    cache_key("#{method}(#{args.join(',')})")
  end

  private

  def add_reference(method, *args)
    # Cache Class
    cache_store = cache_store_for_method(method)

    # Cache Keys
    index_key   = index_key_for_method(method)
    call_key    = self.method_cache_key(method, *args)

    # Update the index
    index       = cache_store.read(index_key) || []
    unless index.include? call_key
      Rails.logger.info "adding cache ref: #{call_key}"
      index << call_key
      cache_store.write index_key, index
    end
  end

  def index_key_for_method(method)
    self.cache_key('index_reference', method)
  end

end