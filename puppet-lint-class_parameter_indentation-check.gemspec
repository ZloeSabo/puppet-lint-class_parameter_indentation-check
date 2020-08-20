# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = 'puppet-lint-trailing_newline-check'
  spec.version     = '1.0.0'
  spec.homepage    = 'https://github.com/rodjek/puppet-lint-trailing_newline-check'
  spec.license     = 'MIT'
  spec.author      = 'Evgeny Soynov'
  spec.email       = 'saboteur@saboteur.me'
  spec.required_ruby_version = '>= 2.4.0'
  spec.files = Dir[
    'README.md',
    'LICENSE',
    'lib/**/*',
    'spec/**/*',
  ]
  spec.test_files  = Dir['spec/**/*']
  spec.summary     = 'A puppet-lint plugin to check file endings.'
  spec.description = <<-DESC
      A puppet-lint plugin to check that manifest files end with a newline.
  DESC

  spec.add_dependency             'puppet-lint', '~> 1.0'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'solargraph'
end
