class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  validate :submissions_open_before_closing_validation
  validate :admin_emails_validation
  has_ancestry
  has_many :admins
  has_many :likes
  has_many :favorite_users, through: :likes, source: :user
  has_many :pages
  has_many :submissions
  after_save :update_admins_after_save

  def admin_users
    User
      .distinct
      .joins(:admins)
      .where(admins: { collection: path_ids })
  end

  def has_admin?(user)
    return false unless user.present?
    admin_users.exists? user.id
  end

  def collection_name
    return "Collection" unless parent
    parent.subcollection_name
  end

  def submissions_closed?
    return false if submissions_close_on.blank?
    submissions_close_on <= Time.now
  end

  def submissions_open?
    return false if submissions_closed?
    return true if submissions_open_on.blank?
    submissions_open_on <= Time.now
  end

  def submissions_open_before_closing_validation
    return if [ submissions_close_on.blank?, submissions_open_on.blank? ].any?
    if submissions_open_on > submissions_close_on
      errors.add(:submissions_close_on, "must be later than submission opening")
    end
  end

  def home_page
    pages.where(is_home: true).first
  end

  def public_pages
    pages.where(is_home: false, visibility: :public)
  end

  def non_public_pages
    pages.where(is_home: false).where.not(visibility: :public)
  end

  def admin_emails
    @admin_emails ||= admins.map { |a| a.user.email } .to_a.join(", ")
  end

  def admin_emails=(email_string)
    @admin_emails = email_string
  end

  def admin_emails_validation
    return unless @admin_emails
    valid_email_regex = URI::MailTo::EMAIL_REGEXP

    @admin_emails.split(",").each do |email|
      next if email.strip.blank?
      unless email.strip.match?(valid_email_regex)
        errors.add(:admin_emails, "contains invalid email: #{email}")
      end
    end
  end

  def update_admins_after_save
    return unless @admin_emails

    @admin_emails.split(",").each do |email|
      next if email.strip.blank?
      user = User.find_or_create_by(email: email.strip)
      admins.find_or_create_by(user: user) unless admins.exists?(user: user)
    end

    admins.each do |admin|
      admins.destroy(admin) unless @admin_emails.include? admin.user.email
    end
  end
end
