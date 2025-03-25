class InvitationMailer < ApplicationMailer
  def invitation_created(invitation)
    @invitation = invitation
    mail(to: invitation.notification_emails, subject: "Submission received by ScholarLattice")
  end
end
