require "def_cache/version"
require "core_ext/class"
require "active_support/all"

module DefCache
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :ClassMethods
  autoload :CacheHandlerBase

  included do
    setup_for_caching!
  end

  def cache_handler
    @cache_handler ||= self.class.cache_handler.new self
  end

  def flush_cache!
    cache_handler.clear_all_references!
  end

end
