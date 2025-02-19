class LimitOneEventPerSubmission < ActiveRecord::Migration[8.0]
  def change
    remove_index :events, :submission_id
    add_index :events, :submission_id, unique: true
  end
end
