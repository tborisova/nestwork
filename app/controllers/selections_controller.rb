class SelectionsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :set_accessible_project
  before_action :set_room
  before_action :require_project_designer, only: [:new, :create]

  def new
    @selection = @room.selections.build
    6.times { @selection.selection_options.build }
  end

  def create
    @selection = @room.selections.build(selection_params)

    if @selection.save
      redirect_to project_path(@project), notice: "Selection added"
    else
      flash.now[:alert] = @selection.errors.full_messages.first || "Could not add selection"
      render :new, status: :unprocessable_entity
    end
  end

  def select_option
    selection = @room.selections.find(params[:id])
    option = selection.selection_options.find(params[:option_id])

    ActiveRecord::Base.transaction do
      Product.create!(
        room: @room,
        name: "#{selection.name} - #{option.name}",
        link: option.link,
        price: option.price,
        quantity: selection.quantity || 1,
        status: "pending"
      )

      selection.destroy!
    end

    redirect_to project_path(@project), notice: "Product selected and added"
  rescue ActiveRecord::RecordInvalid => e
    redirect_to project_path(@project), alert: e.message
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

  def selection_params
    params.require(:selection).permit(
      :name,
      :quantity,
      selection_options_attributes: [:id, :name, :link, :price, :_destroy]
    )
  end
end
