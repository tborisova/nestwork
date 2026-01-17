class Product < ApplicationRecord
  STATUSES = %w[pending approved rejected ordered delivered].freeze

  attribute :status, :string, default: "pending"

  belongs_to :room
  has_many :comments, as: :commentable, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
end
