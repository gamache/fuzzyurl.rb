require 'test_helper'

describe Fuzzyurl::Match do
  describe 'fuzzy_match' do
    it 'returns 0 for full wildcard' do
      assert_equal(0, Fuzzyurl::Match.fuzzy_match("*", "lol"))
      assert_equal(0, Fuzzyurl::Match.fuzzy_match("*", "*"))
      assert_equal(0, Fuzzyurl::Match.fuzzy_match("*", nil))
    end

    it 'returns 1 for exact match' do
      assert_equal(1, Fuzzyurl::Match.fuzzy_match('asdf', 'asdf'))
    end

    it 'handles *.example.com' do
      assert_equal(0, Fuzzyurl::Match.fuzzy_match(
        '*.example.com', 'api.v1.example.com'))
      assert_equal(nil, Fuzzyurl::Match.fuzzy_match(
        '*.example.com', 'example.com'))
    end

    it 'handles **.example.com' do
      assert_equal(0, Fuzzyurl::Match.fuzzy_match(
        '**.example.com', 'api.v1.example.com'))
      assert_equal(0, Fuzzyurl::Match.fuzzy_match(
        '**.example.com', 'example.com'))
      assert_equal(nil, Fuzzyurl::Match.fuzzy_match(
        '**.example.com', 'zzzexample.com'))
    end

    it 'handles path/*' do
      assert_equal(0, Fuzzyurl::Match.fuzzy_match('path/*', 'path/a/b/c'))
      assert_equal(nil, Fuzzyurl::Match.fuzzy_match('path/*', 'path'))
    end

    it 'handles path/**' do
      assert_equal(0, Fuzzyurl::Match.fuzzy_match('path/**', 'path/a/b/c'))
      assert_equal(0, Fuzzyurl::Match.fuzzy_match('path/**', 'path'))
      assert_equal(nil, Fuzzyurl::Match.fuzzy_match('path/*', 'pathzzz'))
    end

    it 'returns nil for bad matches with no wildcards' do
      assert_equal(nil, Fuzzyurl::Match.fuzzy_match("asdf", "not quite"))
    end
  end

  describe 'match' do
    fu = Fuzzyurl.new(protocol: "a", username: "b", password: "c",
      hostname: "d", port: "e", path: "f", query: "g")

    it 'returns 0 for full wildcard' do
      assert_equal(0, Fuzzyurl::Match.match(Fuzzyurl.mask, Fuzzyurl.new))
    end

    it 'returns 8 for full exact match' do
      assert_equal(8, Fuzzyurl::Match.match(fu, fu))
    end

    it 'returns 1 for one exact match' do
      mask = Fuzzyurl.mask(protocol: "a")
      assert_equal(1, Fuzzyurl::Match.match(mask, fu))
    end

    it 'infers protocol from port' do
      mask = Fuzzyurl.mask(port: 80)
      url = Fuzzyurl.new(protocol: 'http')
      assert_equal(1, Fuzzyurl::Match.match(mask, url))
      url.port = '443'
      assert_equal(nil, Fuzzyurl::Match.match(mask, url))
    end

    it 'infers port from protocol' do
      mask = Fuzzyurl.mask(protocol: 'https')
      url = Fuzzyurl.new(port: '443')
      assert_equal(1, Fuzzyurl::Match.match(mask, url))
      url.protocol = 'http'
      assert_equal(nil, Fuzzyurl::Match.match(mask, url))
    end
  end

  describe 'matches?' do
    it 'returns true for matches' do
      assert_equal(true, Fuzzyurl::Match.matches?(
        Fuzzyurl.mask, Fuzzyurl.new))
      assert_equal(true, Fuzzyurl::Match.matches?(
        Fuzzyurl.mask(hostname: "yes"), Fuzzyurl.new(hostname: "yes")))
    end

    it 'returns false for non-matches' do
      assert_equal(false, Fuzzyurl::Match.matches?(
        Fuzzyurl.mask(hostname: "yes"), Fuzzyurl.new(hostname: "no")))
    end
  end

  describe 'match_scores' do
    it 'has all Fuzzyurl fields' do
      scores = Fuzzyurl::Match.match_scores(Fuzzyurl.mask, Fuzzyurl.new)
      assert_equal(scores.keys.sort, Fuzzyurl::FIELDS.sort)
    end
  end

  describe 'best_match_index' do
    it 'returns the index of the best match' do
      best = Fuzzyurl.mask("example.com:8888")
      no_match = Fuzzyurl.mask("example.com:80")
      url = Fuzzyurl.from_string("http://example.com:8888")
      assert_equal(1, Fuzzyurl::Match.best_match_index(
        [Fuzzyurl.mask, best, no_match], url))
    end
  end

end

