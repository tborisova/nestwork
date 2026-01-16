class ProjectDesigner < ApplicationRecord
  self.table_name = 'projects_designers'

  belongs_to :project
  belongs_to :designer, class_name: 'User'
end
