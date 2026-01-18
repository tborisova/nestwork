class RoomsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :set_accessible_project
  before_action :set_room, only: [:update]
  before_action :require_project_designer

  def create
    result = Rooms::CreateWithPlansService.new(project: @project, params: params).call

    if result.success?
      respond_with_success(result.room, result.created?)
    else
      respond_with_error(result.error || "Could not create room")
    end
  end

  def update
    if @room.update(room_params)
      redirect_to project_path(@project), notice: "Room plan uploaded"
    else
      redirect_to project_path(@project), alert: @room.errors.full_messages.first || "Could not upload plan"
    end
  end

  private

  def set_accessible_project
    @project = find_accessible_project(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    handle_project_not_found
  end

  def set_room
    @room = @project.rooms.find(params[:id])
  end

  def respond_with_success(room, is_new)
    notice = is_new ? "Room '#{room.name}' created" : "Room plan uploaded"

    respond_to do |format|
      format.html { redirect_to project_path(@project), notice: notice }
      format.json { render json: { id: room.id, name: room.name }, status: :created }
    end
  end

  def respond_with_error(message)
    respond_to do |format|
      format.html { redirect_to project_path(@project), alert: message }
      format.json { render json: { error: message }, status: :unprocessable_entity }
    end
  end

  def room_params
    params.require(:room).permit(:plan, :plan_with_products)
  end
end
