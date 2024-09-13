class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # passwordless
  include Passwordless::ControllerHelpers
  before_action :current_user

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  def require_user!
    unless current_user
      save_passwordless_redirect_location!(User)
      redirect_to users_sign_in_path, alert: "You must be logged in to access this page."
      false
    else
      true
    end
  end

  def require_site_admin!
    unless current_user and current_user.site_admin?
      redirect_to users_sign_in_path, alert: "You lack sufficient permissions."
      false
    else
      true
    end
  end
end
