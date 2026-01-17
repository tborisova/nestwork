class RoomsController < ApplicationController
  before_action :require_login
  before_action :set_project
  before_action :set_room, only: [ :update ]
  before_action :require_designer

  def create
    room_name = params[:room][:name].to_s.strip
    if room_name.blank?
      respond_to do |format|
        format.html { redirect_to project_path(@project), alert: "Room name is required" }
        format.json { render json: { error: "Room name is required" }, status: :unprocessable_entity }
      end
      return
    end

    @room = @project.rooms.find_or_initialize_by(name: room_name)
    is_new = @room.new_record?

    update_params = {}
    update_params[:plan] = params[:room][:plan] if params[:room][:plan].present?
    update_params[:plan_with_products] = params[:room][:plan_with_products] if params[:room][:plan_with_products].present?

    if @room.save && (update_params.empty? || @room.update(update_params))
      respond_to do |format|
        notice = is_new ? "Room '#{@room.name}' created" : "Room plan uploaded"
        format.html { redirect_to project_path(@project), notice: notice }
        format.json { render json: { id: @room.id, name: @room.name }, status: :created }
      end
    else
      respond_to do |format|
        format.html { redirect_to project_path(@project), alert: @room.errors.full_messages.first || "Could not create room" }
        format.json { render json: { error: @room.errors.full_messages.first || "Could not create room" }, status: :unprocessable_entity }
      end
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

  def require_login
    redirect_to new_session_path, alert: "You need to sign in first" unless current_user
  end

  def set_project
    firm_ids = current_user.firms.select(:id)
    @project = Project.where(firm_id: firm_ids)
                      .or(Project.where(id: current_user.client_projects.select(:id)))
                      .find(params[:project_id])
  end

  def set_room
    @room = @project.rooms.find(params[:id])
  end

  def require_designer
    unless current_user.designer_for_project?(@project)
      redirect_to project_path(@project), alert: "Only designers can manage rooms"
    end
  end

  def room_params
    params.require(:room).permit(:plan, :plan_with_products)
  end
end
