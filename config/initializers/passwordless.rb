Passwordless.configure do |config|
  config.default_from_address = "no-reply@mailer.scholarlattice.org"
  config.failure_redirect_path = "/users/sign_in" # After a sign in fails
  config.token_generator = lambda do |_|
    [ *"A".."F", *"1".."9" ].sample(8).join
  end
  config.restrict_token_reuse = false
  config.expires_at = lambda { 3.months.from_now } # How long until a signed in session expires.
end
