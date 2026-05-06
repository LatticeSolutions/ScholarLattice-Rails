class CollectionMailer < ApplicationMailer
  def message_submitter(submission, subject, message)
    @submission = submission
    @subject = subject
    @message = message
    if @submission.user.mailkick_subscribed?("site_emails")
      mail(
        from: email_address_with_name(
          "updates@mailer.scholarlattice.org",
          "#{@submission.collection.root.title} via ScholarLattice"
        ),
        to: @submission.user.email,
        subject: @subject,
        reply_to: @submission.collection.reply_to_emails,
      )
    end
  end
end
