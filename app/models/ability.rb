# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # default abilities
    can :read, Collection
    can :read, Page, visibility: [ :public, :unlisted ]
    can :read, Profile
    can :read, Submission, status: :accepted
    can :read, Event
    can [ :read, :create ], User
    can [ :read, :create ], Registration

    return unless user.present?

    can :read, :dashboard

    can [ :like, :dislike ], Collection
    can :manage, Collection do |c|
      c.has_admin? user
    end
    cannot :destroy, Collection

    can :manage, Page do |p|
      p.has_admin? user
    end

    can :manage, Event do |e|
      e.collection.has_admin?(user)
    end
    can :access_webinar, Event do |e|
      Registration.where(
        user: user,
        registration_option: e.collection.path.collect(&:registration_options).flatten,
        status: :accepted
      ).any?
    end

    can :manage, Submission do |s|
      s.collection.has_admin?(user)
    end
    can :new, Submission do |s|
      s.collection.submissions_open?
    end
    can :create, Submission do |s|
      s.collection.submissions_open? and s.user_id == user.id
    end
    can [ :read, :update ], Submission do |s|
      s.user_id == user.id
    end
    can :read, Submission do |s|
      s.accepted?
    end
    cannot :destroy, Submission

    can :manage, Registration do |r|
      r.collection.present? and (r.collection.has_admin?(user) || r.user_id == user.id)
    end
    can :view_payments, Registration do |r|
      r.user_id == user.id and r.registration_option.cost.present?
    end

    can :manage, Invitation do |i|
      i.collection.has_admin?(user)
    end
    can :read, Invitation do |i|
      i.user_id == user.id || i.status == :accepted
    end
    can :respond_to, Invitation do |i|
      i.user_id == user.id && i.status != :revoked
    end

    can :manage, User do |u|
      u.id == user.id
    end

    return unless user.site_admin?
    can :manage, :all
  end
end
