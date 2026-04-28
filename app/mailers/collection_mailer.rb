class CollectionMailer < ApplicationMailer
  def message_submitter(submission, subject, message)
    @submission = submission
    @subject = subject
    @message = message
    mail(
      from: "#{@submission.collection.root.title} via ScholarLattice <updates@mailer.scholarlattice.org>",
      to: @submission.user.email,
      subject: @subject,
      reply_to: @submission.collection.reply_to_emails,
    )
  end
end
