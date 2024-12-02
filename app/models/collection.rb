class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  validate :submissions_open_before_closing_validation
  has_ancestry
  has_many :admins
  has_many :direct_admin_users, through: :admins, source: :user
  has_many :likes
  has_many :favorite_users, through: :likes, source: :user
  has_many :pages
  has_many :submissions

  def admin_users
    User
      .distinct
      .joins(:admins)
      .where(admins: { collection: path_ids })
  end

  def has_admin?(user)
    !user.nil? and admin_users.exists? user.id
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
end
