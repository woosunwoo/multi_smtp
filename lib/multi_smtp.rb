require "multi_smtp/mail"
require "multi_smtp/version"

module MultiSMTP
  def self.error_notifier=(notifier)
    @error_notifier = notifier
  end

  def self.error_notifier
    @error_notifier || false
  end

  def self.smtp_providers=(providers)
    @smtp_providers = providers
  end

  def self.smtp_providers
    @smtp_providers || raise("MultiSMTP Error: Please specify smtp_providers.")
  end

  # Optional rotation strategy for provider ordering. Supported: :sequential (default), :round_robin
  def self.rotation_strategy=(strategy)
    @rotation_strategy = strategy
  end

  def self.rotation_strategy
    @rotation_strategy || :sequential
  end

  # Optional state store for cross-process round robin. Must respond to :incr(key) and return an Integer
  # Example: a thin wrapper around Redis INCR. If nil, round_robin falls back to per-process rotation.
  def self.state_store=(store)
    @state_store = store
  end

  def self.state_store
    @state_store
  end
end

if defined?(Rails)
  begin
    require "active_support"
    ActiveSupport.on_load(:action_mailer) do
      ActionMailer::Base.add_delivery_method(:multi_smtp, MultiSMTP::Mail)
    end
  rescue LoadError
    # Fallback for environments without ActiveSupport loaded early
    ActionMailer::Base.add_delivery_method(:multi_smtp, MultiSMTP::Mail) if defined?(ActionMailer)
  end
end
