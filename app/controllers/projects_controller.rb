class ProjectsController < ApplicationController
  before_action :require_login

  def index
    firm_ids = current_user.firms.select(:id)
    @projects = Project.where(firm_id: firm_ids).order(created_at: :desc)
  end

  def new
  end

  private

  def require_login
    redirect_to new_session_path, alert: "You need to sign in first" unless current_user
  end
end

