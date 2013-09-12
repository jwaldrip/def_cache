require 'spec_helper'

describe DefCache::CacheHandler do

  let(:method_name){ nil }
  let(:options){{}}
  let(:klass){ stub_const 'SampleClass', Class.new { include DefCache } }
  let(:instance){ klass.new }
  before(:each){ klass.send(:cache_method, method_name) if method_name }
  subject(:handler){ DefCache::CacheHandler.new(method_name, instance, options) }

  describe '.new' do
    context 'with defaults' do
      let(:method_name){ :foo! }
      let(:options){ { foo: :bar, baz: :raz } }

      its(:cache_options){ should eq options.except(:with, :keys) }
      its(:cache_store){ should be_a ActiveSupport::Cache::Store }
      its(:miss_method){ should eq 'foo_without_cache!' }
      its(:method_name){ should eq method_name }
      its(:keys){ should be_empty }
      its(:instance){ should eq instance }
    end
  end

  describe '#cache_key' do
    let(:method_name){ :raz }
    let(:keys){ [:foo, :bar, :baz] }
    let(:options){ { keys: keys } }
    before(:each) { keys.each { |key| allow(instance).to receive(key).and_return(SecureRandom.hex) } }

    it 'should call each key on the instance' do
      keys.each { |key| expect(instance).to receive(key) }
      handler.cache_key
    end

    it 'should return the proper key' do
      handler.cache_key(:test).should eq [klass.name, *keys.map { |k| instance.send(k) }, method_name, :test].join('/')
    end

  end

  describe '#instance_method' do
    let(:method_name){ :foo }
    it 'should be the proper method' do
      handler.instance_method.should be_a Method
      handler.instance_method.name.should eq :foo_without_cache
    end
  end

  describe '#instance_cache_key' do
    pending
  end

  describe '#logger' do
    pending
  end

  describe '#method_cache_key' do
    pending
  end

  describe '#index_cache_key' do
    pending
  end

  describe '#index' do
    pending
  end

  describe '#remove_reference' do
    pending
  end

  describe '#add_reference' do
    pending
  end

  describe '#flush!' do
    pending
  end

  describe '#fetch_store' do
    pending
  end

  describe '#default_store' do
    pending
  end

  describe '#req_parameter_key' do
    pending
  end

  describe '#opt_parameter_key' do
    pending
  end

  describe '#rest_parameter_key' do
    pending
  end

  describe '#block_parameter_key' do
    pending
  end

end