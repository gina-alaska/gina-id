class WelcomeController < ApplicationController
  def index
    if signed_in?
      @xrds_url = user_xrds_server_url(current_user)
    else
      @xrds_url = xrds_servers_url
    end
    response.headers['X-XRDS-Location'] = @xrds_url
  end
end
