class RegistrationMailer < ApplicationMailer
  def registration_created(registration)
    @registration = registration
    mail(
      to: registration.profile.email,
      subject: "Registration for #{registration.collection.title} on ScholarLattice"
    )
  end
end
