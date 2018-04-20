lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-tcp-ml"
  spec.version = "1.0.3"
  spec.authors = ["dotwilbert"]
  spec.email   = ["fietsebel@thisisnotmyrealemail.com"]

  spec.summary       = 'fluentd output plugin to send logs to a remote tcp port with multiline support'
  spec.description   = %q{tcp_ml out put plug in for fluentd.

    This plugin creates a persistent tcp connection to a remote host at start. 
  }
  spec.homepage      = "https://github.com/dotwilbert/fluent-plugin-tcp-ml"
  spec.license       = "Apache-2.0"

  test_files, files  = `git ls-files -z`.split("\x0").partition do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.files         = files
  spec.executables   = files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = test_files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_runtime_dependency "uuidtools", "~> 2.1"
end
