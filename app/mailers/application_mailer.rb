class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@mailer.scholarlattice.org"
  layout "mailer"
end
