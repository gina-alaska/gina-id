module ServersHelper
  def url_for_user
    user_identity_url(current_user.slug)
  end
end
