namespace :release do
  desc "Bump application version"
  task :bump do
    raise "Please specify new version to release (rake release version=1.3.0)" if ENV['version'].blank?

    version = ENV['version']

    puts "Bumping version to #{version}"
    `set -x && echo #{version} > VERSION && git add VERSION && git commit -m 'bumping version to #{version}' && git tag #{version}`
  end
end
