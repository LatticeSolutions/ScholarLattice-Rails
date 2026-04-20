class SubmissionsController < ApplicationController
  layout "collections"
  load_and_authorize_resource :collection, except: [ :index, :upload, :import ]
  load_resource :collection, only: [ :index, :upload, :import ]
  load_and_authorize_resource :submission, through: :collection, shallow: true, except: [ :index, :create, :upload, :import ]
  before_action :set_collection

  def index
    @submissions = @collection.subtree_submissions
    respond_to do |format|
      format.html
      format.csv { send_data @submissions.to_csv, filename: "submissions-#{@collection.short_title.underscore}-#{DateTime.now.strftime('%Q')}.csv" }
    end
  end

  def show
    if can? :manage, @collection
      @registrations = Registration.where(user: @submission.user, collection: @submission.collection.path)
    end
  end

  def new
    @submission.user = @current_user
  end

  # GET /submissions/1/edit
  def edit
  end

  def create
    @submission = Submission.new(collection: @collection)
    changed_user_email = params[:user][:email] if params[:user].present?
    if (can? :manage, @collection) && changed_user_email.present?
      changed_user = User.find_by(email: changed_user_email)
      if changed_user.present?
        flash[:notice] = "Now creating submission for existing user with email #{changed_user_email}."
        @submission.user = changed_user
      else
        flash[:notice] = "Now creating submission for new user with email #{changed_user_email}."
        @submission.user = User.new(email: changed_user_email)
      end
      render :new and return
    end
    @submission.assign_attributes(submission_params)
    only_admins_can_manage_other_users
    respond_to do |format|
      if @submission.save
        SubmissionMailer.submission_created(@submission).deliver_later
        format.html { redirect_to @submission, notice: "Submission was successfully created." }
        format.json { render :show, status: :created, location: @submission }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    changed_user_email = params[:user][:email] if params[:user].present?
    if (can? :manage, @submission.collection) && changed_user_email.present?
      changed_user = User.find_by(email: changed_user_email)
      if changed_user.present?
        if @submission.update(user: changed_user)
          flash[:notice] = "Submitter email updated successfully."
          redirect_to edit_submission_path(@submission) and return
        else
          flash[:alert] = "Failed to update submitter email: #{@submission.errors.full_messages.join(', ')}"
          render :edit and return
        end
      else
        flash[:notice] = "Editing submission for new user with email #{changed_user_email}."
        @submission.user = User.new(email: changed_user_email)
        render :edit and return
      end
    end
    @submission.assign_attributes(submission_params)
    only_admins_can_manage_other_users
    respond_to do |format|
      if @submission.save
        if send_update_notification?
          SubmissionMailer.submission_updated(@submission).deliver_later
        end
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
    c = @submission.collection
    @submission.destroy!

    respond_to do |format|
      format.html { redirect_to collection_path(c), status: :see_other, notice: "Submission was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def upload
    authorize! :manage, @collection
  end

  def import
    authorize! :manage, @collection
    submissions_csv = params[:file]
    submission_csv_data = params[:submission_csv_data]
    @submission_param_symbols = [
      :title, :abstract, :notes, :private_notes, :submitter_email, :submitter_first_name, :submitter_last_name,
      :submitter_affiliation, :submitter_position
    ]
    if submissions_csv.present?
      require "csv"
      begin
        csv_table = CSV.read(submissions_csv, headers: true)
        @submission_data_array = csv_table.map(&:to_hash)
        @submission_data_headers = CSV.read(submissions_csv, headers: true).headers.reject(&:blank?)
        @submission_data_header_selections = [ [ "(none)", nil ] ] +
          @submission_data_headers.map { |h| [ "#{h} (#{@submission_data_array.first[h]&.truncate(40)})", h ] }
      rescue => e
        flash[:alert] = "Error reading CSV file: #{e.message}"
        redirect_to collection_submissions_upload_path(@collection) and return
      end
      render :import and return
    elsif submission_csv_data.present?
      users_to_save = []
      submissions_to_save = []
      user_cache = {}
      JSON.parse(submission_csv_data).each do |row|
        next if row[params[:submitter_email_header]].blank?
        email = row[params[:submitter_email_header]]
        u = user_cache[email] || User.find_or_initialize_by(email: email)
        if u.new_record? && !user_cache[email]
          u.assign_attributes(
            first_name: row[params[:submitter_first_name_header]] || "Unknown",
            last_name: row[params[:submitter_last_name_header]] || "Unknown",
            affiliation: row[params[:submitter_affiliation_header]] || "Unknown",
            position: row[params[:submitter_position_header]] || "Unknown",
            position_type: :other,
          )
          users_to_save << u
        end
        user_cache[email] = u
        submissions_to_save << @collection.submissions.build(
          title: row[params[:title_header]],
          abstract: row[params[:abstract_header]],
          notes: row[params[:notes_header]],
          private_notes: row[params[:private_notes_header]],
          user: u,
          status: params[:status] || :submitted,
        )
      end
      invalid_users = users_to_save.reject(&:valid?)
      invalid_submissions = submissions_to_save.reject(&:valid?)
      if invalid_users.any? || invalid_submissions.any?
        error_messages = []
        error_messages += invalid_users.map { |u| "User #{u.email}: #{u.errors.full_messages.join(', ')}" }
        error_messages += invalid_submissions.map { |s| "Submission #{s.title}: #{s.errors.full_messages.join(', ')}" }
        flash[:alert] = "Some records could not be imported: #{error_messages.join('; ')}"
        @submission_data_array = JSON.parse(submission_csv_data)
        @submission_data_headers = @submission_data_array.first.keys.reject(&:blank?)
        @submission_data_header_selections = [ [ "(none)", nil ] ] +
          @submission_data_headers.map { |h| [ "#{h} (#{@submission_data_array.first[h]&.truncate(40)})", h ] }
        render :import and return
      end
      users_to_save.each(&:save!)
      submissions_to_save.each(&:save!)
      flash[:alert] = "Submissions have been imported."
      redirect_to collection_submissions_path(@collection) and return
    else
      flash[:alert] = "Please select a CSV file to upload."
      redirect_to collection_submissions_upload_path(@collection) and return
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def submission_params
      if can? :manage, @submission
        params.expect(submission: [ :title, :coauthors, :abstract, :notes, :private_notes, :status, :collection_id, :user_id, user_attributes: [ :id, :first_name, :last_name, :email, :affiliation, :position_type, :position, :affiliation_identifier ] ])
      else
        params.expect(submission: [ :title, :coauthors, :abstract, :notes, :private_notes, :user_id, user_attributes: [ :id, :first_name, :last_name, :email, :affiliation, :position_type, :position, :affiliation_identifier ] ])
      end
    end

    def admin_user_params
      params.expect(user: [ :email ])
    end

    def only_admins_can_manage_other_users
      if @submission.user != @current_user && cannot?(:manage, @submission.collection)
        @submission.errors.add(:user, "must be yourself")
      end
    end

    def send_update_notification?
      if can? :manage, @submission
        return params[:submission][:send_notification] == "1"
      end
      false
    end

    def set_collection
      @collection = @submission.collection if @submission.present?
    end
end
