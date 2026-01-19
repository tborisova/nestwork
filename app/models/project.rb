class Project < ApplicationRecord
  STATUSES = %w[new in_progress waiting_for_approval done].freeze

  attribute :status, :string, default: "new"

  belongs_to :firm

  has_many :projects_clients, class_name: "ProjectClient", dependent: :destroy
  has_many :projects_designers, class_name: "ProjectDesigner", dependent: :destroy

  has_many :clients, through: :projects_clients, class_name: "User", inverse_of: :client_projects
  has_many :designers, through: :projects_designers, class_name: "User", inverse_of: :designer_projects

  has_many :rooms, dependent: :destroy

  validates :name, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }
end
