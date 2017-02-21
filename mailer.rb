class Mailer
  OPTIONS = {
    address:               ENV['MAILER_SMTP_HOST'],
    port:                  ENV['MAILER_PORT'],
    domain:                ENV['MAILER_DOMAIN'],
    user_name:             ENV['MAILER_USER_NAME'],
    password:              ENV['MAILER_PASSWORD'],
    authentication:        'plain',
    enable_starttls_auto:  true
  }
  class << self
    def send(to:, title: nil)
      mail = Mail.new
      mail.subject = "Download OK - #{title}"
      mail.from = ENV['MAILER_EMAIL']
      mail.to = "#{to}"
      mail.body = "Download OK - #{title}"
      mail.delivery_method :smtp, OPTIONS
      mail.deliver!
    end
  end
end
