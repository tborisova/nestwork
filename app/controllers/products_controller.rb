class ProductsController < ApplicationController
  before_action :require_login
  before_action :set_project
  before_action :set_product

  def update_status
    new_status = params[:status]

    # Validate status transition based on role
    if new_status == "approved"
      # Both clients and designers can approve
      unless current_user.designer_for_project?(@project) || current_user.client_for_project?(@project)
        return redirect_to project_path(@project), alert: "You don't have permission to update this product"
      end
    elsif %w[ordered delivered].include?(new_status)
      # Only designers can mark as ordered or delivered
      unless current_user.designer_for_project?(@project)
        return redirect_to project_path(@project), alert: "Only designers can update this status"
      end
    else
      return redirect_to project_path(@project), alert: "Invalid status"
    end

    if @product.update(status: new_status)
      redirect_to project_path(@project), notice: "Product status updated to #{new_status}"
    else
      redirect_to project_path(@project), alert: "Could not update product status"
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

  def set_product
    @product = Product.joins(:room).where(rooms: { project_id: @project.id }).find(params[:id])
  end
end
