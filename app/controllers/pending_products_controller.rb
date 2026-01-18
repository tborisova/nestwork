class PendingProductsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :set_accessible_project
  before_action :set_room
  before_action :require_project_designer, only: [:new, :create]

  def new
    @pending_product = @room.pending_products.build
    6.times { @pending_product.pending_product_options.build }
  end

  def create
    @pending_product = @room.pending_products.build(pending_product_params)

    if @pending_product.save
      redirect_to project_path(@project), notice: "Pending product added"
    else
      flash.now[:alert] = @pending_product.errors.full_messages.first || "Could not add pending product"
      render :new, status: :unprocessable_entity
    end
  end

  def select_option
    pending_product = @room.pending_products.find(params[:id])
    option = pending_product.pending_product_options.find(params[:option_id])

    result = PendingProducts::SelectOptionService.new(
      pending_product: pending_product,
      option: option
    ).call

    if result.success?
      redirect_to project_path(@project), notice: "Product selected and added"
    else
      redirect_to project_path(@project), alert: result.error
    end
  end

  private

  def set_accessible_project
    @project = find_accessible_project(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    handle_project_not_found
  end

  # Fixed: No longer creates rooms as a side effect.
  # Room must exist or be explicitly created first.
  def set_room
    room_name = params[:room].presence || "Default"
    @room = @project.rooms.find_by(name: room_name)

    unless @room
      # Only create room if this is a create/new action and user is a designer
      if %w[new create].include?(action_name) && designer_for_project?
        @room = @project.rooms.create!(name: room_name)
      else
        redirect_to project_path(@project), alert: "Room '#{room_name}' not found"
      end
    end
  end

  def pending_product_params
    params.require(:pending_product).permit(
      :name,
      :quantity,
      pending_product_options_attributes: [:id, :name, :link, :price, :_destroy]
    )
  end
end
