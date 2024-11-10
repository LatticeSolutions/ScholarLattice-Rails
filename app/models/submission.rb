class Submission < ApplicationRecord
  belongs_to :profile
  belongs_to :collection
  enum :status, { submitted: 0, accepted: 1, declined: 2, draft: 3 }

  def has_admin?(user)
    user.profiles.include? profile or
    submission.collection.has_admin? @current_user or
    @current_user.site_admin
  end
end
