class ProjectsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :require_designer, only: [:new, :create]
  before_action :set_accessible_project, only: [:update, :add_client]
  before_action :require_project_designer, only: [:update, :add_client]

  def index
    @is_designer = current_user_is_designer?

    if @is_designer
      load_filter_options
    end

    @projects = build_filtered_projects
  end

  def show
    @project = load_project_with_associations
    @is_designer = designer_for_project?(@project)

    presenter = RoomPresenter.new(@project)
    @rooms_data = presenter.rooms_data
    @project_total = presenter.project_total

    # Load available clients for invite (firm clients not already on project)
    if @is_designer
      existing_client_ids = @project.clients.pluck(:id)
      @available_clients = @project.firm.clients.where.not(id: existing_client_ids).order(:name)
    end
  end

  def new
    @project = Project.new
    @firm = current_user.firms.first
    return redirect_to projects_path, alert: "You need to be part of a firm to create a project" unless @firm

    @clients = @firm.clients
    @designers = @firm.designers
  end

  def create
    @firm = current_user.firms.first
    return redirect_to projects_path, alert: "You need to be part of a firm to create a project" unless @firm

    @project = @firm.projects.build(project_params)

    ActiveRecord::Base.transaction do
      @project.save!
      assign_project_members
    end

    redirect_to projects_path, notice: "Project created"
  rescue ActiveRecord::RecordInvalid => e
    @clients = @firm&.clients || User.none
    @designers = @firm&.designers || User.none
    flash.now[:alert] = e.record.errors.full_messages.first || "Could not create project"
    render :new, status: :unprocessable_entity
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

  def load_filter_options
    firm_ids = current_user.firms.select(:id)

    @filter_designers = User.joins(:firms_designers)
                            .where(firms_designers: { firm_id: firm_ids })
                            .distinct.order(:name)

    @filter_clients = User.joins(:firms_clients)
                          .where(firms_clients: { firm_id: firm_ids })
                          .distinct.order(:name)
  end

  def build_filtered_projects
    projects = accessible_projects

    # Apply filters
    projects = projects.by_status(params[:status])
    projects = projects.search_by_name(params[:name])

    if params[:designer_ids].present?
      designer_ids = Array(params[:designer_ids]).reject(&:blank?).map(&:to_i)
      projects = projects.with_designer(designer_ids) if designer_ids.any?
    end

    if params[:client_ids].present?
      client_ids = Array(params[:client_ids]).reject(&:blank?).map(&:to_i)
      projects = projects.with_client(client_ids) if client_ids.any?
    end

    projects.includes(:designers, :clients, :firm)
            .distinct
            .ordered_by_status
  end

  def load_project_with_associations
    accessible_projects
      .includes(
        :designers,
        :clients,
        rooms: [
          { products: :comments },
          { pending_products: [:pending_product_options, :comments] },
          :comments,
          { plan_attachment: :blob },
          { plan_with_products_attachment: :blob }
        ]
      )
      .find(params[:id])
  end

  def assign_project_members
    client_ids = Array(params.dig(:project, :client_ids)).reject(&:blank?).map(&:to_i)
    designer_ids = Array(params.dig(:project, :designer_ids)).reject(&:blank?).map(&:to_i)

    client_ids.each do |client_id|
      @project.projects_clients.create!(client_id: client_id)
    end

    designer_ids.each do |designer_id|
      @project.projects_designers.create!(designer_id: designer_id)
    end
  end

  def project_params
    params.require(:project).permit(:name, :status)
  end
end
