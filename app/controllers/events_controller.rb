class EventsController < ApplicationController
  load_and_authorize_resource :collection
  load_and_authorize_resource :event, through: :collection, shallow: true
  before_action :set_time_zone

  # GET /events or /events.json
  def index
    params[:start_date] = params.fetch(:start_date, (@collection.all_events.minimum(:starts_at) || Date.today)).to_date.in_time_zone(@collection.inherited_time_zone)
    month_starts_at = params[:start_date].beginning_of_month
    month_ends_at = params[:start_date].end_of_month
    @events = @collection.all_events.where(
      starts_at: month_starts_at..month_ends_at
    )
    @unscheduled_events = @collection.all_events.where(
      starts_at: nil
    )
  end

  # GET /events/1 or /events/1.json
  def show
  end

  # GET /events/new
  def new
  end

  # GET /events/1/edit
  def edit
  end

  # GET /events/1/copy
  def copy
    @event = @event.dup
    @collection = @event.collection
    render :new
  end

  # POST /events or /events.json
  def create
    adjust_datetime_params
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /events/1 or /events/1.json
  def update
    @event.assign_attributes(event_params)
    adjust_datetime_params
    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1 or /events/1.json
  def destroy
    c = @event.collection
    @event.destroy!

    respond_to do |format|
      format.html { redirect_to collection_events_path(c), status: :see_other, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Only allow a list of trusted parameters through.
    def event_params
      params.expect(event: [ :title, :description, :location, :starts_at, :ends_at, :collection_id, :parent_id ])
    end

    def adjust_datetime_params
      if @event.starts_at.present? && @event.starts_at_changed?
        @event.starts_at = @event.starts_at.asctime.in_time_zone(@event.collection.inherited_time_zone)
      end
      if @event.ends_at.present? && @event.ends_at_changed?
        @event.ends_at = @event.ends_at.asctime.in_time_zone(@event.collection.inherited_time_zone)
      end
    end

    def set_time_zone
      Time.zone = @event.present? ? @event.collection.inherited_time_zone : @collection.inherited_time_zone
    end
end
