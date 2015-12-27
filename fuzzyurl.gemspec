require './lib/fuzzyurl/version'

Gem::Specification.new do |s|
  s.name     = 'fuzzyurl'
  s.version  = Fuzzyurl::VERSION
  s.date     = Fuzzyurl::VERSION_DATE

  s.summary  = 'A library for non-strict parsing, construction, and wildcard-matching of URLs.'
  s.homepage = 'https://github.com/gamache/fuzzyurl.rb'
  s.authors  = ['Pete Gamache']
  s.email    = 'pete@gamache.org'

  s.files    = Dir['lib/**/*']
  s.license  = 'MIT'
  s.has_rdoc = true
  s.require_path = 'lib'

  s.required_ruby_version = '>= 1.9.3'

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'minitest', '~> 4.7.0'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'coveralls'
end

