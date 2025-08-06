class StripWhitespace < ActiveRecord::Migration[8.0]
  def change
    Profile.find_each do |profile|
      profile.save # to trigger before_save callbacks that strip whitespace
    end
  end
end
