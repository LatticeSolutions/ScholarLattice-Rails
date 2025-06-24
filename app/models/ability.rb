# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # default abilities
    can :read, Collection
    can :read, Page, visibility: [ :public, :unlisted ]
    can :read, User
    can :read, Submission, status: :accepted
    can :read, Event

    return unless user.present?

    can :read, :dashboard if user.first_name.present?

    can [ :like, :dislike ], Collection
    can :manage, Collection do |c|
      c.has_admin? user
    end
    cannot :destroy, Collection

    can :manage, Page do |p|
      p.has_admin? user
    end
    cannot :destroy, Page

    can :manage, Event do |e|
      e.collection.has_admin?(user)
    end

    can :manage, Submission do |s|
      s.collection.has_admin?(user)
    end
    can :new, Submission do |s|
      s.collection.submissions_open?
    end
    can :create, Submission do |s|
      s.collection.submissions_open? and s.user.in? user.managed_users
    end
    can [ :read, :update ], Submission do |s|
      s.user.in? user.managed_users
    end
    can :read, Submission do |s|
      s.accepted?
    end
    cannot :destroy, Submission

    can :manage, Registration do |r|
      r.collection.nil? || r.collection.has_admin?(user)
    end
    can :read, Registration do |r|
      r.user.in?(user.managed_users) || r.status == :accepted
    end
    can :view_payments, Registration do |r|
      r.user.in?(user.managed_users)
    end

    can :manage, Invitation do |i|
      i.collection.has_admin?(user)
    end
    can :read, Invitation do |i|
      i.user.in?(user.managed_users) || i.status == :accepted
    end
    can :respond_to, Invitation do |i|
      i.user.in?(user.managed_users) && i.status != :revoked
    end

    return unless user.site_admin?
    can :manage, :all
  end
end
