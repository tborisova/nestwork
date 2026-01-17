class ProductsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :set_accessible_project
  before_action :set_product

  def update_status
    new_status = params[:status]

    unless valid_status_transition?(new_status)
      return redirect_to project_path(@project), alert: "Invalid status transition"
    end

    if @product.update(status: new_status)
      redirect_to project_path(@project), notice: "Product status updated to #{new_status}"
    else
      redirect_to project_path(@project), alert: "Could not update product status"
    end
  end

  private

  def set_accessible_project
    @project = find_accessible_project(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    handle_project_not_found
  end

  def set_product
    @product = Product.joins(:room)
                      .where(rooms: { project_id: @project.id })
                      .find(params[:id])
  end

  # Validate status transitions based on user role
  def valid_status_transition?(new_status)
    case new_status
    when "approved"
      # Both clients and designers can approve
      designer_for_project? || client_for_project?
    when "ordered", "delivered"
      # Only designers can mark as ordered or delivered
      designer_for_project?
    when "pending"
      # Both can reset to pending
      designer_for_project? || client_for_project?
    else
      false
    end
  end
end
