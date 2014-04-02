require './lib/fuzzy_url/version'

Gem::Specification.new do |s|
  s.name     = 'fuzzyurl'
  s.version  = FuzzyURL::VERSION
  s.date     = FuzzyURL::VERSION_DATE

  s.summary  = 'Non-strict URL parsing and URL fuzzy matching.'
  s.description = <<-EOT
    FuzzyURL provides two related functions: fuzzy matching of a URL to a URL
    mask that can contain wildcards, and non-strict parsing of URLs into their
    component pieces: protocol, username, password, hostname, port, path,
    query, and fragment.
  EOT
  s.homepage = 'https://github.com/gamache/fuzzyurl'
  s.authors  = ['Pete Gamache']
  s.email    = 'pete@gamache.org'

  s.files    = Dir['lib/**/*']
  s.license  = 'MIT'
  s.has_rdoc = true
  s.require_path = 'lib'

  s.required_ruby_version = '>= 1.8.7'

  s.add_development_dependency 'rake',      '>= 10.0.4'
  s.add_development_dependency 'minitest',  '>= 4.7.0'
  s.add_development_dependency 'mocha',     '>= 0.13.3'
end


