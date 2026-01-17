class SelectionOption < ApplicationRecord
  belongs_to :selection

  validates :name, presence: true, length: { maximum: 255 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :link, length: { maximum: 2048 }, allow_blank: true
end
