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

end
