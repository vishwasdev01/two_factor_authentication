class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  before_action :set_current_session
  protected
  def require_auth
      unless current_user
          redirect_to root_path
      end
  end
  def verify_otp_status
      if session[:user_id].present? && !session[:otp_passed] && @user.otp_enabled
          redirect_to otp_path
      end
  end
  private
  def set_current_session
      @user = current_user
  end
  def current_user
      session[:user_id].present? ? User.find_by(id: session[:user_id]) : nil
  end
end
