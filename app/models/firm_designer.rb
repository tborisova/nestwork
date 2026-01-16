class FirmDesigner < ApplicationRecord
  self.table_name = 'firms_designers'

  belongs_to :firm
  belongs_to :designer, class_name: 'User'
end
