# frozen_string_literal: true

class CommentPresenter
  def initialize(comment, current_user:)
    @comment = comment
    @current_user = current_user
  end

  def as_json
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

  def self.collection(comments, current_user:)
    comments.map { |c| new(c, current_user: current_user).as_json }
  end

  private

  attr_reader :comment, :current_user
end
