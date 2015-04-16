require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
  # provider :developer unless Rails.env.production?
  provider :google_oauth2, Rails.application.secrets.google_client_id, Rails.application.secrets.google_client_secret, {
    name: "google",
    scope: "email, profile",
    image_aspect_ratio: "square",
    image_size: 50# ,
    # prompt: 'consent'
  }
  provider :identity, fields: [:email, :name],
                      on_failed_registration: ->(env) {
                        IdentitiesController.action(:new).call(env)
                      }
  # provider :github, ENV['GITHUB_KEY'], ENV['GITHUB_SECRET']
  # provider :openid, :store => OpenID::Store::Filesystem.new("./tmp"), :name => 'gina', :identifier => 'https://id.gina.alaska.edu'
end
OmniAuth.config.logger = Rails.logger
