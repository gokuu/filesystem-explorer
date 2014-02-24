$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "filesystem_explorer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "filesystem-explorer"
  s.version     = FilesystemExplorer::VERSION
  s.authors     = ["Pedro Miguel Rodrigues"]
  s.email       = ["pedro@bbde.org"]
  s.homepage    = "http://github.com/gokuu/filesystem_explorer"
  s.summary     = "Rails mountable engine to explore the filesystem."
  s.description = "Rails mountable engine to explore the filesystem."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
