# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = 'shrine-cloudimage'
  s.version = '0.2.0'
  s.authors = ['Jan Klimo']
  s.email = ['jan.klimo@gmail.com']
  s.summary = 'Cloudimage integration for Shrine.'
  s.description = 'Fast and easy image resizing, transformation, and acceleration in the Cloud.'

  s.homepage = 'https://github.com/janklimo/shrine-cloudimage'
  s.files = `git ls-files -- bin lib`.split("\n") + %w[CHANGELOG.md LICENSE.txt README.md]
  s.license = 'MIT'

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/janklimo/shrine-cloudimage/issues',
    'changelog_uri' => 'https://github.com/janklimo/shrine-cloudimage/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/janklimo/shrine-cloudimage',
    'documentation_uri' => 'https://docs.cloudimage.io/go/cloudimage-documentation-v7/en/introduction',
  }

  s.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  s.add_dependency 'cloudimage', '~> 0.6'
  s.add_dependency 'shrine', '>= 2.0', '< 4'

  s.add_development_dependency 'github_changelog_generator', '~> 1.15.2'
  s.add_development_dependency 'pry', '~> 0.13'
end
