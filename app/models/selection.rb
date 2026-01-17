class Selection < ApplicationRecord
  belongs_to :room
  has_many :selection_options, dependent: :destroy

  validates :name, presence: true

  accepts_nested_attributes_for :selection_options, reject_if: :all_blank, allow_destroy: true
end
