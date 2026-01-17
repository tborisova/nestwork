class Product < ApplicationRecord
  attribute :status, :string, default: "pending"

  belongs_to :room

  validates :name, presence: true
end
