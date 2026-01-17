class SubmissionMailer < ApplicationMailer
  def submission_created(submission)
    @submission = submission
    mail(
      from: "submissions@mailer.scholarlattice.org",
      to: submission.notification_emails,
      subject: "Submission received by ScholarLattice",
      reply_to: submission.collection.reply_to_emails,
    )
  end

  def submission_updated(submission)
    @submission = submission
    mail(
      from: "ScholarLattice Submissions <submissions@mailer.scholarlattice.org>",
      to: submission.notification_emails,
      subject: "Submission updated on ScholarLattice",
      reply_to: submission.collection.reply_to_emails,
    )
  end

  def verify_email(email, title, token)
    @title = title
    @token = token
    mail(
      from: "ScholarLattice Submissions <submissions@mailer.scholarlattice.org>",
      to: email,
      subject: "Verify email to submit to #{title} on ScholarLattice"
    )
  end
end
