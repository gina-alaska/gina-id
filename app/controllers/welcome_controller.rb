class WelcomeController < ApplicationController
  def index
    response.headers['X-XRDS-Location'] = xrds_servers_url
  end
end
