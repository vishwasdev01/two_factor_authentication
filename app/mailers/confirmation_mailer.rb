class ConfirmationMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Account successfully created')
  end

  def send_otp(user)
    @user = user
    mail(to: @user.email, subject: 'OTP confirmation')
  end
end
