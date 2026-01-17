class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  has_many :firms_designers, class_name: "FirmDesigner", foreign_key: :designer_id
  has_many :firms, through: :firms_designers, source: :firm

  has_many :projects_clients, class_name: "ProjectClient", foreign_key: :client_id
  has_many :projects_designers, class_name: "ProjectDesigner", foreign_key: :designer_id

  has_many :client_projects, through: :projects_clients, class_name: "Project", source: :project
  has_many :designer_projects, through: :projects_designers, class_name: "Project", source: :project
  has_many :comments, dependent: :destroy

  def designer_for_project?(project)
    designer_projects.exists?(project.id)
  end

  def client_for_project?(project)
    client_projects.exists?(project.id)
  end
end
