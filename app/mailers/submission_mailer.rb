class SubmissionMailer < ApplicationMailer
  def submission_created(submission)
    @submission = submission
    mail(
      from: "ScholarLattice Submissions <submissions@mailer.scholarlattice.org>",
      to: submission.notification_emails,
      subject: "Submission to #{submission.collection.title} received by ScholarLattice",
      reply_to: submission.collection.reply_to_emails,
    )
  end

  def submission_updated(submission)
    @submission = submission
    mail(
      from: "ScholarLattice Submissions <submissions@mailer.scholarlattice.org>",
      to: submission.notification_emails,
      subject: "Submission to #{submission.collection.title} updated on ScholarLattice",
      reply_to: submission.collection.reply_to_emails,
    )
  end
end
