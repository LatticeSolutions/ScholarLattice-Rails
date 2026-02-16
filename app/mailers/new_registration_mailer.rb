class NewRegistrationMailer < ApplicationMailer
  def new_registration_created(new_registration)
    @new_registration = new_registration
    mail(
      from: "ScholarLattice Registrations <registrations@mailer.scholarlattice.org>",
      to: new_registration.user.email,
      subject: "Registration for #{new_registration.collection.title} on ScholarLattice",
      reply_to: new_registration.collection.reply_to_emails,
    )
  end
end
