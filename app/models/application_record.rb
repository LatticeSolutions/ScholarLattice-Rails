class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
