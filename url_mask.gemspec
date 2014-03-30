require './lib/url_mask/version'

Gem::Specification.new do |s|
  s.name     = 'urlmask'
  s.version  = URLMask::VERSION
  s.date     = URLMask::VERSION_DATE

  s.summary  = 'Non-strict URL parsing and wildcard matching.'
  s.description = <<-EOT
    URLMask provides two related functions: matching of a URL to a URL mask
    that can contain wildcards, and non-strict parsing of URLs into their
    component pieces: protocol, username, password, hostname, port, path,
    query, and fragment.
  EOT
  s.homepage = 'https://github.com/gamache/urlmask'
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


