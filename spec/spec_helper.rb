# frozen_string_literal: true

require 'bundler/setup'
require 'pry' unless ENV['CI']
require 'shrine'
require 'cloudimage'

# JRuby seems to report incorrect, lower stats.
unless RUBY_ENGINE == 'jruby'
  require 'simplecov'

  SimpleCov.start do
    minimum_coverage 95
    maximum_coverage_drop 1
    add_filter(/spec|refinements/)
  end
end

RSpec.configure do |config|
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
  end
end
