# URLMask

A Ruby Gem for non-strict URL parsing and matching.

## What URLMask Does

URLMask provides two related functions: matching of a URL to a URL mask
that can contain wildcards, and non-strict parsing of a URL into its
component pieces.

Ruby's built-in URI library is not suitable for non-strict parsing,
so URLMask provides a lenient, regex-based matcher to decompose URLs
that look like the following:

```
[protocol ://] [username [: password] @] [hostname] [: port] [/ path] [? query] [# fragment]
```

## Usage

URLMask has no external dependencies, and is usable in Ruby 1.8.7 or above:

```ruby
require 'urlmask'

mask = URLMask.new('*.example.com:80')

mask.matches?('http://www.example.com/index.html')  # => true
mask.matches?('https://www.example.com')            # => false
mask.matches?('http://www.example.com:8080')        # => false
mask.matches?('www.us.example.com')                 # => true
mask.matches?('example.com')                        # => false

mask.decompose
# => {:protocol=>nil, :username=>nil, :password=>nil,
#     :hostname=>"*.example.com", :port=>80, :path=>nil, 
#     :query=>nil, :fragment=>nil}
```

## Documentation

For more information, see the class documentation for URLMask.

## Authorship and License

URLMask is copyright 2014, Pete Gamache,
[mailto:pete@gamache.org](pete@gamache.org).

URLMask is released under the MIT license.  See LICENSE.txt.

