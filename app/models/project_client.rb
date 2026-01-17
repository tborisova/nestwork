class ProjectClient < ApplicationRecord
  self.table_name = "projects_clients"

  belongs_to :project
  belongs_to :client, class_name: "User"

  validates :project_id, uniqueness: { scope: :client_id, message: "client already assigned to this project" }
end
