class Room < ApplicationRecord
  STATUSES = %w[new in_progress review completed].freeze

  attribute :status, :string, default: "new"

  belongs_to :project
  has_many :products, dependent: :destroy
  has_many :pending_products, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_one_attached :plan
  has_one_attached :plan_with_products

  validates :name, presence: true, length: { maximum: 100 }
  validates :name, uniqueness: { scope: :project_id, message: "already exists in this project" }
  validates :status, presence: true, inclusion: { in: STATUSES }

  # Scopes
  scope :by_status, ->(status) { where(status: status) if status.present? }

  # Calculate total cost for all products in this room
  def total_cost
    products.sum { |p| (p.price || 0) * (p.quantity || 1) }
  end
end
