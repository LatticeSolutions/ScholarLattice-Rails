class InvitationMailer < ApplicationMailer
  def invitation_created(invitation)
    @invitation = invitation
    mail(
      from: email_address_with_name(
        "invitations@mailer.scholarlattice.org",
        "#{invitation.collection.root.title} via ScholarLattice"
      ),
      to: invitation.notification_emails,
      subject: "Invitation to submit to #{invitation.collection.title} on ScholarLattice",
      reply_to: invitation.collection.reply_to_emails,
    )
  end
end
