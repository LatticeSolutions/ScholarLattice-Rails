class SessionsController < Passwordless::SessionsController
  before_action :set_redirect, only: :new

  def create
    if find_authenticatable
      return super
    end
    # Need to create the user
    redirect_to new_user_path(email: normalized_email_param),
      notice: "Welcome to ScholarLattice! Please complete your new profile below!"
  end

  private

  def set_redirect
    session[redirect_session_key(User)] = params[:redirect] if params[:redirect].present?
  end
end
