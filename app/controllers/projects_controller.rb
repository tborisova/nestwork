class ProjectsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :require_designer, only: %i[new create]
  before_action :set_accessible_project, only: %i[update add_client]
  before_action :require_project_designer, only: %i[update add_client]

  def index
    @search_form = Projects::SearchForm.new(current_user, params)
    @search_form.execute
  end

  def show
    @project = Projects::DetailedQuery.new(accessible_projects).find(params[:id])
    @is_designer = designer_for_project?(@project)

    presenter = RoomPresenter.new(@project)
    @rooms_data = presenter.rooms_data
    @project_total = presenter.project_total

    if @is_designer
      existing_client_ids = @project.clients.pluck(:id)
      @available_clients = @project.firm.clients.where.not(id: existing_client_ids).order(:name)
    end
  end

  def new
    @project = Project.new
    @firm = current_user.firm
    return redirect_to projects_path, alert: "You need to be part of a firm to create a project" unless @firm

    @clients = @firm.clients
    @designers = @firm.designers
  end

  def create
    @firm = current_user.firm
    return redirect_to projects_path, alert: "You need to be part of a firm to create a project" unless @firm

    result = Projects::CreateService.new(firm: @firm, params: params).call

    if result.success?
      redirect_to projects_path, notice: "Project created"
    else
      @project = result.project || Project.new
      @clients = @firm.clients
      @designers = @firm.designers
      flash.now[:alert] = result.error || "Could not create project"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      respond_to do |format|
        format.html { redirect_to project_path(@project), notice: "Project updated" }
        format.json { render json: { success: true, status: @project.status } }
      end
    else
      respond_to do |format|
        format.html { redirect_to project_path(@project), alert: @project.errors.full_messages.first || "Could not update project" }
        format.json { render json: { error: @project.errors.full_messages.first || "Could not update project" }, status: :unprocessable_entity }
      end
    end
  end

  def add_client
    client_id = params[:client_id].to_i

    # Verify client belongs to the firm
    unless @project.firm.clients.exists?(id: client_id)
      return render json: { error: "Client not found in your firm" }, status: :unprocessable_entity
    end

    # Check if client is already on project
    if @project.clients.exists?(id: client_id)
      return render json: { error: "Client is already on this project" }, status: :unprocessable_entity
    end

    ProjectClient.create!(project: @project, client_id: client_id)

    respond_to do |format|
      format.html { redirect_to project_path(@project), notice: "Client added to project" }
      format.json { render json: { success: true } }
    end
  rescue ActiveRecord::RecordInvalid => e
    respond_to do |format|
      format.html { redirect_to project_path(@project), alert: e.message }
      format.json { render json: { error: e.message }, status: :unprocessable_entity }
    end
  end

  private

  def project_params
    params.require(:project).permit(:name, :status)
  end
end
