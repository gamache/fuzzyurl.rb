## URLMask is a class for representing a URL mask with wildcards, and for
## matching other URLs against that URL mask.  It also contains facilities
## for non-strict parsing of common URLs.
##
## Example usage:
##
## ```
## mask = URLMask.new('http://example.com/*')
## mask.matches?('http://example.com')        # => true
## mask.matches?('http://example.com/a/b/c')  # => true
## mask.matches?('https://example.com')       # => false
## mask.matches?('http://foobar.com')         # => false
## ```
##
## It is important to note that URLMask is not a URL validator!  It performs
## lenient matching of URLs and URL masks like the following:
##
## ```
## [protocol ://] [username [: password] @] [hostname] [: port] [/ path] [? query] [# fragment]
## ```
##
## In a URL mask, any part of the above may be replaced with a `*` character
## to match anything.
##
## In a hostname, the most specific segment of the host (e.g., the "xyz"
## in "xyz.us.example.com") may be replaced with a `*` character
## (e.g., "*.us.example.com") in order to match domains like
## "xxx.us.example.com" and "yyy.zzz.us.example.com", but not "us.example.com".
##
## In a path, a `*` character may be placed after a `/` character (e.g.,
## "/a/b/*") in order to match paths like "/a/b" and "/a/b/c/d", but not
## "/a/bcde".

class URLMask

  ## The mask URL string for this URLMask.
  attr_reader :mask

  ## Creates a new URLMask with the given mask URL string.
  def initialize(mask)
    @mask = mask
  end

  ## Matches the given URL against this URLMask.
  ## Returns nil on negative match, and an integer match score otherwise.
  ## This match score is higher for more specific matches.
  def match(url)
    self.class.match_decomposed(self.decompose, self.class.decompose_url(url))
  end

  ## Matches the given URL against this URLMask.
  ## Returns true on positive match, false otherwise.
  def matches?(url)
    match(url) ? true : false
  end

  ## Returns this URLMask's decomposed (Hash) form.
  def decompose
    @decomposed ||= self.class.decompose_url(self.mask)
  end

  ## Returns this URLMask's mask URL string.
  def to_s
    mask
  end

  ## Returns this URLMask's decomposed (Hash) form.
  def to_hash
    decompose
  end


  class << self

    ## Given a URL, returns a hash containing :protocol, :username, :password,
    ## :hostname, :port, :path, :query, and :fragment fields (all String
    ##  or nil).
    ## Accepts `*` in place of any of the above fields, or as part of hostname
    ## or path.
    ## Returns nil if given a malformed URL.
    ##
    ## Example:
    ##
    ## ```
    ## URLMask.decompose_url('http://user:pass@example.com:8080/some/path/?foo=bar&baz=1#url-fragment')
    ## # => {:protocol=>"http", :username=>"user", :password=>"pass", :hostname=>"example.com", :port=>8080, :path=>"/some/path/", :query=>"foo=bar&baz=1", :fragment=>"url-fragment"} 
    ## ```

    def decompose_url(url)
      if m = url.match(%r{
            ^

            (?: (\* | [a-zA-Z]+) ://)?       ## m[1] is protocol

            (?: (\* | [a-zA-Z0-9]+)          ## m[2] is username
                (?: : (\* | [a-zA-Z0-9]*))   ## m[3] is password
                @
            )?

            ([a-zA-Z0-9\.\*\-]+?)?           ## m[4] is hostname

            (?: : (\* | \d+))?               ## m[5] is port

            (/ [^\?\#]*)?                    ## m[6] is path
                                             ## captures leading /

            (?: \? ([^\#]*) )?               ## m[7] is query

            (?: \# (.*) )?                   ## m[8] is fragment

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

    ## Matches a URL mask string with a URL string.
    ## Raises ArgumentError when given malformed URLs.
    ## Returns true on positive match, false otherwise.
    def matches?(mask, url)
      match(mask, url) ? true : false
    end

    ## Matches a URL mask string with a URL string.
    ## Raises ArgumentError when given malformed URLs.
    ## Returns nil on negative match, and an integer match score otherwise.
    ## This match score is higher for more specific matches.
    def match(mask, url)
      unless mask_parts = decompose_url(mask)
        raise ArgumentError, "Badly formed URL mask: #{mask.inspect}"
      end
      unless url_parts = decompose_url(url)
        raise ArgumentError, "Badly formed URL: #{url.inspect}"
      end
      match_decomposed(mask_parts, url_parts)
    end


    ## Compares a decomposed URL mask with a decomposed URL string.
    ## Returns nil on negative match, and an integer match score otherwise.
    ## This match score is higher for more specific matches.
    def match_decomposed(mask, url)
      score = 0
      tally = Proc.new {|x| return nil unless x; score += x}

      tally.call match_hostnames(mask[:hostname], url[:hostname])
      tally.call match_protocols_and_ports(mask, url)
      tally.call match_paths(mask[:path], url[:path])
      tally.call fuzzy_match(mask[:query], url[:query])
      tally.call fuzzy_match(mask[:username], url[:username])
      tally.call fuzzy_match(mask[:password], url[:password])
      tally.call fuzzy_match(mask[:fragment], url[:fragment])
    end

    ## Matches a decomposed URL mask against a decomposed URL.
    ## Returns true on positive match, false otherwise.
    def matches_decomposed?(mask, url)
      match_decomposed(mask, url) ? true : false
    end

  private

    ## Matches protocol and port information.
    ## Returns nil for no match, 0 for a wildcard match, or 1 for an
    ## exact match.
    def match_protocols_and_ports(mask_parts, url_parts)
      wildcard_match = false
      mask_protocol = mask_parts[:protocol] || 'http'
      url_protocol = url_parts[:protocol] || 'http'
      if mask_parts[:protocol] && mask_protocol != '*'
        return nil if mask_protocol != url_protocol
      else
        wildcard_match = true
      end

      mask_port = mask_parts[:port]
      url_port = url_parts[:port] || PORT_BY_PROTOCOL[url_protocol]
      if mask_parts[:port] && mask_port != '*'
        return nil if mask_port != url_port
      else
        wildcard_match = true
      end

      wildcard_match ? 0 : 1
    end

    PORT_BY_PROTOCOL = {
      'http'  => 80,
      'https' => 443,
      'file'  => nil,
    }

    ## Matches a mask against an element of a URL.  Handles wildcards.
    ## Returns nil for no match, 0 for a wildcard match, or 1 for an
    ## exact match.
    def fuzzy_match(mask, piece)
      return 0 if !mask || mask == '*' || !piece
      return 1 if mask == piece
      nil
    end

    ## Matches a hostname mask against a hostname.
    ## Returns nil for no match, 0 for a wildcard match, or 1 for an
    ## exact match.
    def match_hostnames(mask, host)
      mask_pieces = (mask || '').split('.').reverse
      host_pieces = (host || '').split('.').reverse
      return 1 if mask && host && mask_pieces==host_pieces
      return 0 if match_pieces(mask_pieces, host_pieces, :ignore_depth => false)
      nil
    end

    ## Matches a path mask against a path.
    ## Returns nil for no match, 0 for a wildcard match, or 1 for an
    ## exact match.
    def match_paths(mask, path)
      mask_pieces = (mask || '*').split(%r{/})
      path_pieces = (path || '/').split(%r{/})
      return 1 if mask && path && mask_pieces==path_pieces
      return 0 if match_pieces(mask_pieces, path_pieces, :ignore_depth => true)
      nil
    end

    ## Matches arrays of URL or hostname pieces.
    ## Returns nil for no match, 0 for a wildcard match, or 1 for an
    ## exact match.
    def match_pieces(mask, pieces, args)
      ignore_depth = args[:ignore_depth]
      return nil if !ignore_depth && mask.count > pieces.count
      pieces.each_with_index do |piece, i|
        return 0 if piece && mask[i] == '*'
        return nil if mask[i] != piece
      end
      1
    end

  end # class << self

end

