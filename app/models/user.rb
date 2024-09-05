class User < ApplicationRecord
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP } # <-- validates that the email is in correct format, and that it is unique

  passwordless_with :email # <-- tells Passwordless which field stores the email address
end
