# MultiSMTPPlus

<p align="center">
  <img src="multi-smtp-pro-logo.png" alt="MultiSMTP Pro" width="420" />
</p>

Email delivery is a critical component of many web applications. Occasionally
third-party services can experience temporary downtime. We can achieve automatic failover by overriding the default email delivery method with MultiSMTP.

MultiSMTP takes an array of (1..N) SMTP providers and will iterate over each provider until the email is successfully sent.

## Compatibility

- Ruby 3.1–3.3
- Rails 6.1, 7.x, 8.0+
- Mail >= 2.7, < 3.0

## Installation

Add this line to your application's Gemfile:

```ruby
gem "multi_smtp_plus"
```

Then bundle:

```
$ bundle
```

## Configuration

Set the delivery method to `:multi_smtp` for each environment that should use
the automatic failover. Registration is lazy via `ActiveSupport.on_load(:action_mailer)`.

```ruby
# config/environments/{staging,production}.rb
Rails.application.configure do
  config.action_mailer.delivery_method = :multi_smtp
end
```

In an initializer configure the MultiSMTP class with an array of (1..N) SMTP
providers.

```ruby
# config/initializers/multi_smtp.rb

# Optional: choose how providers are ordered for each delivery
# :sequential (default) or :round_robin
MultiSMTP.rotation_strategy = :round_robin

# Optional: provide a state store for cross-process round robin
# It must respond to `#incr(key)` and return an Integer. Example using Redis:
# MultiSMTP.state_store = Redis.new

sendgrid_settings = {
  address: 'smtp.sendgrid.net',
  authentication: :plain,
  domain: 'example.com',
  password: ENV['SENDGRID_PASSWORD'],
  port: 587,
  user_name: ENV['SENDGRID_USERNAME'],
  # Optional: dynamically skip this provider when a condition is met
  # e.g., free-tier quota exhausted
  skip_if: -> { ENV['SENDGRID_QUOTA_EXHAUSTED'] == '1' }
}

mailgun_settings = {
  address: 'smtp.mailgun.org',
  authentication: :plain,
  domain: 'example.com',
  password: ENV['MAILGUN_PASSWORD'],
  port: 587,
  user_name: ENV['MAILGUN_USERNAME'],
  # Example: skip based on a runtime counter (e.g., Redis)
  # skip_if: -> { Redis.current.get('mailgun:monthly_count').to_i > 990 }
}

MultiSMTP.smtp_providers = [sendgrid_settings, mailgun_settings]
```

### Switching between free tiers (never pay for email)

Use either or both of the following:

- **Round-robin rotation**: spreads deliveries among providers so you consume free quotas evenly.
- **Per-provider `skip_if`**: a Proc/lambda evaluated before attempting a delivery. Return true to skip a provider (e.g., when you detect free-tier quota is exhausted).

For cross-process/app-server rotation, configure `MultiSMTP.state_store` with a Redis-like store that implements `#incr(key)`.

## Error Notifications

If all SMTP providers fail the default behavior is to re-raise the original exception.
However, we can also specify custom notifications.

```ruby
# config/initializers/multi_smtp.rb
require "multi_smtp/notifiers/airbrake"

MultiSMTP.error_notifier = MultiSMTP::Notifiers::Airbrake
```

If there is another type of notification you'd like to receive, you can create a
new notifier that implements the class method `.notify(exception, mail)`.

```ruby
class MyCustomNotifier
  def self.notify(exception, mail)
    # send to your observability tool, log with context, etc.
  end
end

MultiSMTP.error_notifier = MyCustomNotifier
```

See the [Airbrake Notifier](lib/multi_smtp/notifiers/airbrake.rb) for more details.

## Migration from <= 0.0.2

- Notifier signature changed from `notify(mail)` to `notify(exception, mail)` to provide error context.
- Added `MultiSMTP.rotation_strategy` and `MultiSMTP.state_store` for provider ordering.
- Added per-provider `:skip_if` Proc for dynamic skipping (useful for free-tier quotas).
- Rails registration is now lazy via `ActiveSupport.on_load(:action_mailer)`.
- Runtime dependency updated to `mail >= 2.7, < 3` for Rails 6–8 compatibility.

## Contributing

1. Fork it ( https://github.com/harlow/multi_smtp/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
