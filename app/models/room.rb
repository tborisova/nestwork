class Room < ApplicationRecord
  STATUSES = %w[new in_progress review completed].freeze

  attribute :status, :string, default: "new"

  belongs_to :project
  has_many :products, dependent: :destroy
  has_many :selections, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  has_one_attached :plan
  has_one_attached :plan_with_products

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
end
