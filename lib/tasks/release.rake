desc "Release new version"
task :release do
  raise "Please specify new version to release (rake release version=1.3.0)" if ENV['version'].blank?
  version = ENV['version']

  `echo #{version} >> VERSION && git add VERSION && git commit -m 'bumping version to #{version}' && git tag #{version}`
end
