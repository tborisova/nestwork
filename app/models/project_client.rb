class ProjectClient < ApplicationRecord
  self.table_name = 'projects_clients'

  belongs_to :project
  belongs_to :client, class_name: 'User'
end
