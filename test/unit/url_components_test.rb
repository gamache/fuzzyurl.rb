require 'test_helper'

describe FuzzyURL::URLComponents do
  describe '#[]' do
    it 'rejects bad keys' do
      assert_raises(ArgumentError) { FuzzyURL.new['bad'] }
      assert_raises(ArgumentError) { FuzzyURL.new['bad'] = 1 }
      assert_raises(NoMethodError) { FuzzyURL.new.bad }
      assert_raises(NoMethodError) { FuzzyURL.new.bad = 1 }
    end

    it 'symbolizes keys' do
      fu = FuzzyURL.new({})
      fu['hostname'] = 'example.com'
      fu.hostname.must_equal 'example.com'
    end
  end

end

