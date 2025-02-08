class SubmissionMailer < ApplicationMailer
  def submission_created(submission)
    @submission = submission
    mail(to: submission.notification_emails, subject: "Submission received by ScholarLattice")
  end

  def submission_updated(submission)
    @submission = submission
    mail(to: submission.notification_emails, subject: "Submission updated on ScholarLattice")
  end
end
