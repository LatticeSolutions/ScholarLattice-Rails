class SubmissionsController < ApplicationController
  before_action :set_submission, only: %i[ show edit update destroy ]
  before_action :set_collection, only: %i[ new create index ]

  # GET /submissions or /submissions.json
  def index
    require_collection_admin!
    @submissions = @collection.submissions
  end

  # GET /submissions/1 or /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
    require_user!
    @submission = Submission.new(collection: @collection)
  end

  # GET /submissions/1/edit
  def edit
    require_admin!(@submission)
  end

  # POST /submissions or /submissions.json
  def create
    @submission = Submission.new(submission_params)
    @submission.collection = @collection
    require_admin!(@submission)

    respond_to do |format|
      if @submission.save
        format.html { redirect_to @submission, notice: "Submission was successfully created." }
        format.json { render :show, status: :created, location: @submission }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    require_admin!(@submission)
    respond_to do |format|
      if @submission.update(submission_params)
        format.html { redirect_to @submission, notice: "Submission was successfully updated." }
        format.json { render :show, status: :ok, location: @submission }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /submissions/1 or /submissions/1.json
  def destroy
    require_site_admin!
    c = @submission.collection
    @submission.destroy!

    respond_to do |format|
      format.html { redirect_to collection_path(c), status: :see_other, notice: "Submission was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_submission
      @submission = Submission.find(params.expect(:id))
    end

    def set_collection
      @collection = Collection.find(params.expect(:collection_id))
    end

    # Only allow a list of trusted parameters through.
    def submission_params
      params.expect(submission: [ :title, :abstract, :notes, :profile_id, :status ])
    end

    def require_collection_admin!
      if @current_user.nil?
        save_passwordless_redirect_location!(User)
        redirect_to users_sign_in_path, alert: "You must be logged in to access this page."
      else
        return if @current_user.site_admin or @collection.has_admin? @current_user
        redirect_to collection_path(submission.collection), alert: "You are not authorized to access this page."
      end
    end

    def require_admin!(submission)
      if @current_user.nil?
        save_passwordless_redirect_location!(User)
        redirect_to users_sign_in_path, alert: "You must be logged in to access this page."
      else
        return if submission.has_admin? @current_user
        redirect_to collection_path(submission.collection), alert: "You are not authorized to access this page."
      end
    end
end
