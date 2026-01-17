class ProjectDesigner < ApplicationRecord
  self.table_name = "projects_designers"

  belongs_to :project
  belongs_to :designer, class_name: "User"

  validates :project_id, uniqueness: { scope: :designer_id, message: "designer already assigned to this project" }
end
