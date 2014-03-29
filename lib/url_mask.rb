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
     # STDERR.puts '  ' + str
    end

    def compare(mask, url)
      unless mask_parts = decompose_url(mask)
        raise ArgumentError, "Badly formed URL mask: #{mask.inspect}"
      end
      unless url_parts = decompose_url(url)
        raise ArgumentError, "Badly formed URL: #{url.inspect}"
      end

     # STDERR.puts "#{mask} vs #{url}:"

      return false unless compare_protocols_and_ports(mask_parts, url_parts)

      debug("matched protocol")
      debug("matched port")
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
      #puts mask_parts[:path].inspect
      #puts url_parts[:path].inspect
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

      mask_port = mask_parts[:port]
      url_port = url_parts[:port] || PORT_BY_PROTOCOL[url_protocol]
      if mask_parts[:port]
        return false if mask_port != '*' && mask_port != url_port
      end

      true
    end

    def fuzzy_match(mask, piece)
      if mask
        if mask != piece && mask != '*'
          return false
        end
      end
      true
    end

    def compare_hostnames(mask, host)
      compare_pieces((mask || '').split('.').reverse,
                     (host || '').split('.').reverse)
    end

    def compare_paths(mask, path)
      compare_pieces((mask || '/*').split('/'),
                     (path || '/').split('/'))
    end

    def compare_pieces(mask, pieces)
      i = 0
      pieces.each do |piece|
        #puts "piece #{i}: #{mask[i].inspect} vs #{piece.inspect}"
        return true if piece && mask[i] == '*'
        return false if mask[i] != piece
        i += 1
      end
      #return false if mask[i]
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

        #if !(port = m[5]) && PORT_BY_PROTOCOL.has_key?(protocol)
          #port = PORT_BY_PROTOCOL[protocol]
        #end
        port = m[5] ? m[5].to_i : nil
        port = port.to_i if port

        path = m[6]
        path = nil if path == ''

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

