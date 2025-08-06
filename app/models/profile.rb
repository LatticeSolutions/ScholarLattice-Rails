class Profile < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :submissions
  has_many :registrations
  has_many :invitations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :unique_email_among_users_validation
  enum :position_type, { faculty: 0, grad_student: 1, undergrad_student: 2, secondary_student: 3, other: 4, postdoc: 5 }

  before_save :downcase_email
  before_save :strip_whitespace

  default_scope { order(:last_name, :first_name) }

  def description
    if affiliation.present? and position.present?
      "#{position} at #{affiliation}"
    elsif affiliation.present?
      affiliation
    elsif position.present?
      position
    else
      ""
    end
  end

  def verified?
    users.where(email: email).any?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def name_with_email
    "#{name} ⟨#{email}⟩"
  end

  def unique_email_among_users_validation
    users.each do |user|
      if user.profiles.where(email: email.downcase).where.not(id: id).any?
        return errors.add(:email, "must not duplicate any other profile managed by this profile's users")
      end
    end
  end

  def registered_for?(collection)
    registrations_for(collection).any?
  end

  def registrations_for(collection)
    registrations.where(registration_option: collection.registration_options)
  end

  private

  def strip_whitespace
    self.first_name = first_name.strip if first_name.present?
    self.last_name = last_name.strip if last_name.present?
    self.email = email.strip if email.present?
    self.affiliation = affiliation.strip if affiliation.present?
    self.position = position.strip if position.present?
  end
end
