class AddCoauthorsToSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :submissions, :coauthors, :string
    reversible do |change|
      change.up do
        Submission.where(title: nil).update_all(title: "Untitled Submission")
        change_column :submissions, :title, :string, null: false
      end
      change.down { change_column :submissions, :title, :string, null: true }
    end
  end
end
