require 'spec_helper'

describe DefCache do

  let(:klass){ stub_const 'SampleClass', Class.new { include DefCache } }
  subject(:instance){ klass.new }

  describe '#flush_method_cache!' do
    before do
      klass.send :cache_method, :foo, :bar
    end

    it 'should call flush on the handlers' do
      [:foo, :bar].each do |m|
        expect(instance.send "cache_handler_for_#{m}").to receive(:flush!)
      end
      instance.flush_method_cache!
    end
  end

end