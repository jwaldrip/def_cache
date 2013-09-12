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
    define_cache_with_method(method)
    cached_methods_just_added << method
    alias_method_chain method, :cache
  end

  # Define cache with method
  def define_cache_with_method(method)
    target, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
    class_eval <<-RUBY
      def #{target}_with_cache#{punctuation}(*args, &block)
        handler = cache_handler_for_#{method}
        handler.cache_store.fetch(handler.cache_key, handler.cache_options) do
          handler.add_reference(handler.cache_key)
          #{target}_without_cache#{punctuation} *args, &block
        end
      rescue MethodSource::SourceNotFoundError => e
        warn e
        #{target}_without_cache#{punctuation} *args, &block
      end unless method_defined? :#{target}_with_cache#{punctuation}
    RUBY
  end

  # Define cache handler method
  def define_cache_handler_method(method, options = {})
    define_method "cache_handler_for_#{method}" do
      eval <<-RUBY
        @cache_handler_for_#{method} ||= DefCache::CacheHandler.new(:#{method}, self, options)
      RUBY
    end unless method_defined? "cache_handler_for_#{method}"
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
    define_cache_method(method) if !cached_methods_just_added.delete(method) && method_defined?("#{method}_with_cache")
    super
  end

  # A collection for just added methods
  def cached_methods_just_added
    @cached_methods_added ||= []
  end

end