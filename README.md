# Fuzzyurl

A library for parsing, construction, and wildcard matching of URLs.

Available for:

* [Ruby](https://github.com/gamache/fuzzyurl.rb)

  [![Build Status](https://travis-ci.org/gamache/fuzzyurl.rb.svg?branch=master)](https://travis-ci.org/gamache/fuzzyurl.rb)
  [![Coverage Status](https://coveralls.io/repos/gamache/fuzzyurl.rb/badge.svg?branch=master&service=github)](https://coveralls.io/github/gamache/fuzzyurl.rb?branch=master)

* [Elixir](https://github.com/gamache/fuzzyurl.ex)

  [![Build Status](https://travis-ci.org/gamache/fuzzyurl.ex.svg?branch=master)](https://travis-ci.org/gamache/fuzzyurl.ex)
  [![Hex.pm Version](http://img.shields.io/hexpm/v/fuzzyurl.svg?style=flat)](https://hex.pm/packages/fuzzyurl)
  [![Coverage Status](https://coveralls.io/repos/gamache/fuzzyurl.ex/badge.svg?branch=master&service=github)](https://coveralls.io/github/gamache/fuzzyurl.ex?branch=master)

* [JavaScript](https://github.com/gamache/fuzzyurl.js)

  [![Build Status](https://travis-ci.org/gamache/fuzzyurl.js.svg?branch=master)](https://travis-ci.org/gamache/fuzzyurl.js)
  [![npm version](https://badge.fury.io/js/fuzzyurl.svg)](https://badge.fury.io/js/fuzzyurl)


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


## Documentation

Documentation is provided in the per-language repositories linked at the
top of this README.


## Contributing

Contributing patches is awesome!  The ideal patch comes in the form of a
GitHub pull request to one of the per-language repos, containing a good
description of the PR's intent, well-documented code implementing the
change, and tests to verify its operation.

Changes, however, should be suitable for inclusion in all the Fuzzyurl
implementations, not just one.

Copyright on all accepted contributions will be assigned to the project
copyright holder (Pete Gamache).  Contributors shall be recognized in
each project's README.


## Authorship and License

All implementations of Fuzzyurl are copyright 2014-2016, Pete Gamache.

All Fuzzyurl implementations are released under the MIT License,
available at LICENSE.txt.

