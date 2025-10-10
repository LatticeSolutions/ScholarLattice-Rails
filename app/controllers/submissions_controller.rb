class SubmissionsController < ApplicationController
  load_and_authorize_resource :collection, except: [ :index, :upload, :import ]
  load_resource :collection, only: [ :index, :upload, :import ]
  load_and_authorize_resource :submission, through: :collection, shallow: true, except: [ :index, :upload, :import ]

  # GET /submissions or /submissions.json
  def index
    @submissions = @collection.subtree_submissions
    respond_to do |format|
      format.html
      format.csv { send_data @submissions.to_csv, filename: "submissions-#{@collection.short_title.underscore}-#{DateTime.now.strftime('%Q')}.csv" }
    end
  end

  # GET /submissions/1 or /submissions/1.json
  def show
  end

  # GET /submissions/new
  def new
  end

  # GET /submissions/1/edit
  def edit
  end

  # POST /submissions or /submissions.json
  def create
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

  # PATCH/PUT /submissions/1 or /submissions/1.json
  def update
    respond_to do |format|
      if @submission.update(submission_params)
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
      format.html { redirect_to collection_path(c), status: :see_other, notice: "Submission was successfully destroyed." }
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
            position_type: :faculty,
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
        params.expect(submission: [ :title, :abstract, :notes, :private_notes, :user_id, :status, :collection_id ])
      else
        params.expect(submission: [ :title, :abstract, :notes, :private_notes, :user_id ])
      end
    end

    def send_update_notification?
      if can? :manage, @submission
        return params[:submission][:send_notification] == "1"
      end
      false
    end
end
