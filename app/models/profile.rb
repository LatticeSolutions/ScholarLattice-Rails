class Profile < ApplicationRecord
  has_and_belongs_to_many :users
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

  def verified?
    users.where(email: email).any?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def name_with_email
    "#{name} ⟨#{email}⟩"
  end
end
