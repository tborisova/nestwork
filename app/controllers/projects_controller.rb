class ProjectsController < ApplicationController
  before_action :require_login
  before_action :require_designer, only: [ :new, :create ]
  before_action :set_project, only: [ :update ]
  before_action :require_project_designer, only: [ :update ]

  def index
    firm_ids = current_user.firms.select(:id)
    @is_designer = current_user.firms.exists?

    if @is_designer
      @filter_designers = User.joins("INNER JOIN firms_designers ON firms_designers.designer_id = users.id")
                              .where("firms_designers.firm_id IN (?)", firm_ids)
                              .distinct.order(:name)
      @filter_clients = User.joins("INNER JOIN firms_clients ON firms_clients.client_id = users.id")
                            .where("firms_clients.firm_id IN (?)", firm_ids)
                            .distinct.order(:name)
    end

    projects = Project.where(firm_id: firm_ids)
                      .or(Project.where(id: current_user.client_projects.select(:id)))
    if params[:status].present?
      projects = projects.where(status: params[:status])
    end
    if params[:name].present?
      projects = projects.where("projects.name like ?", "%#{params[:name].to_s.strip}%")
    end
    if params[:designer_ids].present?
      designer_ids = Array(params[:designer_ids]).reject(&:blank?).map(&:to_i)
      if designer_ids.any?
        projects = projects.joins(:projects_designers).where(projects_designers: { designer_id: designer_ids })
      end
    end
    if params[:client_ids].present?
      client_ids = Array(params[:client_ids]).reject(&:blank?).map(&:to_i)
      if client_ids.any?
        projects = projects.joins(:projects_clients).where(projects_clients: { client_id: client_ids })
      end
    end

    status_order = Arel.sql("CASE status
      WHEN 'waiting_for_approval' THEN 1
      WHEN 'new' THEN 2
      WHEN 'in_progress' THEN 3
      WHEN 'done' THEN 4
      ELSE 5
    END")
    @projects = projects.includes(:designers, :clients, :firm).distinct.order(status_order, created_at: :desc)
  end

  def show
    firm_ids = current_user.firms.select(:id)
    @project = Project.includes(:designers, :clients, rooms: [ { products: :comments }, { selections: [ :selection_options, :comments ] }, :comments ])
                      .where(firm_id: firm_ids)
                      .or(Project.where(id: current_user.client_projects.select(:id)))
                      .find(params[:id])
    @is_designer = current_user.designer_for_project?(@project)
    @rooms_data = build_rooms_data
    @project_total = @rooms_data.sum { |r| r[:total] }
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

    @project = Project.new(project_params.merge(firm_id: @firm.id))

    ActiveRecord::Base.transaction do
      @project.save!

      client_ids = Array(params[:project][:client_ids]).reject(&:blank?).map(&:to_i)
      designer_ids = Array(params[:project][:designer_ids]).reject(&:blank?).map(&:to_i)

      client_ids.each do |client_id|
        ProjectClient.create!(project_id: @project.id, client_id: client_id)
      end

      designer_ids.each do |designer_id|
        ProjectDesigner.create!(project_id: @project.id, designer_id: designer_id)
      end
    end

    redirect_to projects_path, notice: "Project created"
  rescue ActiveRecord::RecordInvalid => e
    @clients = @firm ? @firm.clients : User.none
    @designers = @firm ? @firm.designers : User.none
    flash.now[:alert] = e.record.errors.full_messages.first || "Could not create project"
    render :new, status: :unprocessable_entity
  end

  def update
    if @project.update(project_params)
      redirect_to project_path(@project), notice: "Project updated"
    else
      redirect_to project_path(@project), alert: @project.errors.full_messages.first || "Could not update project"
    end
  end

  private

  def set_project
    firm_ids = current_user.firms.select(:id)
    @project = Project.where(firm_id: firm_ids)
                      .or(Project.where(id: current_user.client_projects.select(:id)))
                      .find(params[:id])
  end

  def require_project_designer
    unless current_user.designer_for_project?(@project)
      redirect_to project_path(@project), alert: "Only designers can edit projects"
    end
  end

  def require_login
    redirect_to new_session_path, alert: "You need to sign in first" unless current_user
  end

  def require_designer
    unless current_user.firms.exists?
      redirect_to projects_path, alert: "Only designers can create projects"
    end
  end

  def project_params
    params.require(:project).permit(:name)
  end

  def build_rooms_data
    room_names = [ "Living room", "Kitchen", "Dining room", "Master bedroom", "Guest bedroom", "Master bathroom" ]
    room_names.map do |name|
      room = @project.rooms.find { |r| r.name == name }
      products = room ? room.products.map { |p|
        { id: p.id, name: p.name, price: p.price, link: p.link, quantity: p.quantity, status: p.status, comments_count: p.comments.size }
      } : []
      room_total = products.sum { |p| (p[:price] || 0) * (p[:quantity] || 1) }
      {
        name: name,
        room_id: room&.id,
        comments_count: room ? room.comments.size : 0,
        total: room_total,
        products: products,
        selections: room ? room.selections.map { |s|
          {
            id: s.id,
            name: s.name,
            quantity: s.quantity,
            comments_count: s.comments.size,
            options: s.selection_options.map { |o| { id: o.id, name: o.name, price: o.price, link: o.link } }
          }
        } : []
      }
    end
  end
end
