class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:gmail_username)
  layout 'mailer'
end
