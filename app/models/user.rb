class User < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password_salt, presence: true
  validates :password_hash, presence: true
  has_many :firms_designers, class_name: 'FirmDesigner'
  has_many :firm, through: :firms_designers, inverse_of: :designer

  has_many :projects_clients, class_name: 'ProjectClient', foreign_key: :client_id
  has_many :projects_designers, class_name: 'ProjectDesigner', foreign_key: :designer_id

  has_many :client_projects, through: :projects_clients, class_name: 'Project', source: :project
  has_many :designer_projects, through: :projects_designers, class_name: 'Project', source: :project

  class << self
    def compute_hash(salt, plaintext_password) = Digest::SHA256.hexdigest("#{salt}::#{plaintext_password}")
  end

  def authenticate(plaintext_password)
    return false if plaintext_password.nil?

    computed = User.compute_hash(password_salt, plaintext_password)

    ActiveSupport::SecurityUtils.secure_compare(computed, password_hash)
  end

  def set_password!(plaintext_password)
    raise ArgumentError, "password must be present" if plaintext_password.blank?

    self.password_salt = SecureRandom.hex(16)
    self.password_hash = User.compute_hash(password_salt, plaintext_password)
  end
end
