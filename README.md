# FuzzyURL

A Ruby Gem for non-strict URL parsing and matching.

## What FuzzyURL Does

FuzzyURL provides two related functions: matching of a URL to a URL mask
that can contain wildcards, and non-strict parsing of a URL into its
component pieces.

`FuzzyURL.url_to_hash` and `FuzzyURL#to_hash` parse into Hash format URLs
which look like the following:
 
```
[protocol ://] [username [: password] @] [hostname] [: port] [/ path] [? query] [# fragment]
```

Further, URL masks can be constructed using some or all of the above
fields, replacing some or all of those fields with a `*` wildcard,
either in string format or in hash format (through `FuzzyURL.new`).

These URL masks can be compared to URLs to not only determine whether a
yes-or-no match was reached (through `matches?`), but also provide a
numeric match score by which multiple URL masks can be sorted for
specificity (through `match`).

## Usage

FuzzyURL has no external dependencies, and is usable in Ruby 1.8.7 or above:

```ruby
require 'urlmask'

mask = FuzzyURL.new('*.example.com:80')

mask.matches?('http://www.example.com/index.html')  # => true
mask.matches?('https://www.example.com')            # => false
mask.matches?('http://www.example.com:8080')        # => false
mask.matches?('www.us.example.com')                 # => true
mask.matches?('example.com')                        # => false

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

