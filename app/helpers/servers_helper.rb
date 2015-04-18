module ServersHelper
  def url_for_user
    server_url(current_user.id)
  end
end
