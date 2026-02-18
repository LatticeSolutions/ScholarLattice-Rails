class NewRegistration < ApplicationRecord
  belongs_to :user
  belongs_to :collection
  validates :user_id, uniqueness: { scope: :collection_id }

  validate :error_when_no_option_chosen, unless: -> { registration_option_choices.select { |c| c.amount > 0 }.any? }

  before_save :ensure_choices_for_all_options

  has_many :registration_option_choices, dependent: :destroy

  enum :status, { submitted: 0, accepted: 1, declined: 2 }

  accepts_nested_attributes_for :user, :registration_option_choices

  def has_cost?
    registration_option_choices.any?(&:has_cost?)
  end

  def total_cost
    registration_option_choices.select(&:has_cost?).sum(&:total_cost)
  end

  def csv_row
    row = [
      id,
      status.humanize,
      collection.id,
      collection.short_title_path,
      user.last_name,
      user.first_name,
      user.email,
      user.affiliation,
      user.position,
      user.position_type
    ]
    collection.registration_options.each do |option|
      choice = registration_option_choices.find_by(registration_option: option)
      row += [
        choice&.amount || 0,
        choice&.info || ""
      ]
    end
    row
  end

  def self.to_csv(collection)
    require "csv"
    attributes = [
      "ID",
      "Status",
      "Collection ID",
      "Collection Slug",
      "User Last Name",
      "User First Name",
      "User Email",
      "User Affiliation",
      "User Position",
      "User Position Type"
    ]
    collection.registration_options.each do |option|
      attributes += [
        "#{option.name}: Amount",
        "#{option.name}: Info"
      ]
    end
    CSV.generate(headers: true) do |csv|
      csv << attributes

      where(collection: collection).each do |submission|
        csv << submission.csv_row
      end
    end
  end

  def ensure_choices_for_all_options
    collection.registration_options.each do |option|
      if registration_option_choices.select { |c| c.registration_option == option }.empty?
        registration_option_choices.new(registration_option: option)
      end
    end
  end

  private

  def error_when_no_option_chosen
    errors.add(:registration_option_choices, "must have at least one option chosen")
  end
end
