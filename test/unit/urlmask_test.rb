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
  describe '.compare' do
    it 'passes control to .compare_decomposed' do
      URLMask.expects(:compare_decomposed).returns(true)
      URLMask.compare('*', '*')
    end

    it 'handles positive matches' do
      i = 0
      while i < MATCHES.count-1
        mask = MATCHES[i+=1]
        url = MATCHES[i+=1]
        URLMask.compare(mask, url).must_equal true, "#{mask} vs #{url}"
      end
    end

    it 'handles negative matches' do
      i = 0
      while i < NEGATIVE_MATCHES.count-1
        mask = NEGATIVE_MATCHES[i+=1]
        url = NEGATIVE_MATCHES[i+=1]
        URLMask.compare(mask, url).must_equal false, "#{mask} vs #{url}"
      end
    end
  end

  describe '#matches' do
    it 'passes control to .compare_decomposed' do
      URLMask.expects(:compare_decomposed).returns(true)
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

  describe '#decompose' do
    it 'hands off processing to .decompose_url' do
      URLMask.expects(:decompose_url).with('test').returns({})
      m = URLMask.new('test')
      m.decompose
    end

    it 'memoizes' do
      URLMask.expects(:decompose_url).with('test').returns({})
      m = URLMask.new('test')
      m.decompose
      m.decompose
    end
  end

  describe '.decompose_url' do
    it 'handles bad input' do
      d = URLMask.decompose_url('this is clearly crap')
      d.must_be_nil
    end

    it 'handles *' do
      d = URLMask.decompose_url('*')
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
      d = URLMask.decompose_url('example.com')
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
      d = URLMask.decompose_url('http://example.com')
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
      d = URLMask.decompose_url('http://*')
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
      d = URLMask.decompose_url('example.com:80')
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
      d = URLMask.decompose_url('https://example.com/')
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
      d = URLMask.decompose_url('http://example.com:12345')
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
      d = URLMask.decompose_url('http://user:pass@example.com')
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
      d = URLMask.decompose_url('http://user:@example.com')
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
      d = URLMask.decompose_url('http://example.com/some/path?query=true')
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
      d = URLMask.decompose_url('https://example.com?query=true')
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
      d = URLMask.decompose_url('HTTP://Example.COM/PATH#frag')
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
      d = URLMask.decompose_url('file:///path/to/a/file')
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
      d = URLMask.decompose_url('http://user:pass@example.com:12345/some/path?query=true&foo=bar#frag')
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
