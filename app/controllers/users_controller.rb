class UsersController < ApplicationController
  load_and_authorize_resource :collection

  # GET /users or /users.json
  def index
    redirect_to(dashboard_path)
  end

  # # GET /users/1 or /users/1.json
  # def show
  # end

  # GET /users/new
  def new
    require_unauth!
    @user = User.new(
      email: params[:email],
      first_name: nil,
      last_name: nil,
      affiliation: nil,
      position: nil,
      position_type: nil,
    )
  end

  # # GET /users/1/edit
  # def edit
  # end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)
    @session = build_passwordless_session(@user)

    respond_to do |format|
      if @user.save && @session.save
        unless @current_user.present?
          if Passwordless.config.after_session_save.arity == 2
            Passwordless.config.after_session_save.call(@session, request)
          else
            Passwordless.config.after_session_save.call(@session)
          end
          redirect_to(
            Passwordless.context.path_for(
              @session,
              id: @session.to_param,
              action: "show",
              **default_url_options
            ),
            flash: { notice: "Verify your email to complete your profile and sign in." }
          )
          return
        end
        format.html { redirect_to @user, notice: "User was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # # PATCH/PUT /users/1 or /users/1.json
  # def update
  #   respond_to do |format|
  #     if @user.update(user_params)
  #       format.html { redirect_to @user, notice: "User was successfully updated." }
  #       format.json { render :show, status: :ok, location: @user }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /users/1 or /users/1.json
  # def destroy
  #   @user.destroy!

  #   respond_to do |format|
  #     format.html { redirect_to users_path, status: :see_other, notice: "User was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Only allow a list of trusted parameters through.
    def user_params
      params.expect(user: [ :email, :first_name, :last_name, :affiliation, :position, :position_type, :affiliation_identifier ])
    end
end
