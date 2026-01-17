class CommentsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :set_accessible_project
  before_action :set_commentable
  before_action :set_comment, only: [:update, :destroy]

  def index
    @comments = @commentable.comments.includes(:user).recent_first
    render json: @comments.map { |c| comment_json(c) }
  end

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      render json: comment_json(@comment), status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_update_params)
      render json: comment_json(@comment)
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    unless @comment.user_id == current_user.id
      return render json: { error: "You can only delete your own comments" }, status: :forbidden
    end

    @comment.destroy
    head :no_content
  end

  private

  def set_accessible_project
    @project = find_accessible_project(params[:project_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Project not found" }, status: :not_found
  end

  def set_commentable
    @commentable = find_commentable
    return render json: { error: "Item not found" }, status: :not_found unless @commentable
    return render json: { error: "Item not found" }, status: :not_found unless commentable_belongs_to_project?
  end

  def find_commentable
    if params[:product_id]
      Product.find_by(id: params[:product_id])
    elsif params[:selection_id]
      Selection.find_by(id: params[:selection_id])
    elsif params[:room_id]
      Room.find_by(id: params[:room_id])
    end
  end

  def commentable_belongs_to_project?
    case @commentable
    when Product, Selection
      @commentable.room.project_id == @project.id
    when Room
      @commentable.project_id == @project.id
    else
      false
    end
  end

  def set_comment
    @comment = @commentable.comments.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Comment not found" }, status: :not_found
  end

  def comment_params
    params.require(:comment).permit(:comment)
  end

  def comment_update_params
    params.require(:comment).permit(:resolved)
  end

  def comment_json(comment)
    {
      id: comment.id,
      comment: comment.comment,
      resolved: comment.resolved || false,
      user_id: comment.user_id,
      user_name: comment.user.name,
      created_at: comment.created_at.iso8601,
      can_delete: comment.user_id == current_user.id
    }
  end
end
