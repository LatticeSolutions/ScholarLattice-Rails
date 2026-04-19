class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  delegate :can?, :cannot?, to: :ability

  def ability
    @ability ||= Ability.new(self)
  end

  def inherited(attribute)
    public_send(attribute).present? ? public_send(attribute) : parent&.inherited(attribute)
  end

  def to_html(attribute)
    Kramdown::Document.new(public_send(attribute)).to_html
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
