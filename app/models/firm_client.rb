class FirmClient < ApplicationRecord
  self.table_name = "firms_clients"

  belongs_to :firm
  belongs_to :client, class_name: "User"
end
