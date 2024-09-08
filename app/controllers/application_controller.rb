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
    return if current_user
    save_passwordless_redirect_location!(User)
    redirect_to users_sign_in_path, alert: "You must be logged in to access this page."
  end

  def require_site_admin!
    require_user!
    return if current_user.site_admin?
    redirect_to users_sign_in_path, alert: "You lack sufficient permissions."
  end
end
