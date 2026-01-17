class Product < ApplicationRecord
  STATUSES = %w[pending approved rejected ordered delivered].freeze

  attribute :status, :string, default: "pending"

  belongs_to :room
  has_many :comments, as: :commentable, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :quantity, numericality: { greater_than: 0, only_integer: true }, allow_nil: true
  validates :link, length: { maximum: 2048 }, allow_blank: true

  # Scopes
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :ordered, -> { where(status: "ordered") }
  scope :delivered, -> { where(status: "delivered") }

  # Calculate total price for this product
  def total_price
    (price || 0) * (quantity || 1)
  end

  # Check if status can transition to the given status
  def can_transition_to?(new_status)
    valid_transitions = {
      "pending" => %w[approved rejected],
      "approved" => %w[ordered pending],
      "rejected" => %w[pending],
      "ordered" => %w[delivered approved],
      "delivered" => %w[ordered]
    }
    valid_transitions[status]&.include?(new_status)
  end
end
