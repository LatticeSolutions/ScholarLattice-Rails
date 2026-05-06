class SubmissionMailer < ApplicationMailer
  def submission_created(submission)
    @submission = submission
    if @submission.user.subscribed?("site_emails")
      mail(
        from: email_address_with_name(
          "submissions@mailer.scholarlattice.org",
          "#{submission.collection.root.title} via ScholarLattice"
        ),
        to: submission.notification_emails,
        subject: "Submission to #{submission.collection.title} received by ScholarLattice",
        reply_to: submission.collection.reply_to_emails,
      )
    end
  end

  def submission_updated(submission)
    @submission = submission
    if @submission.user.subscribed?("site_emails")
      mail(
        from: email_address_with_name(
          "submissions@mailer.scholarlattice.org",
          "#{submission.collection.root.title} via ScholarLattice"
        ),
        to: submission.notification_emails,
        subject: "Submission to #{submission.collection.title} updated on ScholarLattice",
        reply_to: submission.collection.reply_to_emails,
      )
    end
  end
end
