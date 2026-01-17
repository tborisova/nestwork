class Firm < ApplicationRecord
  has_many :firms_designers, class_name: "FirmDesigner"
  has_many :designers, through: :firms_designers, class_name: "User", source: :designer

  has_many :firms_clients, class_name: "FirmClient"
  has_many :clients, through: :firms_clients, class_name: "User", source: :client
end
