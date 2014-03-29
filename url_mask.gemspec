require './lib/url_mask/version'

Gem::Specification.new do |s|
  s.name     = 'urlmask'
  s.version  = URLMask.version
  s.date     = URLMask.version_date

  s.summary  = 'Match URLs to URL masks.'
  s.description = <<-EOT
    URLMask is a gem for matching URLs like "http://example.com/a/b/c"
    to URL masks like "example.com", "http://example.com:*/a/*", etc.
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


