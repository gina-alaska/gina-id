module GinaAuthentication
  module Users
    extend ActiveSupport::Concern

    included do
      skip_before_filter :force_password_reset, only: [:update, :forgot_password, :send_reset_instructions, :reset_password]
    end

    def disable_provider
      current_user.authorizations.where(provider: params[:provider]).first.try(:destroy)
      redirect_to root_path
    end
  end
end
