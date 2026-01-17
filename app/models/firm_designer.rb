class FirmDesigner < ApplicationRecord
  self.table_name = "firms_designers"

  belongs_to :firm
  belongs_to :designer, class_name: "User"

  validates :firm_id, uniqueness: { scope: :designer_id, message: "designer already assigned to this firm" }
end
