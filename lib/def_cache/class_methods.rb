require 'set'

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
    __cached_methods__ << method.to_sym
    stub_cache_method_original(method)
    define_cache_handler_method(method, options)
    define_cache_with_method(method)
    alias_method_chain method, :cache
  end

  # Define cache with method
  def define_cache_with_method(method)
    target, punctuation = method.to_s.sub(/([?!=])$/, ''), $1
    raise PunctuationError, 'methods ending in `=` cannot be cached.' if punctuation == '='
    class_eval <<-RUBY
      def #{target}_with_cache#{punctuation}(*args, &block)
        handler = cache_handler_for_#{method}
        handler.cache_store.fetch(handler.cache_key, handler.cache_options) do
          handler.add_reference(handler.cache_key)
          #{target}_without_cache#{punctuation}(*args, &block)
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
    if __cached_methods__.include? method.to_sym
      define_cache_method(method) unless caller.any? { |files| files.include? __FILE__ }
    end
    super
  end

  def __cached_methods__
    @__cached_methods__ ||= Set.new
  end

end
