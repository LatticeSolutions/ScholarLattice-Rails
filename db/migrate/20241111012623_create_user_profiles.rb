class CreateUserProfiles < ActiveRecord::Migration[8.0]
  def up
    create_table :profiles_users, id: false do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.references :profile, null: false, foreign_key: true, type: :uuid
    end
    # Create UserProfile associations
    Profile.all.each do |p|
      p.users = [ User.find(p.user_id) ]
      p.save
    end
  end
  def down
    drop_table :profiles_users
  end
end
