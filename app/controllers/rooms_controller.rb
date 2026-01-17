class RoomsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :set_accessible_project
  before_action :set_room, only: [:update]
  before_action :require_project_designer

  def create
    room_name = params.dig(:room, :name).to_s.strip

    if room_name.blank?
      return respond_with_error("Room name is required")
    end

    @room = @project.rooms.find_or_initialize_by(name: room_name)
    is_new = @room.new_record?

    if @room.save && attach_plans
      respond_with_success(is_new)
    else
      respond_with_error(@room.errors.full_messages.first || "Could not create room")
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

  def attach_plans
    return true unless params[:room]

    update_params = {}
    update_params[:plan] = params[:room][:plan] if params[:room][:plan].present?
    update_params[:plan_with_products] = params[:room][:plan_with_products] if params[:room][:plan_with_products].present?

    update_params.empty? || @room.update(update_params)
  end

  def respond_with_success(is_new)
    notice = is_new ? "Room '#{@room.name}' created" : "Room plan uploaded"

    respond_to do |format|
      format.html { redirect_to project_path(@project), notice: notice }
      format.json { render json: { id: @room.id, name: @room.name }, status: :created }
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
