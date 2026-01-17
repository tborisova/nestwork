class FirmClient < ApplicationRecord
  self.table_name = "firms_clients"

  belongs_to :firm
  belongs_to :client, class_name: "User"

  validates :firm_id, uniqueness: { scope: :client_id, message: "client already assigned to this firm" }
end
