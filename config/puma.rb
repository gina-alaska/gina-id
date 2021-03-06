workers Integer(ENV['WEB_CONCURRENCY'] || 2)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

# preload_app!
prune_bundler

rackup      DefaultRackup
port        ENV['PORT']     || 9292
environment ENV['RAILS_ENV'] || 'development'
pidfile     ENV['PUMA_PIDFILE'] || '/var/run/puma.pid'

on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  # ActiveRecord::Base.establish_connection
end
