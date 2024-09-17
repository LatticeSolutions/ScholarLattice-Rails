class SessionsController < Passwordless::SessionsController
  before_action :require_unauth!, only: %i[ new show ]

  private

    def require_unauth!
      unless @current_user.nil?
        redirect_to dashboard_path, notice: "You are already signed in."
      end
    end
end
