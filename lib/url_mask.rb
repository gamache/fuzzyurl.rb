class URLMask

  attr_reader :mask

  def initialize(mask)
    @mask = mask
  end

  def to_s
    mask
  end

  def matches?(url)
    begin
      self.class.compare(mask, url)
    rescue ArgumentError
      false
    end
  end

  class << self

    def debug(str)
      #STDERR.puts '  ' + str
    end

    def compare(mask, url)
      unless mask_parts = decompose_url(mask)
        raise ArgumentError, "Badly formed URL mask: #{mask.inspect}"
      end
      unless url_parts = decompose_url(url)
        raise ArgumentError, "Badly formed URL: #{url.inspect}"
      end

      #STDERR.puts "#{mask} vs #{url}:"

      return false unless compare_protocols_and_ports(mask_parts, url_parts)

      return false unless fuzzy_match(mask_parts[:username],
                                      url_parts[:username])

      debug("matched username")
      return false unless fuzzy_match(mask_parts[:password],
                                      url_parts[:password])

      debug("matched password")
      return false unless fuzzy_match(mask_parts[:query],
                                      url_parts[:query])

      debug("matched query")
      return false unless fuzzy_match(mask_parts[:fragment],
                                      url_parts[:fragment])

      debug("matched fragment")
      return false unless compare_hostnames(mask_parts[:hostname],
                                            url_parts[:hostname])

      debug("matched hostnames")

      return false unless compare_paths(mask_parts[:path],
                                        url_parts[:path])
      debug("matched paths")

      true
    end


    def compare_protocols_and_ports(mask_parts, url_parts)
      mask_protocol = mask_parts[:protocol] || 'http'
      url_protocol = url_parts[:protocol] || 'http'
      if mask_parts[:protocol]
        return false if mask_protocol != '*' && mask_protocol != url_protocol
      end
      debug("matched protocol")

      mask_port = mask_parts[:port]
      url_port = url_parts[:port] || PORT_BY_PROTOCOL[url_protocol]
      if mask_parts[:port]
        return false if mask_port != '*' && mask_port != url_port
      end
      debug("matched port")

      true
    end

    def fuzzy_match(mask, piece)
      if mask
        if mask != piece && mask != '*' && piece
          return false
        end
      end
      true
    end

    ## *.example.com => 'com', 'example', '*'
    ## example.com   => 'com', 'example'
    ## This should not match.
    def compare_hostnames(mask, host)
      compare_pieces((mask || '').split('.').reverse,
                     (host || '').split('.').reverse,
                     :ignore_depth => false)
    end

    ## /some/path/*  => '', 'some', 'path', '*'
    ## /some/path    => '', 'some', 'path'
    ## This should match.
    def compare_paths(mask, path)
      compare_pieces((mask || '*').split(%r{/}),
                     (path || '/').split(%r{/}),
                     :ignore_depth => true)
    end

    def compare_pieces(mask, pieces, args)
      ignore_depth = args[:ignore_depth]
      return false if !ignore_depth && mask.count > pieces.count
      #puts mask.inspect
      #puts pieces.inspect
      i = 0
      pieces.each do |piece|
        #puts "piece #{i}: #{mask[i].inspect} vs #{piece.inspect}"
        return true if piece && mask[i] == '*'
        return false if mask[i] != piece
        i += 1
      end
      true
    end

    def decompose_url(url)
      if m = url.match(%r{
            ^

            (?: ([a-zA-Z]+) ://)?         ## m[1] is protocol

            (?: ([a-zA-Z0-9]+)            ## m[2] is username
                (?: : ([a-zA-Z0-9]*))     ## m[3] is password
                @
            )?

            ([a-zA-Z0-9\.\*\-]+?)?        ## m[4] is hostname
                                          ## match * too

            (?: : (\*|\d+))?              ## m[5] is port
                                          ## match * too

            (/ [^\?\#]*)?                 ## m[6] is path

            (?: \? ([^\#]*) )?            ## m[7] is query

            (?: \# (.*) )?                ## m[8] is fragment

            $
          }x)
        protocol = m[1] ? m[1].downcase : nil
        username = m[2]
        password = m[3]
        hostname = m[4] ? m[4].downcase : nil

        port = m[5] ? m[5].to_i : nil
        port = port.to_i if port

        path = m[6]

        query    = m[7]
        fragment = m[8]

        { :protocol => protocol,
          :username => username,
          :password => password,
          :hostname => hostname,
          :port => port,
          :path => path,
          :query => query,
          :fragment => fragment }

      else ## no match
        nil
      end
    end

    PORT_BY_PROTOCOL = {
      'http'  => 80,
      'https' => 443,
      'file'  => nil,
    }
  end

end

