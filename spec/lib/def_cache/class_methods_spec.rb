require 'spec_helper'

describe DefCache::ClassMethods do

  subject(:klass) { stub_const 'SampleClass', Class.new { extend DefCache::ClassMethods } }

  describe '.cache_method' do
    it 'should call .define_cache_method for each method with the passed options' do
      methods = [:foo, :bar, :baz]
      options = { option: :value }
      methods.each do |method|
        expect(klass).to receive(:define_cache_method).with(method, options)
      end
      klass.send :cache_method, *methods, options
    end
  end

  describe '.define_cache_method' do
    it 'should call .stub_cache_method_original with the method' do
      expect(klass).to receive(:stub_cache_method_original).at_least(:once).with(:foo).and_call_original
      klass.send :define_cache_method, :foo
    end

    it 'should call .define_cache_handler_method with the method' do
      options = { option: :value }
      expect(klass).to receive(:define_cache_handler_method).at_least(:once).with(:foo, options).and_call_original
      klass.send :define_cache_handler_method, :foo, options
    end

    it 'should call .define_cache_with_method' do
      expect(klass).to receive(:define_cache_with_method).at_least(:once).with(:foo).and_call_original
      klass.send :define_cache_method, :foo
    end

    it 'should call alias_method_chain with the method and :cache' do
      expect(klass).to receive(:alias_method_chain).at_least(:once).with(:foo, :cache).and_call_original
      klass.send :define_cache_method, :foo
    end
  end

  describe '.define_cache_with_method' do
    it 'should define the cache with method' do
      expect(klass).to receive(:method_added).with(:foo_with_cache)
      klass.send :define_cache_with_method, :foo
    end

    context 'if the method is already defined' do
      it 'should not define the method' do
        klass.send(:define_method, :foo_with_cache) { 'value' }
        expect(klass).to_not receive(:method_added).with(:foo_with_cache)
        klass.send :define_cache_with_method, :foo
      end
    end
  end

  describe '#cache_with_method' do
    let(:instance) { klass.new }

    before(:each) do
      klass.send :cache_method, :foo, with: :memory_store, logger: Logger.new('/dev/null')
    end

    it 'should cache miss once' do
      expect(instance).to receive(:foo_without_cache).exactly(:once)
      2.times { instance.foo }
    end
  end

  describe '.define_cache_handler_method' do
    it 'should define the cache handler method' do
      expect(klass).to receive(:method_added).with(:cache_handler_for_foo)
      klass.send :define_cache_handler_method, :foo
    end

    it 'should create a cache handler with the proper options' do
      options = { foo: :bar }
      klass.send :define_cache_handler_method, :foo, options
      instance = klass.new
      expect(DefCache::CacheHandler).to receive(:new).with :foo, instance, options
      instance.cache_handler_for_foo
    end

    it 'should define a method that returns a cache handler' do
      options = { foo: :bar }
      klass.send :define_cache_handler_method, :foo, options
      instance = klass.new
      handler = instance.cache_handler_for_foo
      handler.should be_a DefCache::CacheHandler
      handler.instance.should eq instance
      handler.cache_options.should eq options
    end

    context 'if the method is already defined' do
      it 'should not define the method' do
        klass.send(:define_method, :cache_handler_for_foo) { 'value' }
        expect(klass).to_not receive(:method_added).with(:cache_handler_for_foo)
        klass.send :define_cache_handler_method, :foo
      end
    end
  end

  describe '.stub_cache_method_original' do
    it 'should stub the original method' do
      expect(klass).to receive(:method_added).with(:foo)
      klass.send :stub_cache_method_original, :foo
    end

    it 'should define a method that raises an error' do
      klass.send :stub_cache_method_original, :foo
      expect { klass.new.foo }.to raise_error NoMethodError
    end

    context 'if the method is already defined' do
      it 'should not stub the method' do
        klass.send(:define_method, :foo) { 'value' }
        expect(klass).to_not receive(:method_added).with(:foo)
        klass.send :stub_cache_method_original, :foo
      end
    end
  end

end
