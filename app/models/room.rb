class Room < ApplicationRecord
  belongs_to :project
  has_many :products, dependent: :destroy
  has_many :selections, dependent: :destroy
end
