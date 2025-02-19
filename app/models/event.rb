class Event < ApplicationRecord
  has_ancestry
  belongs_to :collection
  belongs_to :submission, optional: true

  validate :starts_after_parent
  validate :ends_before_parent
  validates :title, presence: true

  def same_times_as_parent?
    starts_at == parent&.starts_at && ends_at == parent&.ends_at
  end

  private

  def starts_after_parent
    return unless starts_at.present? && parent.present?
    unless starts_at >= parent.starts_at
      errors.add(:starts_at, "must start after parent #{parent.title} starts (#{parent.starts_at})")
    end
  end

  def ends_before_parent
    return unless ends_at.present? && parent.present?
    unless ends_at <= parent.ends_at
      errors.add(:ends_at, "must end before parent #{parent.title} ends (#{parent.ends_at})")
    end
  end
end
