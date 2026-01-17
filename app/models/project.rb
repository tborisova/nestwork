class Project < ApplicationRecord
  attribute :status, :string, default: "new"

  has_many :projects_clients, class_name: 'ProjectClient'
  has_many :projects_designers, class_name: 'ProjectDesigner'

  has_many :clients, through: :projects_clients, class_name: 'User', inverse_of: :client_projects
  has_many :designers, through: :projects_designers, class_name: 'User', inverse_of: :designer_projects
end
