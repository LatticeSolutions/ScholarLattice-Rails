class MergeProfilesIntoUsers < ActiveRecord::Migration[8.0]
  def up
    # Add profile columns to users table
    add_column :users, :first_name, :string, null: false, default: 'FirstName'
    add_column :users, :last_name, :string, null: false, default: 'LastName'
    add_column :users, :affiliation, :string, null: false, default: 'Unaffiliated'
    add_column :users, :position, :string, null: false, default: 'None'
    add_column :users, :position_type, :integer, null: false, default: 4
    add_column :users, :verified_email, :boolean, null: false, default: false

    # Add table for UserManagements
    create_table :user_managements, id: false do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :manager, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.timestamps
    end

    # Add foreign keys for users instead of profiles
    add_reference :invitations, :user, foreign_key: true, null: true, type: :uuid
    add_reference :submissions, :user, foreign_key: true, null: true, type: :uuid
    add_reference :registrations, :user, foreign_key: true, null: true, type: :uuid

    handled_profile_ids = []
    handled_user_ids = []

    # Copy data from main profiles to users
    User.all.each do |user|
      profile = user.main_profile
      next unless profile
      # Update existing user with profile data
      user.update(
        first_name: profile.first_name,
        last_name: profile.last_name,
        affiliation: profile.affiliation || 'Unaffiliated',
        position: profile.position || 'None',
        position_type: profile.position_type || 4,
        verified_email: true,
      )
      # Associate all foreign keys to the appropriate user
      profile.invitations.update_all(user_id: user.id)
      profile.registrations.update_all(user_id: user.id)
      profile.submissions.update_all(user_id: user.id)
      handled_profile_ids << profile.id
      handled_user_ids << user.id
    end

    # Associate all profiles with users
    Profile.all.each do |profile|
      next if handled_profile_ids.include?(profile.id)
      user = User.find_by(email: profile.email.downcase)
      if user.nil?
        # create a new user if not found
        user = User.create!(
          email: profile.email.downcase,
          first_name: profile.first_name,
          last_name: profile.last_name,
          affiliation: profile.affiliation || 'Unaffiliated',
          position: profile.position || 'None',
          position_type: profile.position_type || 4
        )
        profile.users.each do |manager|
          UserManagement.create!(
            user: user,
            manager: manager
          )
        end
      end
      # Associate all foreign keys to the user
      profile.invitations.update_all(user_id: user.id)
      profile.registrations.update_all(user_id: user.id)
      profile.submissions.update_all(user_id: user.id)
      unless handled_user_ids.include?(user.id)
        handled_user_ids << user.id
      end
      handled_profile_ids << profile.id
    end

    if Invitation.where(user_id: nil).any?
      raise "There are Invitations without a user_id after migration!"
    end
    if Registration.where(user_id: nil).any?
      raise "There are Registrations without a user_id after migration!"
    end
    if Submission.where(user_id: nil).any?
      raise "There are Submissions without a user_id after migration!"
    end

    change_column_null :invitations, :user_id, false
    change_column_null :submissions, :user_id, false
    change_column_null :registrations, :user_id, false

    # # Drop the profiles table
    # remove_column :invitations, :profile_id
    # remove_column :submissions, :profile_id
    # remove_column :registrations, :profile_id
    # drop_table :profiles_users
    # drop_table :profiles
  end
end
