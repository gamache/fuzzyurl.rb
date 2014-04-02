# FuzzyURL

A Ruby Gem for non-strict URL parsing and URL fuzzy matching.

## About FuzzyURL

FuzzyURL provides two related functions: fuzzy matching of a URL to a URL
mask that can contain wildcards, and non-strict parsing of URLs into their
component pieces: protocol, username, password, hostname, port, path,
query, and fragment.

FuzzyURL provides two related functions: non-strict parsing of URLs or
URL-like strings into their component pieces (protocol, username, password,
hostname, port, path, query, and fragment), and fuzzy matching of URLs
and URL patterns.

FuzzyURL can decompose URLs that look like the following:

```
[protocol ://] [username [: password] @] [hostname] [: port] [/ path] [? query] [# fragment]
```

## Usage

FuzzyURLs can be constructed using some or all of the above
fields, replacing some or all of those fields with a `*` wildcard,
either in string format or in hash format (through `FuzzyURL.new`).
In addition, hostnames can use `*` as their first label (e.g., 
"\*.example.com"), and paths can use `*` after the last path separator
(`/`) in the path (e.g., "/some/path/\*").

```ruby
require 'fuzzyurl'

fu = FuzzyURL.new('*.example.com:80')
fu = FuzzyURL.new(hostname: '*.example.com', port: 80)  ## same thing
```

A FuzzyURL can be compared to URLs to not only determine whether a
yes-or-no match was reached (through `matches?`):

```ruby
fu.matches?('http://www.example.com/index.html')  # => true
fu.matches?('https://www.example.com')            # => false
fu.matches?('http://www.example.com:8080')        # => false
fu.matches?('www.us.example.com')                 # => true
fu.matches?('example.com')                        # => false
```

...but also to provide a
numeric match score by which multiple URL masks can be sorted for
specificity (through `match`).


```ruby

mask.to_hash
# => {:protocol=>nil, :username=>nil, :password=>nil,
#     :hostname=>"*.example.com", :port=>80, :path=>nil, 
#     :query=>nil, :fragment=>nil}
```

## Documentation

For more information, see the class documentation for FuzzyURL.

## Authorship and License

FuzzyURL is copyright 2014, Pete Gamache,
[mailto:pete@gamache.org](pete@gamache.org).

FuzzyURL is released under the MIT license.  See LICENSE.txt.

