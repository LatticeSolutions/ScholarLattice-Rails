class Profile < ApplicationRecord
  belongs_to :user
  validates :email, presence: true, uniqueness: { scope: :user,
    message: "A profile with this email address already exists for this user." }
  validates :first_name, presence: true
  validates :last_name, presence: true

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
end
