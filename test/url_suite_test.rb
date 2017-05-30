require 'test_helper'
require 'json'

MATCHES = JSON.parse(File.read(File.expand_path('../matches.json', __FILE__)))

describe 'URL test suite' do
  describe 'positive matches' do
    MATCHES['positive_matches'].each do |(mask, url)|
      it "'#{mask}' matches '#{url}'" do
        assert(Fuzzyurl.matches?(mask, url))
      end
    end
  end

  describe 'negative matches' do
    MATCHES['negative_matches'].each do |(mask, url)|
      it "'#{mask}' does not match '#{url}'" do
        assert(!Fuzzyurl.matches?(mask, url))
      end
    end
  end
end
