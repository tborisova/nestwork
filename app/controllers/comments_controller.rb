class CommentsController < ApplicationController
  include ProjectAccessible

  before_action :require_login
  before_action :set_accessible_project
  before_action :set_commentable
  before_action :set_comment, only: [:update, :destroy]

  def index
    @comments = @commentable.comments.includes(:user).recent_first
    render json: CommentPresenter.collection(@comments, current_user: current_user)
  end

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      render json: CommentPresenter.new(@comment, current_user: current_user).as_json, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_update_params)
      render json: CommentPresenter.new(@comment, current_user: current_user).as_json
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
    @commentable = Comments::CommentableFinder.new(params).call
    return render json: { error: "Item not found" }, status: :not_found unless @commentable
    return render json: { error: "Item not found" }, status: :not_found unless Comments::CommentableFinder.belongs_to_project?(@commentable, @project)
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
end
