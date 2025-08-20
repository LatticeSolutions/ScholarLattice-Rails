class SubmissionMailer < ApplicationMailer
  def submission_created(submission)
    @submission = submission
    mail(
      to: submission.notification_emails,
      subject: "Submission received by ScholarLattice",
      reply_to: submission.collection.reply_to_emails,
    )
  end

  def submission_updated(submission)
    @submission = submission
    mail(
      to: submission.notification_emails,
      subject: "Submission updated on ScholarLattice",
      reply_to: submission.collection.reply_to_emails,
    )
  end
end
