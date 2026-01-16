class Firm < ApplicationRecord
  has_many :firms_designers, class_name: 'FirmDesigner'
  has_many :designers, through: :firms_designers, class_name: 'User', inverse_of: :firm
end
