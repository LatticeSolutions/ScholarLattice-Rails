class EventsController < ApplicationController
  layout "collections"
  load_and_authorize_resource :collection, except: [ :webinar ]
  load_and_authorize_resource :event, through: :collection, shallow: true, except: [ :webinar, :print ]
  around_action :set_time_zone, except: [ :webinar ]
  before_action :set_collection

  # GET /events or /events.json
  def index
    unless @collection.show_events?
      if can? :manage, @collection
        flash[:alert] = "This collection is configured to not show events to the public."
      else
        redirect_to collection_path(@collection)
        return
      end
    end
    params[:start_date] = params.fetch(
      :start_date,
      (
        @collection.all_scheduled_events.minimum(:starts_at) ||
      Date.today)
    ).to_date.in_time_zone(@collection.inherited_time_zone)
    month_starts_at = params[:start_date].beginning_of_month
    month_ends_at = params[:start_date].end_of_month
    @current_events = @collection.all_top_events.where(
      starts_at: month_starts_at..month_ends_at
    )
    @scheduled_events = @collection.all_scheduled_events
    @unscheduled_events = @collection.all_unscheduled_events
    @happening_soon_events = @collection.all_events.where(
      starts_at: (Time.current - 30.minutes)..(Time.current + 1.hour)
    )
    @happening_soon_events = @happening_soon_events.reject do |event|
      event.descendants.any? { |d| @happening_soon_events.include?(d) }
    end
    @happening_soon_events = @happening_soon_events.reject do |event|
      event.ends_at.present? && (event.ends_at < Time.current)
    end
  end

  # GET /events/1 or /events/1.json
  def show
    if @event.attached_collection.present?
      redirect_to collection_path(@event.attached_collection)
    end
  end

  def webinar
    @event = Event.find(params[:event_id])
    unless @event.inherited(:webinar_link).present?
      redirect_to event_path(@event), alert: "This event does not have a webinar link."
      return
    end
    authorize! :access_webinar, @event, message: "Must have an accepted registration to access this webinar."
    redirect_to_if_allowed @event.inherited(:webinar_link)
  end

  def print
    @scheduled_events = @collection.all_scheduled_events
    @depth = params[:depth].present? ? params[:depth].to_i : 0
    render layout: false
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
    @event.assign_attributes(event_params)
    # reauthorize in case collection changes
    authorize! :create, @event
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

  def new_subevents
  end

  # POST /events or /events.json
  def create_subevents
    number_of_subevents = params[:number_of_subevents]&.to_i || 0
    length_of_each_subevent = params[:length_of_each_subevent]&.to_i || 0
    length_of_break = params[:length_of_break]&.to_i || 0
    same_times = params[:same_times] == "1"
    attach_submissions = params[:attach_submissions] == "1"
    title = (params[:subevent_title] || @event.title).strip
    if number_of_subevents <= 0 || length_of_each_subevent < 0 || length_of_break < 0
      flash[:alert] = "Invalid input values. Please ensure all values are positive."
      render :new_subevents, status: :unprocessable_entity
      return
    end
    if number_of_subevents > 100
      flash[:alert] = "Too many subevents requested. Please request fewer than 100 subevents."
      render :new_subevents, status: :unprocessable_entity
      return
    end
    subevents = []
    number_of_subevents.times do |i|
      subevent = @event.dup
      subevent.parent = @event
      subevent.order = i+1
      if title == subevent.title
        if title.match?(/#(\d+\.)*\d+$/)
          subevent.title = "#{title}.#{subevent.order}"
        else
          subevent.title = "#{title} \##{subevent.order}"
        end
      else
        subevent.title = title
      end
      if !same_times && @event.starts_at.present?
        subevent.starts_at = @event.starts_at + i * length_of_each_subevent.minutes + i * length_of_break.minutes
        if @event.ends_at.present?
          subevent.ends_at = subevent.starts_at + length_of_each_subevent.minutes
        end
      end
      subevents << subevent
    end
    if attach_submissions
      @event.collection.unscheduled_submissions.where(status: :accepted).each_with_index do |s, i|
        if i < subevents.length
          subevents[i].submission = s
        end
      end
    end
    if subevents.any?(&:invalid?)
      flash[:alert] = "Some subevents could not be created due to errors: #{subevents.map(&:errors).map(&:full_messages).join(', ')}"
      render :new_subevents, status: :unprocessable_entity
      return
    end
    subevents.each(&:save!)
    redirect_to @event, notice: "All subevents were successfully created."
  end

  private

    # Only allow a list of trusted parameters through.
    def event_params
      params.expect(event: [
        :title, :description, :content, :location, :starts_at, :ends_at, :collection_id, :parent_id,
        :submission_id, :attached_collection_id, :order, :webinar_link
      ])
    end

    def adjust_datetime_params
      if @event.starts_at.present? && @event.starts_at_changed?
        @event.starts_at = @event.starts_at.asctime.in_time_zone(@event.collection.inherited_time_zone)
      end
      if @event.ends_at.present? && @event.ends_at_changed?
        @event.ends_at = @event.ends_at.asctime.in_time_zone(@event.collection.inherited_time_zone)
      end
    end

    def set_time_zone(&block)
      Time.use_zone(
        @event.present? ?
        @event.collection.inherited_time_zone :
        @collection.inherited_time_zone,
        &block
      )
    end

    def set_collection
      @collection = @event.collection if @event.present?
    end
end
