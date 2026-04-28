class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("updates@mailer.scholarlattice.org", "ScholarLattice Updates")
  default reply_to: "support@scholarlattice.org"
  layout "mailer"
  before_action :attach_logo

  private

  def attach_logo
    attachments.inline["logo.png"] = File.read(Rails.root.join("app/assets/images/logo.png"))
  end
end
