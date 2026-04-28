class RegistrationMailer < ApplicationMailer
  def registration_created(registration)
    @registration = registration
    mail(
      from: email_address_with_name(
        "registrations@mailer.scholarlattice.org",
        "#{registration.collection.root.title} via ScholarLattice"
      ),
      to: registration.user.email,
      subject: "Registration for #{registration.collection.title} on ScholarLattice",
      reply_to: @registration.collection.admins.any? ? @registration.collection.admins.map { |a| a.user.email }.to_a : nil,
    )
  end
end
