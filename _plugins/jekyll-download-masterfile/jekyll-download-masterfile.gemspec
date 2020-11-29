require_relative 'lib/jekyll/download_masterfile/version'

Gem::Specification.new do |spec|
  spec.name          = "jekyll-download-masterfile"
  spec.version       = Jekyll::DownloadMasterfile::VERSION
  spec.authors       = ["Stephen Gibson"]
  spec.email         = ["stephen@duradiamondsoftware.co.uk"]

  spec.summary       = %q{Downloads the ccpkg masterfile}
  spec.homepage      = "https://ccpkg.brawcode.com"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Gibbo3771/ccpkg/tree/web/_plugins/jekyll-download-masterfile"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
