$:.unshift File.expand_path("../lib", __FILE__)
require "foreman/version"

Gem::Specification.new do |gem|
  gem.name     = "foreman-capistrano"
  gem.version  = Foreman::VERSION

  gem.author   = "David Dollar, Gropher"
  gem.email    = "ddollar@gmail.com, grophen@gmail.com"
  gem.homepage = "http://github.com/Gropher/foreman"
  gem.summary  = "Process manager for applications with multiple components + capistrano support out of the box"

  gem.description = gem.summary

  gem.executables = "foreman"
  gem.files = Dir["**/*"].select { |d| d =~ %r{^(README|bin/|data/|ext/|lib/|spec/|test/)} }
  gem.files << "man/foreman.1"

  gem.add_dependency 'thor', '>= 0.13.6'

  if ENV["PLATFORM"] == "java"
    gem.add_dependency "posix-spawn", "~> 0.3.6"
    gem.platform = Gem::Platform.new("java")
  end

  if ENV["PLATFORM"] == "mingw32"
    gem.add_dependency "win32console", "~> 1.3.0"
    gem.platform = Gem::Platform.new("mingw32")
  end
end
