desc "Import legacy users"
task :import_legacy_users => :environment do
  raise "Please specify a file `rake import_legacy_users file=users.json`" if ENV['file'].blank?

  users = JSON.parse(File.read(ENV['file']))
  users.each { |u| LegacyUser.create(u.slice("login", "email", "crypted_password", "salt", "first_name", "last_name", "active", "identity_url")) }

  puts "Imported #{users.count} legacy users"
end
