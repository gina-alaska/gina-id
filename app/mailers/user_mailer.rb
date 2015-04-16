class UserMailer < ApplicationMailer
  def reset_password(user, reset_url)
    @user = user
    @reset_url = reset_url

    mail(to: user.email, subject: "[GINA::ID] Reset your GINA::ID password")
  end
end
