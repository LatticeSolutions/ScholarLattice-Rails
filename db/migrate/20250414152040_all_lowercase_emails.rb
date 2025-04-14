class AllLowercaseEmails < ActiveRecord::Migration[8.0]
  def up
    User.find_each do |user|
      user.update(email: user.email.downcase)
    end
    Profile.find_each do |profile|
      profile.update(email: profile.email.downcase)
    end
  end
  def down
    # No need to revert, as the email is already in lowercase.
  end
end
