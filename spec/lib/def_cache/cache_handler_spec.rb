require 'spec_helper'

describe DefCache::CacheHandler do

  let(:method_name){ nil }
  let(:options){{}}
  let(:klass){ stub_const 'SampleClass', Class.new { include DefCache } }
  let(:instance){ klass.new }
  let(:subject){ DefCache::CacheHandler.new(method_name, instance, options) }

  subject(:instance){ klass.new }

end