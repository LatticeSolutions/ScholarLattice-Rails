class NewRegistration < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  validates :user_id, uniqueness: { scope: :collection_id }

  validate :only_admins_update_status

  validate :has_choices_for_all_options

  has_many :registration_option_choices, dependent: :destroy

  enum :status, { submitted: 0, accepted: 1, declined: 2 }

  accepts_nested_attributes_for :user, :registration_option_choices

  private

  def only_admins_update_status
    if @current_user.nil? || !@current_user.ability.can?(:manage, collection)
      if new_record?
        if !submitted?
          errors.add(:status, "can only be set by collection admins")
        end
      elsif status_changed? && status_was.present?
        errors.add(:status, "can only be changed by collection admins")
      end
    end
  end

  def has_choices_for_all_options
    if registration_option_choices.map(&:registration_option_id).uniq.sort != collection.registration_options.map(&:id).uniq.sort
      errors.add(:registration_option_choices, "must be made for all registration options")
    end
  end
end
