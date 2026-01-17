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

  # Scopes for common queries
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :search_by_name, ->(name) { where("projects.name LIKE ?", "%#{name.strip}%") if name.present? }
  scope :with_designer, ->(designer_ids) {
    joins(:projects_designers).where(projects_designers: { designer_id: designer_ids }) if designer_ids.present?
  }
  scope :with_client, ->(client_ids) {
    joins(:projects_clients).where(projects_clients: { client_id: client_ids }) if client_ids.present?
  }
  scope :ordered_by_status, -> {
    order(Arel.sql("CASE status
      WHEN 'waiting_for_approval' THEN 1
      WHEN 'new' THEN 2
      WHEN 'in_progress' THEN 3
      WHEN 'done' THEN 4
      ELSE 5
    END"), created_at: :desc)
  }
end
