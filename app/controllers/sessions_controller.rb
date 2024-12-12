class SessionsController < Passwordless::SessionsController
  before_action :require_unauth!, only: %i[ new show ]
  before_action :set_redirect, only: :new

  private

    def require_unauth!
      unless @current_user.nil?
        redirect_to dashboard_path, notice: "You are already signed in."
      end
    end

    def set_redirect
      unless params[:redirect_to].nil?
        session[redirect_session_key(User)] = params[:redirect_to]
      end
    end
end
