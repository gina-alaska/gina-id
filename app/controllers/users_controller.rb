class UsersController < ApplicationController
  include GinaAuthentication::Users

  def show
    return redirect_to root_url unless signed_in?

    save_current_location
    @user = current_user
    render 'edit'
  end

  def forgot_password
  end

  def send_reset_instructions
    @user = User.where('email ilike :email', email: params[:email]).first

    if @user.nil? or @user.identity.nil?
      flash[:error] = 'Not account was found with that email address'
      redirect_to forgot_password_user_path
    else
      @user.create_password_reset_code!
      UserMailer.reset_password(@user, reset_password_user_url(reset_code: @user.reset_code)).deliver_later
      redirect_to root_path, notice: "An email has been sent to #{params[:email]} with instructions for resettting your password"
    end
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
        @user.clear_password_reset_code!
        flash[:success] = "Successfully updated account info"
        format.html { redirect_to user_path }
      else
        format.html { render 'edit' }
      end
    end
  end

  private

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
