class CollectionsController < ApplicationController
  load_and_authorize_resource
  around_action :set_time_zone, only: [ :show ]

  def index
    @collections = Collection.roots
    render layout: "application"
  end

  def show
  end

  def new
    @collection = Collection.new
  end

  def new_subcollection
    @subcollection = Collection.new parent_id: @collection.id
  end

  def create
    adjust_datetime_params
    if @collection.save
      if @collection.parent.present?
        notice = "Subcollection was successfully created."
      else
        notice = "Collection was successfully created."
      end
      redirect_to @collection, notice: notice
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @collection.assign_attributes(collection_params)
    adjust_datetime_params
    if @collection.save
      redirect_to @collection
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy!
    redirect_to collections_path, status: :see_other
  end

  def like
    likes = Like.where collection: @collection, user: @current_user
    if likes.empty?
      Like.create! collection: @collection, user: @current_user
      flash.notice = "#{@collection.short_title} is now a favorite!"
    else
      flash.notice = "#{@collection.short_title} is already a favorite."
    end
    redirect_to @collection
  end

  def dislike
    likes = Like.where collection: @collection, user: @current_user
    if likes.empty?
      flash.notice = "#{@collection.short_title} isn't a favorite."
    else
      likes.destroy_all
      flash.notice = "#{@collection.short_title} is no longer a favorite."
    end
    redirect_to @collection
  end

  def people
    @collection = Collection.find(params[:collection_id])
    authorize! :manage, @collection
  end


  private

    def collection_params
      ps = params.require(:collection).permit(
        :title, :short_title, :description, :content, :parent_id, :subcollection_name,
        :submittable, :admin_emails, :time_zone, :submissions_open_on, :submissions_close_on,
        :order, :show_events, :registerable, :public_webinars, :affiliation_identifier_alias,
        :limit_one_registration_option, :paypal_link, :icon_url, :banner_url, :theme_color
      )
      ps[:theme_color] = nil if params[:collection][:set_theme_color]=="0"
      ps
    end

    def adjust_datetime_params
      if @collection.submissions_open_on.present? && @collection.submissions_open_on_changed?
        @collection.submissions_open_on = @collection.submissions_open_on.asctime.in_time_zone(@collection.inherited_time_zone)
      end
      if @collection.submissions_close_on.present? && @collection.submissions_close_on_changed?
        @collection.submissions_close_on = @collection.submissions_close_on.asctime.in_time_zone(@collection.inherited_time_zone)
      end
    end

    def set_time_zone(&block)
      Time.use_zone(@collection.inherited_time_zone, &block)
    end
end
