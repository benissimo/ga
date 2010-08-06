ActionMailer::Base.delivery_method = :sendmail
ActionMailer::Base.raise_delivery_errors = true

#ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.alice.it',
  :port           => 25,
  :domain         => 'alice.it',
  #:authentication => :login,
  :user_name      => 'benjamin.ellis',
  :password       => ''
}