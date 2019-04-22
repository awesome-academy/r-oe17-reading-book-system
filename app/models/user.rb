class User < ApplicationRecord
  belongs_to :role
  has_one :history
  has_many :follows
  has_many :categorys, through: :follows
  has_many :books
  has_many :likes
  has_many :books, through: :likes
  has_many :comments
  has_many :books, through: :comments

  attr_accessor :remember_token
  before_save :downcase_email
  validates :name, presence: true, length: {maximum: Settings.name_max}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length:
    {maximum: Settings.email_max}, format: {with: VALID_EMAIL_REGEX}, uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true, length: {
    minimum: Settings.pass_min}, allow_nil: true
  scope :ordered_by_name, -> {order name: :asc}

  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  private

  def downcase_email
    email.downcase!
  end

end