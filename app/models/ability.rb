# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # default abilities
    can :read, Collection
    can :read, Page, visibility: [ :public, :unlisted ]
    can :read, Submission, status: :accepted
    can :read, Registration, status: :accepted
    can :read, RegistrationOption
    can :read, Event
    can [ :read, :create ], User

    return unless user.present?

    can :read, :dashboard

    can [ :like, :dislike ], Collection
    can :manage, Collection do |c|
      c.has_admin? user
    end
    cannot :destroy, Collection do |c|
      c.children?
    end

    can :manage, Page do |p|
      p.has_admin? user
    end

    can :manage, Event do |e|
      e.collection.has_admin?(user)
    end
    can :access_webinar, Event do |e|
      e.collection.public_webinars or e.collection.path_ids.intersect?(user.registrations.where(status: :accepted).pluck(:collection_id))
    end

    can :manage, Submission do |s|
      s.collection.blank? || (can? :manage, s.collection) || s.user_id.blank? || s.user_id == user.id
    end

    can [ :read, :create ], Registration do |r|
      r.user.nil? || r.user_id == user.id
    end
    can :update, Registration do |r|
      r.user_id == user.id && !r.accepted?
    end
    can :manage, Registration do |r|
      can? :manage, r.collection
    end
    can :destroy, Registration do |r|
      can? :manage, r.collection
    end

    can :manage, RegistrationOption do |ro|
      can? :manage, ro.collection
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
