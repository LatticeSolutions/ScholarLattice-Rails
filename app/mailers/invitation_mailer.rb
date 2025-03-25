class InvitationMailer < ApplicationMailer
  def invitation_created(invitation)
    @invitation = invitation
    mail(to: invitation.notification_emails, subject: "Invitation to submit to #{invitation.collection.name} on ScholarLattice")
  end
end
