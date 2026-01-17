# frozen_string_literal: true

# Concern for controllers that need to access projects with proper authorization.
# Provides common methods for:
# - Finding projects the current user can access
# - Requiring login
# - Checking designer permissions
module ProjectAccessible
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_is_designer? if respond_to?(:helper_method)
  end

  private

  # Returns a scope of projects accessible to the current user
  # (either through firm membership or as a client)
  def accessible_projects
    firm_ids = current_user.firms.select(:id)
    Project.where(firm_id: firm_ids)
           .or(Project.where(id: current_user.client_projects.select(:id)))
  end

  # Find a project by ID from accessible projects
  def find_accessible_project(id = params[:project_id] || params[:id])
    accessible_projects.find(id)
  end

  # Standard before_action to set @project
  def set_accessible_project
    @project = find_accessible_project
  rescue ActiveRecord::RecordNotFound
    handle_project_not_found
  end

  # Check if current user is a designer (belongs to any firm)
  def current_user_is_designer?
    @_current_user_is_designer ||= current_user&.firms&.exists?
  end

  # Check if current user is a designer for the given project
  def designer_for_project?(project = @project)
    current_user&.designer_for_project?(project)
  end

  # Check if current user is a client for the given project
  def client_for_project?(project = @project)
    current_user&.client_for_project?(project)
  end

  # Before action: require user to be logged in
  def require_login
    return if current_user

    respond_to do |format|
      format.html { redirect_to new_session_path, alert: "You need to sign in first" }
      format.json { render json: { error: "You need to sign in first" }, status: :unauthorized }
    end
  end

  # Before action: require user to be a designer (member of a firm)
  def require_designer
    return if current_user_is_designer?

    respond_to do |format|
      format.html { redirect_to projects_path, alert: "Only designers can perform this action" }
      format.json { render json: { error: "Only designers can perform this action" }, status: :forbidden }
    end
  end

  # Before action: require user to be a designer for the current project
  def require_project_designer
    return if designer_for_project?

    respond_to do |format|
      format.html { redirect_to project_path(@project), alert: "Only designers can perform this action" }
      format.json { render json: { error: "Only designers can perform this action" }, status: :forbidden }
    end
  end

  # Handle project not found - override in controllers for different behavior
  def handle_project_not_found
    respond_to do |format|
      format.html { redirect_to projects_path, alert: "Project not found" }
      format.json { render json: { error: "Project not found" }, status: :not_found }
    end
  end
end
