class SelectionOption < ApplicationRecord
  belongs_to :selection

  validates :name, presence: true
end
