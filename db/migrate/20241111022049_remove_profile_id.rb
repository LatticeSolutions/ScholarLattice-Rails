class RemoveProfileId < ActiveRecord::Migration[8.0]
  def up
    remove_column :profiles, :user_id
  end
  def down
    add_reference :profiles, :user, type: :uuid
    # Create user_id associations
    Profile.all.each do |p|
      if p.users.any?
        p.update(user_id: p.users.first.id)
      end
    end
  end
end
