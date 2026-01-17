class Product < ApplicationRecord
  attribute :status, :string, default: "pending"

  belongs_to :room
  has_many :comments, as: :commentable, dependent: :destroy

  validates :name, presence: true
end
