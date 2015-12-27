# Fuzzyurl

[![Build Status](https://travis-ci.org/gamache/fuzzyurl.rb.svg?branch=master)](https://travis-ci.org/gamache/fuzzyurl.rb)
[![Coverage Status](https://coveralls.io/repos/gamache/fuzzyurl.rb/badge.svg?branch=master&service=github)](https://coveralls.io/github/gamache/fuzzyurl.rb?branch=master)

Non-strict parsing, composition, and wildcard matching of URLs in
Ruby.

## Introduction

Fuzzyurl provides two related functions: non-strict parsing of URLs or
URL-like strings into their component pieces (protocol, username, password,
hostname, port, path, query, and fragment), and fuzzy matching of URLs
and URL patterns.

Specifically, URLs that look like this:

    [protocol ://] [username [: password] @] [hostname] [: port] [/ path] [? query] [# fragment]

Fuzzyurls can be constructed using some or all of the above
fields, optionally replacing some or all of those fields with a `*`
wildcard if you wish to use the Fuzzyurl as a URL mask.


## Installation

Put the following in your `Gemfile`:

    gem 'fuzzyurl', '~> 0.8.0'


## Parsing URLs

    irb> Fuzzyurl.from_string("https://api.example.com/users/123?full=true")
    #=> #<Fuzzyurl:0x007ff55b914f58 @protocol="https", @username=nil, @password=nil, @hostname="api.example.com", @port=nil, @path="/users/123", @query="full=true", @fragment=nil>


## Constructing URLs

    irb> f = Fuzzyurl.new(hostname: "example.com", protocol: "http", port: "8080")
    irb> f.to_s
    #=> "http://example.com:8080"


## Matching URLs

Fuzzyurl supports wildcard matching:

* `*` matches anything, including `null`.
* `foo*` matches `foo`, `foobar`, `foo/bar`, etc.
* `*bar` matches `bar`, `foobar`, `foo/bar`, etc.

Path and hostname matching allows the use of a greedier wildcard `**` in
addition to the naive wildcard `*`:

* `*.example.com` matches `filsrv-01.corp.example.com` but not `example.com`.
* `**.example.com` matches `filsrv-01.corp.example.com` and `example.com`.
* `/some/path/*` matches `/some/path/foo/bar` and `/some/path/`
   but not `/some/path`
* `/some/path/**` matches `/some/path/foo/bar` and `/some/path/`
   and `/some/path`

The `Fuzzyurl.mask` function aids in the creation of URL masks.

    irb> Fuzzyurl.mask
    #=> #<Fuzzyurl:0x007ff55b039578 @protocol="*", @username="*", @password="*", @hostname="*", @port="*", @path="*", @query="*", @fragment="*">

    irb> Fuzzyurl.matches?(Fuzzyurl.mask, "http://example.com:8080/foo/bar")
    #=> true

    irb> mask = Fuzzyurl.mask(path: "/a/b/**")
    irb> Fuzzyurl.matches?(mask, "https://example.com/a/b/")
    #=> true
    irb> Fuzzyurl.matches?(mask, "git+ssh://jen@example.com/a/b/")
    #=> true
    irb> Fuzzyurl.matches?(mask, "https://example.com/a/bar")
    #=> false

`Fuzzyurl.bestMatch`, given a list of URL masks and a URL, will return
the given mask which most closely matches the URL:

    irb> masks = ["/foo/*", "/foo/bar", Fuzzyurl.mask]
    irb> Fuzzyurl.best_match(masks, "http://example.com/foo/bar")
    #=> "/foo/bar"

If you'd prefer the array index instead of the matching mask itself, use
`Fuzzyurl.best_match_index` instead:

    irb> Fuzzyurl.best_match_index(masks, "http://example.com/foo/bar")
    #=> 1


## Authorship and License

Fuzzyurl is copyright 2014-2015, Pete Gamache.

Fuzzyurl is released under the MIT License.  See LICENSE.txt.

If you got this far, you should probably follow me on Twitter.
[@gamache](https://twitter.com/gamache)

