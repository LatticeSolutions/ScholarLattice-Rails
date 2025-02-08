# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # default abilities
    can :read, Collection
    can :read, Page, visibility: [ :public, :unlisted ]
    can :read, Profile
    can :read, Submission, status: :accepted

    return unless user.present?

    can :manage, Collection do |c|
      c.has_admin? user
    end
    can :like, Collection
    cannot :destroy, Collection

    can :manage, Page do |p|
      p.collection.has_admin? user
    end
    cannot :destroy, Page

    can :manage, Submission do |s|
      s.collection.has_admin?(user)
    end
    can :create, Submission do |s|
      return false unless s.collection.submissions_open?
      s.profile.in? user.profiles
    end
    can :update, Submission do |s|
      s.profile.in? user.profiles
    end
    cannot :destroy, Submission

    can :manage, Profile, users: user
    can :manage, Profile, email: user.email
    cannot :destroy, Profile

    return unless user.site_admin?
    can :manage, :all
  end
end
