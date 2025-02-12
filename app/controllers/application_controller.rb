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
    return true if current_user
    save_passwordless_redirect_location!(User)
    redirect_to users_sign_in_path, alert: "You must be logged in to access this page."
    false
  end

  def require_profile!
    require_user! or return false
    return true unless @current_user.profiles.empty?
    redirect_to new_profile_path, alert: "You must create a profile."
    false
  end

  def require_site_admin!
    require_user! or return false
    return true if current_user.site_admin?
    redirect_to root_path, alert: "You lack sufficient permissions."
    false
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.json { head :forbidden }
      if current_user
        format.html { redirect_to dashboard_path, alert: exception.message }
      else
        format.html { redirect_to users_sign_in_path, alert: "You must be logged in to access this page." }
      end
    end
  end
end
