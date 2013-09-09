module DefCache::ClassMethods

  protected

  # Add method(s) to be cached
  def cache_method(*methods)
    options = methods.extract_options!
    methods.each do |method|
      define_cache_method method, options
    end
  end

  private

  # Define the cache_method
  def define_cache_method(method, options={})
    stub_cache_method_original(method)
    define_cache_handler_method(method, options)
    class_eval <<-RUBY
      def #{method}_with_cache(*args, &block)
        handler = cache_handler_for_#{method}
        handler.cache_store.fetch(handler.cache_key, handler.cache_options) do
          handler.add_reference(handler.cache_key)
          #{method}_without_cache *args, &block
        end
      rescue MethodSource::SourceNotFoundError => e
        warn e
        #{method}_without_cache *args, &block
      end
    RUBY
    alias_method_chain method, :cache
  end

  # Define cache handler method
  def define_cache_handler_method(method, options)
    options = Marshal.dump options
    class_eval <<-RUBY
      def cache_handler_for_#{method}
        @cache_handler_for_#{method} ||= DefCache::CacheHandler.new :#{method}, self, Marshal.load("#{options}")
      end
    RUBY
  end

  # Define an empty method to avoid alias method chain errors
  def stub_cache_method_original(method)
    class_eval <<-RUBY
      def #{method}
        raise NoMethodError, "undefined method `#{method}' for #{self}"
      end unless method_defined? :#{method}
    RUBY
  end

  # Relink the original method if it is redefined
  def method_added(method)
    if !cached_methods_just_added.delete(method) && method_defined?("#{method}_with_cache")
      alias_method "#{method}_without_cache", method
      cached_methods_just_added << method
      alias_method method, "#{method}_with_cache"
    end
    super
  rescue NoMethodError
    nil
  end

  # A collection for just added methods
  def cached_methods_just_added
    @cached_methods_added ||= []
  end

end