class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # passwordless
  include Passwordless::ControllerHelpers
  before_action :current_user
  before_action :first_profile_redirect

  private

  def current_user
    @current_user ||= authenticate_by_session(User)
  end

  def first_profile_redirect
    if current_user &&
        current_user.profiles.empty? &&
        !request.path.include?("/profiles") &&
        !request.path.include?("/users")
      flash[:notice] = "Please create your profile to continue."
      redirect_to new_profile_path
    end
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
