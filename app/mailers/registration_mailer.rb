class RegistrationMailer < ApplicationMailer
  def registration_created(registration)
    @registration = registration
    mail(
      to: registration.user.email,
      subject: "Registration for #{registration.collection.title} on ScholarLattice",
      reply_to: registration.collection.reply_to_emails,
    )
  end
  def verify_email(email, title, token)
    @title = title
    @token = token
    mail(
      to: email,
      subject: "Verify email to register for #{title} on ScholarLattice"
    )
  end
end
