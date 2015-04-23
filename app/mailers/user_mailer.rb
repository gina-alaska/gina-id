class UserMailer < ApplicationMailer
  layout 'mailer'

  def reset_password(user, reset_url)
    @user = user
    @reset_url = reset_url

    mail(to: user.email, subject: "[GINA::ID] Reset your GINA::ID password")
  end

  def new_user_notification(user)
    @user = user
    mail(to: ['will@gina.alaska.edu', 'dayne@gina.alaska.edu'], subject: "[GINA::ID] New user acccount created")
  end

  def signup_notification(user, activation_url)
    @activation_url = activation_url
    @user = user
    mail(to: user.email, subject: "[GINA::ID] New account verification")
  end

  def password_update_notification(user, url)
    @user = user
    @url = url
    mail(to: user.email, subject: "[GINA::ID] Your password has been changed")
  end

  def email_confirmation(user, activation_url)
    @activation_url = activation_url
    @user = user
    mail(to: user.email, subject: "[GINA::ID] New email confirmation")
  end
end
