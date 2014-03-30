require 'test_helper'

MATCHES = <<-EOT.split(/\s+/)

  *                   http://example.com
  *                   http://example.com/
  *                   https://example.com/
  *                   http://username:password@api.example.com/v1
  *                   http://www53.cdn.example.com/?something=1&xss=true
  *                   http://example.com/Q@(@*&%&!
  *                   http://example.com

  http://*            http://example.com
  http://*            example.com
  http://*            http://example.com:80
  http://*            http://example.com:8080
  http://*            http://example.com/some/path?args=1

  example.com         example.com
  example.com         example.com:80

  example.com         http://example.com
  example.com         http://example.com/some/path?args=1
  example.com         http://example.com:80/
  example.com         http://example.com

  http://example.com  example.com
  http://example.com  example.com/a/b/c
  http://example.com  example.com:80/a/b/c

  example.com/a/*     example.com/a/b/c

  *.example.com       api.example.com
  *.example.com       xxx.yyy.example.com

  example.com:8080    example.com:8080
  localhost:12345     localhost:12345

  example.com:443     https://example.com/
EOT

NEGATIVE_MATCHES = <<-EOT.split(/\s+/)

  http://*            https://example.com
  https://*           http://example.com

  http://example.com  http://www.example.com

  *.example.com       example.com

  example.com/a/*     example.com/b/a/b/c
  example.com/a/*     foobar.com/a/b/c

  example.com:888     example.com:8888
  https://example.com example.com:443

EOT

describe URLMask do
  describe '.matches?' do
    it 'passes control to .match_hash' do
      URLMask.expects(:match_hash).returns(true)
      URLMask.match('*', '*')
    end

    it 'handles positive matches' do
      i = 0
      while i < MATCHES.count-1
        mask = MATCHES[i+=1]
        url = MATCHES[i+=1]
        URLMask.matches?(mask, url).must_equal true, "#{mask} vs #{url}"
      end
    end

    it 'handles negative matches' do
      i = 0
      while i < NEGATIVE_MATCHES.count-1
        mask = NEGATIVE_MATCHES[i+=1]
        url = NEGATIVE_MATCHES[i+=1]
        URLMask.matches?(mask, url).must_equal false, "#{mask} vs #{url}"
      end
    end
  end

  describe '#matches?' do
    it 'passes control to .match_hash' do
      URLMask.expects(:match_hash).returns(true)
      mask = URLMask.new('*')
      mask.matches?('*')
    end

    it 'handles positive matches' do
      i = 0
      while i < MATCHES.count-1
        mask = MATCHES[i+=1]
        url = MATCHES[i+=1]
        urlmask = URLMask.new(mask)
        urlmask.matches?(url).must_equal true, "#{mask} vs #{url}"
      end
    end

    it 'handles negative matches' do
      i = 0
      while i < NEGATIVE_MATCHES.count-1
        mask = NEGATIVE_MATCHES[i+=1]
        url = NEGATIVE_MATCHES[i+=1]
        urlmask = URLMask.new(mask)
        urlmask.matches?(url).must_equal false, "#{mask} vs #{url}"
      end
    end
  end

  describe '.match' do
    it 'scores wildcards correctly' do
      URLMask.match('*', 'http://example.com/a/b').must_equal 0
      URLMask.match('*://*/*', 'http://example.com/a/b').must_equal 0
    end

    it 'scores exact matches correctly' do
      URLMask.match('example.com', 'http://example.com/a/b').must_equal 1
      URLMask.match('http://example.com', 'http://example.com/a/b').must_equal 2
      URLMask.match('http://example.com/a/*', 'http://example.com/a/b').must_equal 2
      URLMask.match('http://example.com/a/b', 'http://example.com/a/b').must_equal 3

      URLMask.match(
        'http://user:pass@example.com:12345/some/path?query=true&foo=bar#frag',
        'http://user:pass@example.com:12345/some/path?query=true&foo=bar#frag'
      ).must_equal 8

      URLMask.match('*.example.com:80', 'api.example.com').must_equal 0
    end
  end


  describe '#to_hash' do
    it 'hands off processing to .url_to_hash' do
      URLMask.expects(:url_to_hash).with('test').returns({})
      m = URLMask.new('test')
      m.to_hash
    end

    it 'memoizes' do
      URLMask.expects(:url_to_hash).with('test').returns({})
      m = URLMask.new('test')
      m.to_hash
      m.to_hash
    end
  end

  describe '.url_to_hash' do
    it 'handles bad input' do
      d = URLMask.url_to_hash('this is clearly crap')
      d.must_be_nil
    end

    it 'handles *' do
      d = URLMask.url_to_hash('*')
      d[:protocol].must_be_nil
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal '*'
      d[:port].must_be_nil
      d[:path].must_be_nil
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles example.com' do
      d = URLMask.url_to_hash('example.com')
      d[:protocol].must_be_nil
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal 'example.com'
      d[:port].must_be_nil
      d[:path].must_be_nil
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles http://example.com' do
      d = URLMask.url_to_hash('http://example.com')
      d[:protocol].must_equal 'http'
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal 'example.com'
      d[:port].must_be_nil
      d[:path].must_be_nil
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles http://*' do
      d = URLMask.url_to_hash('http://*')
      d[:protocol].must_equal 'http'
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal '*'
      d[:port].must_be_nil
      d[:path].must_be_nil
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles example.com:80' do
      d = URLMask.url_to_hash('example.com:80')
      d[:protocol].must_be_nil
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal 'example.com'
      d[:port].must_equal 80
      d[:path].must_be_nil
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles https://example.com/' do
      d = URLMask.url_to_hash('https://example.com/')
      d[:protocol].must_equal 'https'
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal 'example.com'
      d[:port].must_be_nil
      d[:path].must_equal '/'
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles http://example.com:12345' do
      d = URLMask.url_to_hash('http://example.com:12345')
      d[:protocol].must_equal 'http'
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal 'example.com'
      d[:port].must_equal 12345
      d[:path].must_be_nil
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles http://user:pass@example.com' do
      d = URLMask.url_to_hash('http://user:pass@example.com')
      d[:protocol].must_equal 'http'
      d[:username].must_equal 'user'
      d[:password].must_equal 'pass'
      d[:hostname].must_equal 'example.com'
      d[:port].must_be_nil
      d[:path].must_be_nil
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles http://user:@example.com' do
      d = URLMask.url_to_hash('http://user:@example.com')
      d[:protocol].must_equal 'http'
      d[:username].must_equal 'user'
      d[:password].must_equal ''
      d[:hostname].must_equal 'example.com'
      d[:port].must_be_nil
      d[:path].must_be_nil
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles http://example.com/some/path?query=true' do
      d = URLMask.url_to_hash('http://example.com/some/path?query=true')
      d[:protocol].must_equal 'http'
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal 'example.com'
      d[:port].must_be_nil
      d[:path].must_equal '/some/path'
      d[:query].must_equal 'query=true'
      d[:fragment].must_be_nil
    end

    it 'handles https://example.com?query=true' do
      d = URLMask.url_to_hash('https://example.com?query=true')
      d[:protocol].must_equal 'https'
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal 'example.com'
      d[:port].must_be_nil
      d[:path].must_be_nil
      d[:query].must_equal 'query=true'
      d[:fragment].must_be_nil
    end

    it 'handles HTTP://Example.COM/PATH#frag' do
      d = URLMask.url_to_hash('HTTP://Example.COM/PATH#frag')
      d[:protocol].must_equal 'http'
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_equal 'example.com'
      d[:port].must_be_nil
      d[:path].must_equal '/PATH'
      d[:query].must_be_nil
      d[:fragment].must_equal 'frag'
    end

    it 'handles file:///path/to/a/file' do
      d = URLMask.url_to_hash('file:///path/to/a/file')
      d[:protocol].must_equal 'file'
      d[:username].must_be_nil
      d[:password].must_be_nil
      d[:hostname].must_be_nil
      d[:port].must_be_nil
      d[:path].must_equal '/path/to/a/file'
      d[:query].must_be_nil
      d[:fragment].must_be_nil
    end

    it 'handles http://user:pass@example.com:12345/some/path?query=true&foo=bar#frag' do
      d = URLMask.url_to_hash('http://user:pass@example.com:12345/some/path?query=true&foo=bar#frag')
      d[:protocol].must_equal 'http'
      d[:username].must_equal 'user'
      d[:password].must_equal 'pass'
      d[:hostname].must_equal 'example.com'
      d[:port].must_equal 12345
      d[:path].must_equal '/some/path'
      d[:query].must_equal 'query=true&foo=bar'
      d[:fragment].must_equal 'frag'
    end
  end

end
