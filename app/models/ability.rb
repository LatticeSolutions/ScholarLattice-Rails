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

    return unless user.present?

    can :read, :dashboard if user.profiles.any?

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
    can :access_webinar, Event do |e|
      Registration.where(
        profile: user.profiles,
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
      s.collection.submissions_open? and s.profile.in? user.profiles
    end
    can [ :read, :update ], Submission do |s|
      s.profile.in? user.profiles
    end
    can :read, Submission do |s|
      s.accepted?
    end
    cannot :destroy, Submission

    can :manage, Registration do |r|
      r.collection.present? and r.collection.has_admin?(user)
    end
    can :create, Registration do |r|
      r.registration_option.nil? or (r.registration_option.collection.registrations_open? and r.profile.in? user.profiles)
    end
    can :read, Registration do |r|
      r.profile.in?(user.profiles)
    end
    can :view_payments, Registration do |r|
      r.profile.in?(user.profiles) and r.registration_option.cost.present?
    end

    can :manage, Invitation do |i|
      i.collection.has_admin?(user)
    end
    can :read, Invitation do |i|
      i.profile.in?(user.profiles) || i.status == :accepted
    end
    can :respond_to, Invitation do |i|
      i.profile.in?(user.profiles) && i.status != :revoked
    end

    can :create, Profile
    can :manage, Profile do |p|
      user.in? p.users
    end
    can :manage, Profile, email: user.email
    cannot :destroy, Profile do |p|
      p.submissions.any?
    end

    return unless user.site_admin?
    can :manage, :all
  end
end
