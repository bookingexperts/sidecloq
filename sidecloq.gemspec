# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidecloq/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidecloq'
  spec.version       = Sidecloq::VERSION
  spec.authors       = ['Matt Robinson']
  spec.email         = ['robinson.matty@gmail.com']

  spec.summary       = 'Recurring / Periodic / Scheduled / Cron job extension for Sidekiq'
  spec.description   = spec.summary
  spec.homepage      = 'http://github.com/mattyr/sidecloq'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|assets)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'sidekiq', '>= 6.5'
  spec.add_dependency 'redlock', '>= 2.0'
  spec.add_dependency 'concurrent-ruby'
  spec.add_dependency 'rufus-scheduler', '>= 3.1'
end
