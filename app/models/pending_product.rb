class PendingProduct < ApplicationRecord
  self.table_name = "pending_products"

  belongs_to :room
  has_many :pending_product_options, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :quantity, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

  accepts_nested_attributes_for :pending_product_options, reject_if: :all_blank, allow_destroy: true
end
