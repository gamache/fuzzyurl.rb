require 'test_helper'

describe Fuzzyurl::Strings do

  describe 'from_string' do
    it 'handles simple URLs' do
      assert(Fuzzyurl::Strings.from_string("http://example.com"))
      assert(Fuzzyurl::Strings.from_string("ssh://user:pass@host"))
      assert(Fuzzyurl::Strings.from_string("https://example.com:443/omg/lol"))
    end

    it 'rejects bullshit' do
      assert_equal(nil, Fuzzyurl::Strings.from_string(nil))
      assert_equal(nil, Fuzzyurl::Strings.from_string(22))
    end

    it 'handles rich URLs' do
      fu = Fuzzyurl::Strings.from_string("http://user_1:pass%20word@foo.example.com:8000/some/path?awesome=true&encoding=ebcdic#/hi/mom")
      assert_equal("http", fu.protocol)
      assert_equal("user_1", fu.username)
      assert_equal("pass%20word", fu.password)
      assert_equal("foo.example.com", fu.hostname)
      assert_equal("8000", fu.port)
      assert_equal("/some/path", fu.path)
      assert_equal("awesome=true&encoding=ebcdic", fu.query)
      assert_equal("/hi/mom", fu.fragment)
    end
  end

  describe 'to_string' do
    it 'handles simple URLs' do
      assert_equal('example.com', Fuzzyurl::Strings.to_string(
        Fuzzyurl.new(hostname: 'example.com')))
      assert_equal('http://example.com', Fuzzyurl::Strings.to_string(
        Fuzzyurl.new(protocol: 'http', hostname: 'example.com')))
      assert_equal('http://example.com/oh/yeah', Fuzzyurl::Strings.to_string(
        Fuzzyurl.new(path: '/oh/yeah', protocol: 'http', hostname: 'example.com')))
    end

    it 'handles rich URLs' do
      fu = Fuzzyurl.new(
        protocol: "https",
        username: "u",
        password: "p",
        hostname: "api.example.com",
        port: "443",
        path: "/secret/endpoint",
        query: "admin=true",
        fragment: "index"
      )
      assert_equal(Fuzzyurl::Strings.to_string(fu),
        "https://u:p@api.example.com:443/secret/endpoint?admin=true#index")
    end
  end
end

