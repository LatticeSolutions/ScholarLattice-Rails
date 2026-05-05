class LocationsController < ApplicationController
  layout "collections"
  load_and_authorize_resource :collection
  load_and_authorize_resource :location, through: :collection, shallow: true
  before_action :set_collection

  # GET /locations or /locations.json
  def index
    @locations = Location.where(collection: @collection)
  end

  # GET /locations/1 or /locations/1.json
  def show
  end

  # GET /locations/new
  def new
    @location = Location.new(collection: @collection)
  end

  # GET /locations/1/edit
  def edit
  end

  # POST /locations or /locations.json
  def create
    @location = Location.new(location_params)
    @location.collection = @collection
    if @location.save
      redirect_to @location, notice: "Location was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /locations/1 or /locations/1.json
  def update
    if @location.update(location_params)
      redirect_to @location, notice: "Location was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /locations/1 or /locations/1.json
  def destroy
    @location.destroy!
    redirect_to collection_locations_path(@collection), status: :see_other, notice: "Location was successfully destroyed."
  end

  private
    # Only allow a list of trusted parameters through.
    def location_params
      params.expect(location: [ :title ])
    end

    def set_collection
      @collection = @location.collection if @location.present?
    end
end
