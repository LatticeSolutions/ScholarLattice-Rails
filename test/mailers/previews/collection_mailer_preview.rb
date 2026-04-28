# Preview all emails at /rails/mailers/collection_mailer
class CollectionMailerPreview < ActionMailer::Preview
  # Preview this email at /rails/mailers/collection_mailer/message_submitter
  def message_submitter
    submission = Submission.take
    CollectionMailer.message_submitter(
      submission,
      "Sample subject",
      "## Sample markdown header\n\nSample markdown **formatting**"
    )
  end
end
