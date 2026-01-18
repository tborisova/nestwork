class Firm < ApplicationRecord
  has_many :projects, dependent: :destroy

  has_many :designers, class_name: "User", foreign_key: :firm_id, dependent: :nullify

  has_many :firms_clients, class_name: "FirmClient", dependent: :destroy
  has_many :clients, through: :firms_clients, class_name: "User", source: :client

  validates :name, presence: true
end
