require 'rake/testtask'

task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.libs << 'test/lib'
  t.test_files = FileList['test/**/*_test.rb']
  #t.warning = true
  t.verbose = true
end

task :release do
  system(<<-EOT)
    git add lib/fuzzyurl/version.rb
    git commit -m 'release v#{Fuzzyurl::VERSION}'
    git push origin
    git tag v#{Fuzzyurl::VERSION}
    git push --tags origin
    gem build fuzzyurl.gemspec
    gem push fuzzyurl-#{Fuzzyurl::VERSION}.gem
  EOT
end

