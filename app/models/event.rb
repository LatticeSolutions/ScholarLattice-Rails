class Event < ApplicationRecord
  has_ancestry
  belongs_to :collection
  belongs_to :submission, optional: true

  validate :starts_at_within_ancestor_range
  validate :ends_at_within_ancestor_range
  validates :title, presence: true

  private

  def starts_at_within_ancestor_range
    return unless starts_at.present?

    ancestors.where.not(starts_at: nil).each do |ancestor|
      unless starts_at >= ancestor.starts_at
        errors.add(:starts_at, "must be within the time range of ancestor event #{ancestor.title}")
      end
    end
  end

  def ends_at_within_ancestor_range
    return unless ends_at.present?

    ancestors.where.not(ends_at: nil).each do |ancestor|
      unless ends_at <= ancestor.ends_at
        errors.add(:ends_at, "must be within the time range of ancestor event #{ancestor.title}")
      end
    end
  end
end
