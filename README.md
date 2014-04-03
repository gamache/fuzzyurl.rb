# FuzzyURL [![Build Status](https://travis-ci.org/gamache/fuzzyurl.png?branch=master)](https://travis-ci.org/gamache/fuzzyurl)

A Ruby Gem for non-strict URL parsing, manipulation, and fuzzy matching.

## About FuzzyURL

FuzzyURL provides two related functions: non-strict parsing of URLs or
URL-like strings into their component pieces (protocol, username, password,
hostname, port, path, query, and fragment), and fuzzy matching of URLs
and URL patterns.

## Usage

FuzzyURL can work with URLs that look like the following:

```
[protocol ://] [username [: password] @] [hostname] [: port] [/ path] [? query] [# fragment]
```

FuzzyURLs can be constructed using some or all of the above
fields, replacing some or all of those fields with a `*` wildcard,
either in string format or in hash format (through `FuzzyURL.new`).
In addition, hostnames can use `*` as their first label (e.g., 
"\*.example.com"), and paths can use `*` after the last path separator
(`/`) in the given path (e.g., "/some/path/\*").


```ruby
require 'fuzzyurl'

fuzzy_url = FuzzyURL.new('*.example.com:80')
fuzzy_url = FuzzyURL.new(hostname: '*.example.com', port: 80)  ## same thing
fuzzy_url = FuzzyURL.new(FuzzyURL.new('*.example.com:80'))     ## also works

fuzzy_url.to_hash
# => {:protocol=>nil, :username=>nil, :password=>nil, :hostname=>"*.example.com",
#     :port=>80, :path=>nil, :query=>nil, :fragment=>nil}
```


### Matching

A FuzzyURL can be compared with a given URL or URL-like string, subject
to the same rules as above, to provide a boolean result with
`#matches?`:


```ruby
fuzzy_url.matches?('http://www.example.com/index.html')  # => true
fuzzy_url.matches?('https://www.example.com')            # => false
fuzzy_url.matches?('http://www.example.com:8080')        # => false
fuzzy_url.matches?('www.us.example.com')                 # => true
fuzzy_url.matches?('example.com')                        # => false
```

FuzzyURL also provides relative matching functionality through `#match`,
which returns nil (no match) or an integer representing relative match
quality, higher being more specific.  In this way, several FuzzyURLs may
be ranked in terms of specificity to a given URL: 

```ruby
fuzzy_urls = ['example.com', 'http://example.com', 'example.com/index.html',
              '*', 'example.com/index.html#foo', 'badmatch.example.com'
             ].map {|url| FuzzyURL.new(url)}
url = 'http://example.com:8080/index.html#foo'
matches = fuzzy_urls.select {|fu| fu.matches?(url)}

matches.sort_by {|fu| -fu.match(url)}.map(&:to_s)
# => ["example.com/index.html#foo", "http://example.com", 
#     "example.com/index.html", "example.com", "*"] 

```

### Parsing and Manipulation

FuzzyURLs allow back-and-forth composition and decomposition of URLs or
URL-like patterns.  Create a FuzzyURL object from a string, a hash, or
another FuzzyURL.  Then you can edit any component of the URL with ease:

```ruby
fuzzy_url = FuzzyURL.new
fuzzy_url.protocol = 'http'
fuzzy_url[:hostname] = 'example.com'
fuzzy_url['path'] = '/index.html'

fuzzy_url.to_s  # => "http://example.com/index.html" 

```

## Documentation

For more information, see the class documentation for FuzzyURL.

## Authorship and License

FuzzyURL is copyright 2014, Pete Gamache,
[mailto:pete@gamache.org](pete@gamache.org).

FuzzyURL is released under the MIT license.  See LICENSE.txt.

