class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end

  def inherited(attribute)
    public_send(attribute).present? ? public_send(attribute) : parent&.inherited(attribute)
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
