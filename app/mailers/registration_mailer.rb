class RegistrationMailer < ApplicationMailer
  def registration_created(registration)
    @registration = registration
    if @registration.user.mailkick_subscribed?("site_emails")
      mail(
        from: email_address_with_name(
          "registrations@mailer.scholarlattice.org",
          "#{registration.collection.root.title} via ScholarLattice"
        ),
        to: registration.user.email,
        subject: "Registration for #{registration.collection.title} on ScholarLattice",
        reply_to: submission.collection.reply_to_emails,
      )
    end
  end
end
