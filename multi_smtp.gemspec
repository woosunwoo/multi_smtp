# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "multi_smtp/version"

Gem::Specification.new do |spec|
  spec.name          = "multi_smtp_plus"
  spec.version       = MultiSMTP::VERSION
  spec.authors       = ["Harlow Ward", "Sunwoo Yang"]
  spec.email         = ["harlow@hward.com", "yangsunwoo@gmail.com"]
  spec.summary       = %q{Automatic SMTP email failover in Rails with MultiSMTP}
  spec.description   = %q{MultiSMTP Plus provides automatic SMTP failover and rotation across multiple providers for Rails (6–8). It supports sequential or round-robin rotation and per-provider skip conditions (e.g., free-tier quota checks), with optional cross-process state via Redis.}
  spec.homepage      = "https://github.com/woosunwoo/multi_smtp"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.1"
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => File.join(spec.homepage, "releases")
  }

  spec.files         = Dir[
    "lib/**/*",
    "README.md",
    "LICENSE.txt",
    "multi_smtp.gemspec"
  ]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  # Mail 2.7–2.8 are used by Rails 6–8
  spec.add_runtime_dependency "mail", ">= 2.7", "< 3"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3.10"
end
