class SessionsController < Passwordless::SessionsController
  before_action :require_unauth!, only: %i[ new show ]
  before_action :set_redirect, only: :new

  def create
    if find_authenticatable
      super
      return
    end
    # Need to create the user
    redirect_to new_user_path(email: normalized_email_param), notice: "Welcome to ScholarLattice! Please complete your new profile below!"
  end

  private

    def set_redirect
      unless params[:redirect_to].nil?
        session[redirect_session_key(User)] = params[:redirect_to]
      end
    end
end
