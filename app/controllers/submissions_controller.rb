class SubmissionsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :submission,
    through: :collection,
    shallow: true,
    except: [ :new_invitations, :create_invitations ]

  # GET /submissions or /submissions.json
  def index
    authorize! :manage, @collection
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
        SubmissionMailer.submission_updated(@submission).deliver_later
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

  def new_invitations
    @invite_info = ""
  end

  def create_invitations
    @invite_info = params.require(:invites)
    invites = @invite_info.split(/[\n,;]+/)
    parsed_invites = invites.map do |invite|
      if invite.match?(/\A[^@\s]+ [^@\s]+ <[^@\s]+@[^@\s]+\z/)
        name, email = invite.strip.split(/ <|>/)
        {
          first_name: name.strip.split(" ").first,
          last_name: name.strip.split(" ").last,
          email: email.strip
        }
      else
        nil
      end
    end
    if parsed_invites.any?(&:nil?)
      flash.now[:alert] = "Could not parse invite info."
      render :new_invitations, status: :unprocessable_entity
    else
      parsed_invites.each do |invite|
        user = User.find_or_create_by(email: invite[:email])
        profile = user.primary_profile
        if profile.nil?
          profile = user.profiles.create!(invite)
        end
        Submission.create!(
          title: "Invited Submission",
          profile: profile,
          collection: @collection,
          status: :invited
        )
      end
      redirect_to collection_submissions_path(@collection),
        notice: "Invitations sent."
    end
  end

  private
    # Only allow a list of trusted parameters through.
    def submission_params
      if can? :manage, @submission
        params.expect(submission: [ :title, :abstract, :notes, :profile_id, :status, :collection_id ])
      else
        params.expect(submission: [ :title, :abstract, :notes, :profile_id ])
      end
    end
end
