# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "pingen-client"
  spec.version = "0.2.0"
  spec.authors = ["Martin Cavoj", "Alessandro Rodi"]
  spec.email = ["alessandro.rodi@renuo.ch"]

  spec.summary = "Invoke Pingen API easily with Ruby"
  spec.description = "This gem allows you to connect to Pingen API and use the services provided"
  spec.homepage = "https://github.com/renuo/pingen-client"
  spec.license = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/renuo/pingen-client"
  spec.metadata["changelog_uri"] = "https://github.com/renuo/pingen-client/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
