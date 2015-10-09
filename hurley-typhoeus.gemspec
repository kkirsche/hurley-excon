# coding: utf-8
lib = 'hurley-typhoeus'
lib_file = File.expand_path("../lib/#{lib}.rb", __FILE__)
File.read(lib_file) =~ /\bVERSION\s*=\s*["'](.+?)["']/
version = $1

Gem::Specification.new do |spec|
  spec.authors = ['Kevin Kirsche']
  spec.description = %q{Typhoeus connection for Hurley.}
  spec.email = %w(kev.kirsche@gmail.com)
  spec.homepage = 'https://github.com/kkirsche/hurley-typhoeus'
  dev_null    = File.exist?('/dev/null') ? '/dev/null' : 'NUL'
  git_files   = `git ls-files -z 2>#{dev_null}`
  spec.files = git_files.split("\0") if $?.success?
  spec.test_files = Dir.glob('test/**/*.rb')
  spec.licenses = ['MIT']
  spec.name = lib
  spec.require_paths = ['lib']
  spec.summary = 'Typhoeus connection for Hurley.'
  spec.version = version

  spec.add_development_dependency 'sinatra', '~> 1.4'

  spec.add_runtime_dependency 'typhoeus', '~> 0'
  spec.add_runtime_dependency 'hurley', '~> 0'
end
