class SelectionsController < ApplicationController
  before_action :require_login
  before_action :set_project
  before_action :set_room
  before_action :require_designer, only: [:new, :create]

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

    Product.create!(
      room: @room,
      name: "#{selection.name} - #{option.name}",
      link: option.link,
      price: option.price,
      quantity: selection.quantity || 1,
      status: "pending"
    )

    selection.destroy

    redirect_to project_path(@project), notice: "Product selected and added"
  end

  private

  def require_login
    redirect_to new_session_path, alert: "You need to sign in first" unless current_user
  end

  def set_project
    firm_ids = current_user.firms.select(:id)
    @project = Project.where(firm_id: firm_ids)
                      .or(Project.where(id: current_user.client_projects.select(:id)))
                      .find(params[:project_id])
  end

  def require_designer
    unless current_user.designer_for_project?(@project)
      redirect_to project_path(@project), alert: "Only designers can add products"
    end
  end

  def set_room
    room_name = params[:room] || "Default"
    @room = @project.rooms.find_or_create_by!(name: room_name)
  end

  def selection_params
    params.require(:selection).permit(
      :name,
      :quantity,
      selection_options_attributes: [:id, :name, :link, :price, :_destroy]
    )
  end
end
