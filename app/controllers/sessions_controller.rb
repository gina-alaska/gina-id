class SessionsController < ApplicationController
  protect_from_forgery :except => [:create, :failure]
  include GinaAuthentication::Sessions

  def new
  end

  def verify
    user = User.where(activation_code: params[:code]).first

    if signed_in? && current_user != user
      flash[:error] = "Unable to activate your account at this time, please log out and try again"
    elsif !user.nil?
      flash[:notice] = "Your account has now been verified"
      user.verified!
      signin_user(user)
    else
      flash[:error] = "There was an error verifying your account, the activation code was invalid."
    end

    redirect_to root_url
  end
end
