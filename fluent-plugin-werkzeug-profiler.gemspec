# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-werkzeug-profiler"
  gem.version       = "0.0.1"
  gem.authors       = ["Kenta MORI"]
  gem.email         = ["zoncoen@gmail.com"]
  gem.description   = %q{Fluent input plugin for Werkzeug WSGI application profiler statistics.}
  gem.summary       = %q{Fluent input plugin for Werkzeug WSGI application profiler statistics.}
  gem.homepage      = "https://github.com/zoncoen/fluent-plugin-werkzeug-profiler.git"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake"
  gem.add_runtime_dependency "fluentd"
end
