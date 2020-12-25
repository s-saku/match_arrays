require_relative 'lib/match_arrays/version'

Gem::Specification.new do |spec|
  spec.name          = "match_arrays"
  spec.version       = MatchArrays::VERSION
  spec.authors       = ["s-saku"]
  spec.email         = ["t.nishi7@gmail.com"]

  spec.summary       = %q{A ruby gem that matches two arrays and executes a callback based on the match result.}
  spec.homepage      = "https://github.com/s-saku/match_arrays"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/s-saku/match_arrays"
  spec.metadata["changelog_uri"] = "https://github.com/s-saku/match_arrays/blob/main/README.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.4.4'
  spec.add_dependency "activerecord"
  spec.add_development_dependency "bundler", "~> 2.0"
end
