class Profile < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :submissions
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :unique_email_among_users_validation
  enum :position_type, { faculty: 0, grad_student: 1, undergrad_student: 2, secondary_student: 3, other: 4 }

  before_save :downcase_email

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
end
