class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
  belongs_to :user

  validates :comment, presence: true, length: { maximum: 5000 }

  scope :unresolved, -> { where(resolved: false) }
  scope :resolved, -> { where(resolved: true) }
  scope :recent_first, -> { order(created_at: :desc) }

  # Default resolved to false
  after_initialize :set_defaults, if: :new_record?

  private

  def set_defaults
    self.resolved ||= false
  end
end
