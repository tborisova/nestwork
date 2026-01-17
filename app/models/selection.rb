class Selection < ApplicationRecord
  belongs_to :room
  has_many :selection_options, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :quantity, numericality: { greater_than: 0, only_integer: true }, allow_nil: true

  accepts_nested_attributes_for :selection_options, reject_if: :all_blank, allow_destroy: true
end
