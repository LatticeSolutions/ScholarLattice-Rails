class RegistrationMailer < ApplicationMailer
  def registration_created(registration)
    @registration = registration
    mail(
      from: "#{registration.collection.root.title} via ScholarLattice <registrations@mailer.scholarlattice.org>",
      to: registration.user.email,
      subject: "Registration for #{registration.collection.title} on ScholarLattice",
      reply_to: registration.collection.reply_to_emails,
    )
  end
end
