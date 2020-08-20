# frozen_string_literal: true

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |task|
    task.options = ['-D', '-E']
    task.patterns = [
      'lib/**/*.rb',
      'spec/**/*.rb',
      'bin/*',
      '*.gemspec',
      'Gemfile',
      'Rakefile',
    ]
  end
rescue LoadError
  warn 'Rubocop is not available for this version of Ruby.'
end
