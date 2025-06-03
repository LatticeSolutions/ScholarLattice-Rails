class MergeProfilesIntoUsers < ActiveRecord::Migration[8.0]
  def up
    # Add profile columns to users table
    add_column :users, :first_name, :string, null: false, default: 'FirstName'
    add_column :users, :last_name, :string, null: false, default: 'LastName'
    add_column :users, :affiliation, :string
    add_column :users, :position, :string
    add_column :users, :position_type, :integer, default: 0

    # Add foreign keys for users instead of profiles
    add_reference :invitations, :user, foreign_key: true
    add_reference :submissions, :user, foreign_key: true
    add_reference :registrations, :user, foreign_key: true

    # Copy data from profiles to users
    Profile.all.each do |profile|
      user = profile.users.where(email: profile.email).first
      if user
        # Update existing user with profile data
        user.update(
          first_name: profile.first_name,
          last_name: profile.last_name,
          affiliation: profile.affiliation,
          position: profile.position,
          position_type: profile.position_type
        )
      else
        user = User.find_by(email: profile.email)
        # If no user exists with email, create it
        if user.nil?
          user = User.create(
            email: profile.email,
            first_name: profile.first_name,
            last_name: profile.last_name,
            affiliation: profile.affiliation,
            position: profile.position,
            position_type: profile.position_type
          )
        end
      end
      # In any case we now have a user, so associate
      # all foreign keys to the appropriate user
      profile.invitations.update_all(user_id: user.id)
      profile.registrations.update_all(user_id: user.id)
      profile.submissions.update_all(user_id: user.id)
    end

    # Drop the profiles table
    drop_table :profiles
  end
end
