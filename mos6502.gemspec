# frozen_string_literal: true

# Copyright (c) 2020 Robert Haines.
#
# Licensed under the BSD License. See LICENCE for details.

require_relative 'lib/mos6502/version'

Gem::Specification.new do |s|
  s.name          = 'mos6502'
  s.version       = Mos6502::VERSION
  s.authors       = ['Robert Haines']
  s.email         = ['robert.haines@manchester.ac.uk']

  s.summary       = 'A 6502 in ruby.'
  #s.description   = %q{TODO: Write a longer description or delete this line.}
  #s.homepage      = "TODO: Put your gem's website or public repo URL here."

  s.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  s.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
  end
  s.bindir        = 'exe'
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'coveralls', '~> 0.8'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'rake', '~> 12.0'
  s.add_development_dependency 'rubocop', '0.93.0'
end
