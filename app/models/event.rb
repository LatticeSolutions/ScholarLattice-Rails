class Event < ApplicationRecord
  has_ancestry
  belongs_to :collection
  belongs_to :submission, optional: true

  validate :submission_does_not_have_another_event
  validate :starts_before_ends
  validate :starts_within_parent
  validate :ends_within_parent

  validates :title, presence: true

  validate :collection_is_in_subtree_of_parents_collection

  default_scope { order(:starts_at, :order, :title) }

  def same_times_as_parent?
    starts_at == parent&.starts_at && ends_at == parent&.ends_at
  end

  def length_in_minutes
    return nil unless starts_at.present? && ends_at.present?
    ((ends_at - starts_at) / 60).round
  end

  def children_have_same_times?
    children.where.not(starts_at: starts_at, ends_at: ends_at).empty?
  end

  private

  def submission_does_not_have_another_event
    return unless submission_id.present?
    if Event.where(submission_id: submission_id).where.not(id: id).exists?
      errors.add(:submission, "is already assigned to another event")
    end
  end

  def starts_before_ends
    return unless starts_at.present? && ends_at.present?
    if starts_at >= ends_at
      errors.add(:starts_at, "must be before ends_at")
    end
  end

  def starts_within_parent
    return unless starts_at.present? && parent.present?
    if parent.starts_at.present? && starts_at < parent.starts_at
      errors.add(:starts_at, "must be after parent #{parent.title} starts (#{parent.starts_at})")
    end
    if parent.ends_at.present? && parent.ends_at < parent.starts_at
      errors.add(:starts_at, "must be before parent #{parent.title} ends (#{parent.ends_at})")
    end
  end

  def ends_within_parent
    return unless ends_at.present? && parent.present?
    if parent.starts_at.present? && ends_at < parent.starts_at
      errors.add(:ends_at, "must be after parent #{parent.title} starts (#{parent.starts_at})")
    end
    if parent.ends_at.present? && parent.ends_at < ends_at
      errors.add(:ends_at, "must be before parent #{parent.title} end (#{parent.starts_at})")
    end
  end

  def collection_is_in_subtree_of_parents_collection
    return unless parent.present?
    unless parent.collection.subtree.include?(collection)
      errors.add(:collection, "must be in the subtree of #{parent.collection.title}")
    end
  end
end
