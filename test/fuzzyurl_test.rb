require 'test_helper'

describe Fuzzyurl do
  describe 'class methods' do
    describe 'new' do
      it 'accepts strings or hashes' do
        assert_equal(Fuzzyurl.new('example.com:80'),
                     Fuzzyurl.new(hostname: 'example.com', port: '80'))
      end
    end

    describe 'mask' do
      it 'accepts strings or hashes' do
        assert_equal(Fuzzyurl.mask('example.com:80'),
                     Fuzzyurl.mask(hostname: 'example.com', port: '80'))
      end
    end

    describe 'to_string' do
      it 'is delegated' do
        assert_equal('example.com',
                     Fuzzyurl.to_string(Fuzzyurl.new(hostname: 'example.com')))
      end
    end

    describe 'from_string' do
      it 'is delegated' do
        assert_equal(Fuzzyurl.new(hostname: 'example.com'),
                     Fuzzyurl.from_string('example.com'))
      end
    end

    describe 'match' do
      it 'accepts strings or Fuzzyurls' do
        assert_equal(0, Fuzzyurl.match(Fuzzyurl.mask, 'example.com'))
      end
    end

    describe 'matches?' do
      it 'accepts strings or Fuzzyurls' do
        assert(Fuzzyurl.matches?(Fuzzyurl.mask, 'example.com'))
      end
    end

    describe 'match_scores' do
      it 'accepts strings or Fuzzyurls' do
        scores = Fuzzyurl.match_scores(Fuzzyurl.mask, 'example.com')
        assert_equal(8, scores.count)
        assert_equal(0, scores.values.reduce(:+))
      end
    end

    describe 'best_match_index' do
      it 'accepts strings or Fuzzyurls' do
        assert_equal(1, Fuzzyurl.best_match_index(
                          [Fuzzyurl.mask, 'example.com:80', 'example.com'],
                          'http://example.com'
        ))
      end
    end

    describe 'best_match' do
      it 'returns the input object, not always a Fuzzyurl' do
        assert_equal('example.com:80', Fuzzyurl.best_match(
                                         [Fuzzyurl.mask, 'example.com:80', 'example.com'],
                                         'http://example.com'
        ))
      end
    end

    describe 'fuzzy_match' do
      it 'is delegated' do
        assert_equal(1, Fuzzyurl.fuzzy_match('a', 'a'))
      end
    end
  end # class methods

  describe 'instance methods' do
    describe 'to_hash' do
      it 'works' do
        assert_equal(Fuzzyurl.new('example.com:8888').to_hash,
                     protocol: nil, username: nil, password: nil,
                     hostname: 'example.com', port: '8888', path: nil,
                     query: nil, fragment: nil)
      end
    end

    describe 'with' do
      it 'creates a new Fuzzyurl object' do
        fu1 = Fuzzyurl.new(hostname: 'example.com', port: '80')
        fu2 = fu1.with(port: '8888')
        assert(fu1 != fu2)
        assert_equal('example.com', fu1.hostname)
        assert_equal('example.com', fu2.hostname)
        assert_equal('80', fu1.port)
        assert_equal('8888', fu2.port)
      end
    end

    describe 'to_s' do
      it 'is delegated' do
        assert_equal('http://example.com',
                     Fuzzyurl.new(protocol: 'http', hostname: 'example.com').to_s)
      end
    end
  end # instance methods
end
