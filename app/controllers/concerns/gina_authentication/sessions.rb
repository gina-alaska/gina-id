module GinaAuthentication
  module Sessions
    extend ActiveSupport::Concern

    included do
      skip_before_filter :force_password_reset, only: [:destroy]
    end

    def create
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

      # Log the authorizing user in.
      signin_user(@auth.user)

      if current_user.id
        flash[:success] = "Succesfully signed in as #{current_user.name}"
      else
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
