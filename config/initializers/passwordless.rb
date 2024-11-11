Passwordless.configure do |config|
  config.default_from_address = "no-reply@mailer.scholarlattice.org"
  config.success_redirect_path = "/dashboard" # After a user successfully signs in
  config.failure_redirect_path = "/users/sign_in" # After a sign in fails
  config.sign_out_redirect_path = "/" # After a user signs out
  config.token_generator = lambda do |_|
    [ *"A".."F", *"1".."9" ].sample(8).join
  end
  config.restrict_token_reuse = false
end
