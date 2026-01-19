class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :name, presence: true, length: { maximum: 100 }
  validates :password, length: { minimum: 8 }, allow_nil: true

  # Designer association (a designer can only belong to one firm)
  belongs_to :firm, optional: true

  # Client associations (for firms)
  has_many :firms_clients, class_name: "FirmClient", foreign_key: :client_id
  has_many :client_firms, through: :firms_clients, source: :firm

  # Project associations
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

  def designer? = firm_id.present?
end
