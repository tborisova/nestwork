class ProjectsController < ApplicationController
  before_action :require_login

  def index
    firm_ids = current_user.firms.select(:id)
    @filter_designers = User.joins("INNER JOIN firms_designers ON firms_designers.designer_id = users.id")
                            .where("firms_designers.firm_id IN (?)", firm_ids)
                            .distinct.order(:name)
    @filter_clients = User.joins("INNER JOIN firms_clients ON firms_clients.client_id = users.id")
                          .where("firms_clients.firm_id IN (?)", firm_ids)
                          .distinct.order(:name)

    projects = Project.where(firm_id: firm_ids)
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

    @projects = projects.includes(:designers, :clients).distinct.order(created_at: :desc)
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

  private

  def require_login
    redirect_to new_session_path, alert: "You need to sign in first" unless current_user
  end

  def project_params
    params.require(:project).permit(:name)
  end
end
