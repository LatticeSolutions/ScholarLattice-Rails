class QuestionsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :question, through: :collection, shallow: true

  # GET /questions or /questions.json
  def index
  end

  # GET /questions/1 or /questions/1.json
  def show
  end

  # GET /questions/new
  def new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions or /questions.json
  def create
    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: "Question was successfully created." }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1 or /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: "Question was successfully updated." }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1 or /questions/1.json
  def destroy
    c = @question.collection
    @question.destroy!

    respond_to do |format|
      format.html { redirect_to collection_questions_path(c), status: :see_other, notice: "Question was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def question_params
    params.expect(question: [ :name, :prompt ])
  end
end
