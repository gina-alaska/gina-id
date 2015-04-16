class LegacyUser < ActiveRecord::Base
  attr_accessor :password

  validates :login, uniqueness: true
  validates :email, uniqueness: true
  validates :password, presence: true, confirmation: true

  before_save :encrypt_password

  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def self.authenticate(login, password)
    return nil if login.nil? or password.nil?
    u = where('login = ? OR email = ?', login.downcase, login.downcase).where(active: true).first # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
end
