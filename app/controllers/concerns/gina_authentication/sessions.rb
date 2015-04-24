module GinaAuthentication
  module Sessions
    extend ActiveSupport::Concern

    included do
      skip_before_filter :force_password_reset, only: [:destroy]
      skip_before_filter :verify_authenticity_token, :only => :create
    end

    def create
      logger.info auth_hash[:extra][:id_info][:openid_id]
      if @auth = Authorization.find_from_hash(auth_hash)
        # Update a user with any new identify information
        # @auth.user.update_from_hash!(auth_hash)
        if signed_in? && @auth.user != current_user
          flash[:error] = "This identity is already registered with another user account"
          return redirect_back_or_default('/')
        end
      else
        # Create a new user or add an auth to existing user, depending on
        # whether there is already a user signed in.
        @auth = Authorization.create_from_hash(auth_hash, current_user)
      end

      if @auth.new_user? && @auth.user.legacy_user.nil?
        UserMailer.new_user_notification(@auth.user).deliver_later
        if params[:provider] == 'identity'
          url = activate_sessions_url(code: @auth.user.activation_code)
          UserMailer.signup_notification(@auth.user, url).deliver_later
        end
        flash[:success] = "An email has been sent to #{@auth.user.email} with details on how to activate your account."
      else
        flash[:success] = "You have been signed in as #{@auth.user.name}"
      end

      # Log the authorizing user in.
      signin_user(@auth.user)

      if !current_user.id
        flash[:error] = "Unable to create your account, if you have logged in previously using a different method please login using that method instead."
      end

      redirect_back_or_default('/')
    end

    def destroy
      signout
      flash[:notice] = 'You have been signed out'
      redirect_back_or_default('/')
    end

    def failure
      if params[:message] = 'invalid_credentials'
        flash[:error] = "Unable to sign in at this time: Invalid credentials"
      else
        flash[:error] = "Unable to sign in at this time: #{params[:message]}"
      end
      redirect_back_or_default('/')
    end

    protected

    def signin_user(user)
      self.current_user = user
    end

    def signout
      session[:user_id] = nil
    end

    def auth_hash
      request.env['omniauth.auth']
    end
  end
end
