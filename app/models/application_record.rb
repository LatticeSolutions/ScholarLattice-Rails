class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def inherited(attribute)
    public_send(attribute).present? ? public_send(attribute) : parent&.inherited(attribute)
  end

  def ability
    @ability ||= Ability.new(self)
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
