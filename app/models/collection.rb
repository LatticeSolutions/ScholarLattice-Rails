class Collection < ApplicationRecord
  validates :title, presence: true
  validates :short_title, presence: true
  validate :submissions_open_before_closing_validation
  validate :admin_emails_validation
  has_ancestry
  has_many :admins, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :favorite_users, through: :likes, source: :user
  has_many :pages, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :invitations, dependent: :destroy
  has_many :registration_options, dependent: :destroy
  has_many :registrations, through: :registration_options
  has_many :payments, through: :registrations
  has_one :attached_event, class_name: "Event", foreign_key: "attached_collection_id", dependent: :nullify
  after_save :update_admins_after_save
  before_save :round_down_submission_times

  default_scope { order(:order, :title) }

  def admin_users
    User
      .distinct
      .joins(:admins)
      .where(admins: { collection: path_ids })
  end

  def inherited_time_zone
    return time_zone if time_zone.present?
    parent_time_zone
  end

  def parent_time_zone
    return "UTC" unless parent
    parent.inherited_time_zone
  end

  def has_admin?(user)
    return false unless user.present?
    admin_users.exists? user.id
  end

  def collection_name
    return "Collection" unless parent
    parent.subcollection_name
  end

  def short_title_path
    return short_title unless parent
    "#{parent.short_title_path} / #{short_title}"
  end

  def subtree_submissions
    Submission.where(collection: subtree)
  end

  def subtree_invitations
    Invitation.where(collection: subtree)
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

  def registrations_open?
    registerable and registration_options.count > 0
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

  def all_events
    Event.where(collection: subtree)
  end

  def all_top_events
    # remove events that are descendants of other events in the collection
    reject_ids = all_events.map(&:descendant_ids).flatten.uniq
    all_events.where.not(id: reject_ids)
  end

  def all_scheduled_events
    all_top_events.where.not(starts_at: nil)
  end

  def all_unscheduled_events
    all_top_events.where(starts_at: nil)
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

  def qr_code
    require "rqrcode"
    RQRCode::QRCode.new(Rails.application.routes.url_helpers.collection_url(self)).as_svg(module_size: 3)
  end

  def connected_profiles
    subtree.map { |c| (
      c.admin_users.map(&:main_profile) +
      c.favorite_users.map(&:main_profile) +
      c.registrations.where.not(status: :declined).map(&:profile) +
      c.submissions.where.not(status: [ :declined, :draft ]).map(&:profile) +
      c.invitations.where.not(status: [ :declined, :revoked ]).map(&:profile)
     ) }.flatten.compact.uniq.sort_by { |p| [ p.last_name, p.first_name ] }
  end

  def connected_unsubmitted_profiles
    connected_profiles.select { |p| p.submissions.where(collection: subtree).empty? }
  end

  def connected_unregistered_profiles
    connected_profiles.select { |p| p.registrations.select { |r| subtree.include? r.collection }.empty? }
  end

  def program_tex
    ERB.new(File.read("#{Rails.root}/app/views/events/_program.text.erb")).result_with_hash(collection: self)
  end

  def has_webinars?
    attached_event.blank? and all_events.where.not(webinar_link: [ nil, "" ]).any?
  end

  private

  def round_down_submission_times
    self.submissions_open_on = submissions_open_on.change(sec: 0) if submissions_open_on.present?
    self.submissions_close_on = submissions_close_on.change(sec: 0) if submissions_close_on.present?
  end
end
