class RegistrationMailer < ApplicationMailer
  def registration_created(registration)
    @registration = registration
    mail(
      to: registration.user.email,
      subject: "Registration for #{registration.collection.title} on ScholarLattice",
      reply_to: registration.collection.reply_to_emails,
    )
  end
end
