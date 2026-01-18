class Firm < ApplicationRecord
  has_many :projects, dependent: :destroy

  has_many :firms_designers, class_name: "FirmDesigner", dependent: :destroy
  has_many :designers, through: :firms_designers, class_name: "User", source: :designer

  has_many :firms_clients, class_name: "FirmClient", dependent: :destroy
  has_many :clients, through: :firms_clients, class_name: "User", source: :client

  validates :name, presence: true
end
