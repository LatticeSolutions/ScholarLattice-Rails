class SessionsController < Passwordless::SessionsController
  before_action :require_unauth!, only: %i[ new show ]

  protected

  def passwordless_success_redirect_path(current_user)
    if current_user.profiles.empty?
      new_profile_path
    else
      dashboard_path
    end
  end

  private

    def require_unauth!
      unless @current_user.nil?
        redirect_to dashboard_path, notice: "You are already signed in."
      end
    end
end
