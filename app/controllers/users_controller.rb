class UsersController < ApplicationController
  include GinaAuthentication::Users

  def index
    return redirect_to root_url unless signed_in?

    save_current_location
    @user = current_user
  end

  def forgot_password
  end

  def send_reset_instructions
    @user = User.where('email ilike :email', email: params[:email]).first

    if @user.nil? && (legacy = legacy_user(params[:email]))
      @user = User.create_from_legacy_user(legacy)
    end

    if @user.present?
      if @user.identity.present?
        @user.create_password_reset_code!
        reset_url = reset_password_users_url(reset_code: @user.reset_code)
        UserMailer.reset_password(@user, reset_url).deliver_later
      else
        # TODO: Add instructions for users that don't have a password
      end
    end

    redirect_to root_path, notice: "An email will be sent to #{params[:email]} with instructions for resetting your password"
  end

  def reset_password
    if reset_code_valid?
      reset_code_user.update_attribute(:force_password_reset, true)
      self.current_user = reset_code_user unless signed_in?
    elsif reset_code_given?
      return failed_password_reset
    elsif !signed_in?
      return failed_password_reset("You must be logged into to reset your password")
    end
    @user = current_user
  end

  def update
    @user = current_user

    respond_to do |format|
      if @user.update_attributes(user_params)
        if @user.identity && @user.identity.previous_changes['password_digest'].present?
          @user.clear_password_reset_code!
          UserMailer.password_update_notification(@user, root_url).deliver_later
        end

        if @user.previous_changes['email'].present?
          @user.verify!
          url = verify_sessions_url(code: @user.activation_code)
          UserMailer.email_confirmation(@user, url).deliver_later
          flash[:notice] = "An email has been sent to #{@user.email} to confirm you new address"
        end

        flash[:success] = "Successfully updated account info"
        format.html { redirect_to users_path }
      else
        format.html { render 'edit' }
      end
    end
  end

  def confirm_migration
    @user = current_user

    @user.legacy_user.update_attribute(:active, false)

    redirect_to root_url
  end

  private

  def legacy_user(email)
    LegacyUser.where('email ilike :email', email: email).first
  end

  def reset_code_user
    return nil unless reset_code_given?
    @reset_code_user ||= User.where(reset_code: params[:reset_code]).first
  end

  def reset_code_given?
    params[:reset_code].present?
  end

  def reset_code_valid?
    return false unless reset_code_given?

    signed_in? ? reset_code_belongs_to_current_user? : reset_code_user.present?
  end

  def reset_code_belongs_to_current_user?
    current_user == reset_code_user
  end

  def failed_password_reset(message = "Invalid or expired reset code")
    flash[:error] = message
    redirect_to root_path
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :current_password)
  end
end
