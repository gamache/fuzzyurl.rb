require 'fuzzy_url/version'
require 'fuzzy_url/matching'
require 'fuzzy_url/url_components'
require 'pp'

## FuzzyURL is a class to represent URLs and URL-like things.  FuzzyURL aids
## in the manipulation and matching of URLs by providing non-strict parsing,
## wildcard matching, ranked matching, `#to_s`, and more.
##
## Example usage:
##
## ```
## require 'fuzzyurl'
## fuzzy_url = FuzzyURL.new('http://example.com/*')
## fuzzy_url.matches?('http://example.com')        # => true
## fuzzy_url.matches?('http://example.com/a/b/c')  # => true
## fuzzy_url.matches?('https://example.com')       # => false
## fuzzy_url.matches?('http://foobar.com')         # => false
## ```
##
## It is important to note that FuzzyURL is not a URL validator!  It performs
## lenient matching of URLs and URL-like things that look like the following:
##
## ```
## [protocol ://] [username [: password] @] [hostname] [: port] [/ path] [? query] [# fragment]
## ```
##
## In a FuzzyURL, any part of the above may be replaced with a `*` character
## to match anything.
##
## In a hostname, the leftmost label of the host (e.g., the `xyz`
## in `xyz.us.example.com`) may be replaced with a `*` character
## (e.g., `*.us.example.com`) in order to match domains like
## `xxx.us.example.com` and `yyy.zzz.us.example.com`, but not `us.example.com`.
##
## In a path, a `*` character may be placed after the last `/` path separator 
## (e.g., `/a/b/*`) in order to match paths like `/a/b` and `/a/b/c/d`,
## but not `/a/bcde`.

class FuzzyURL
  include FuzzyURL::Matching
  include FuzzyURL::URLComponents


  ## Creates a new FuzzyURL with the given URL or URL-like object of type
  ## String, Hash, or FuzzyURL.
  ## Acceptable hash keys are :protocol, :username, :password, :hostname,
  ## :port, :path, :query, and :fragment.  Hash keys other than these are
  ## ignored.
  def initialize(url='')
    default_components = {:protocol=>nil, :username=>nil, :password=>nil,
                          :hostname=>nil, :port=>nil, :path=>nil,
                          :query=>nil, :fragment=>nil}
    case url
    when String
      unless hash = self.class.url_to_hash(url)
        raise ArgumentError, "Bad url URL: #{url.inspect}"
      end
      @components = default_components.merge(hash)
    when Hash, FuzzyURL
      @components = default_components.merge(url.to_hash)
    else
      raise ArgumentError, "url must be a String, Hash, or FuzzyURL; got #{url.inspect}"
    end
  end

  ## Matches the given URL string, hash, or FuzzyURL against this FuzzyURL.
  ## Returns nil on negative match, and an integer match score otherwise.
  ## This match score is higher for more specific matches.
  def match(url)
    case url
    when String
      self.class.match_hash(self.to_hash, self.class.url_to_hash(url))
    when Hash, FuzzyURL
      self.class.match_hash(self.to_hash, url.to_hash)
    else
      raise ArgumentError, "url must be a String, Hash, or FuzzyURL; got #{url.inspect}"
    end
  end

  ## Matches the given URL string, hash, or FuzzyURL against this FuzzyURL.
  ## Returns true on positive match, false otherwise.
  def matches?(url)
    match(url) ? true : false
  end

  ## Returns this FuzzyURL's hash form.
  def to_hash
    Hash[@components]
  end

  ## Returns this FuzzyURL's string form.
  def to_s
    self.class.hash_to_url(@components)
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
    ## FuzzyURL.url_to_hash('http://user:pass@example.com:8080/some/path/?foo=bar&baz=1#url-fragment')
    ## # => {:protocol=>"http", :username=>"user", :password=>"pass", :hostname=>"example.com", :port=>8080, :path=>"/some/path/", :query=>"foo=bar&baz=1", :fragment=>"url-fragment"} 
    ## ```

    def url_to_hash(url)
      if m = url.match(%r{
            ^

            (?: (\* | [a-zA-Z][A-Za-z+.-]+) ://)?    ## m[1] is protocol

            (?: (\* | [a-zA-Z0-9%_.!~*'();&=+$,-]+)                 ## m[2] is username
                (?: : (\* | [a-zA-Z0-9%_.!~*'();&=+$,-]*))?         ## m[3] is password
                @
            )?

            ([a-zA-Z0-9\.\*\-]+?)?                   ## m[4] is hostname

            (?: : (\* | \d+))?                       ## m[5] is port

            (/ [^\?\#]*)?                            ## m[6] is path
                                                     ## captures leading /

            (?: \? ([^\#]*) )?                       ## m[7] is query

            (?: \# (.*) )?                           ## m[8] is fragment

            $
          }x)

        protocol = m[1] ? m[1].downcase : nil
        username = m[2]
        password = m[3]
        hostname = m[4] ? m[4].downcase : nil
        port     = m[5] ? m[5].to_i : nil
        path     = m[6]
        query    = m[7]
        fragment = m[8]

        { :protocol => protocol,
          :username => username,
          :password => password,
          :hostname => hostname,
          :port     => port,
          :path     => path,
          :query    => query,
          :fragment => fragment }

      else ## no match
        nil
      end
    end

    ## Given a hash containing :protocol, :username, :password,
    ## :hostname, :port, :path, :query, and :fragment fields (all String
    ## or nil), return a URL string containing these elements.
    def hash_to_url(hash)
      url = ''
      url << "#{ hash[:protocol] }://" if hash[:protocol]
      if hash[:username]
        url << "#{hash[:username]}"
        url << ":#{hash[:password]}" if hash[:password]
        url << '@'
      end
      url << "#{hash[:hostname]}" if hash[:hostname]
      url << ":#{hash[:port]}" if hash[:port]

      ## make sure path starts with a / if it's defined
      path = hash[:path]
      path = "/#{path}" if path && path.index('/') != 0
      url << "#{path}"

      url << "?#{hash[:query]}" if hash[:query]
      url << "##{hash[:fragment]}" if hash[:fragment]
      url
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
      unless mask_hash = url_to_hash(mask)
        raise ArgumentError, "Badly formed URL mask: #{mask.inspect}"
      end
      unless url_hash = url_to_hash(url)
        raise ArgumentError, "Badly formed URL: #{url.inspect}"
      end
      match_hash(mask_hash, url_hash)
    end

  end # class << self

end

