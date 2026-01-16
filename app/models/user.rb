class User < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password_salt, presence: true
  validates :password_hash, presence: true


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
