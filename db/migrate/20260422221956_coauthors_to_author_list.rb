class CoauthorsToAuthorList < ActiveRecord::Migration[8.0]
  def change
    Submission.where.not(coauthors: nil).each do |s|
      s.update coauthors: "#{s.user.name}, with #{s.coauthors}"
    end
    rename_column :submissions, :coauthors, :author_list
  end
end
