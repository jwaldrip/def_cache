require "def_cache/version"
require "active_support/all"

module DefCache
  extend ActiveSupport::Concern
  extend ActiveSupport::Autoload

  autoload :ClassMethods
  autoload :CacheHandler

  def flush_method_cache!
    methods.select { |m| m.to_s.include? 'cache_handler_for_' }.each { |m| send(m).flush! }
  end

end