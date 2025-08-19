require "mail"

module MultiSMTP
  class Mail < Mail::SMTP
    def initialize(default_settings)
      @default_settings = default_settings || {}
      super(@default_settings)
    end

    def deliver!(mail)
      providers = ordered_providers

      providers.each_with_index do |smtp_provider, index|
        self.settings = default_settings.merge(smtp_provider)

        begin
          super(mail)
          break
        rescue Exception => e
          next unless all_providers_failed?(index, providers)

          if error_notifier
            # Pass the exception and the mail to the notifier
            error_notifier.notify(e, mail)
          else
            raise e
          end
        end
      end
    end

    private

    def ordered_providers
      case MultiSMTP.rotation_strategy
      when :round_robin
        rotate_round_robin(MultiSMTP.smtp_providers.dup)
      else
        MultiSMTP.smtp_providers.dup
      end
    end

    def rotate_round_robin(list)
      return list if list.empty? || list.size == 1

      # Cross-process if state_store provided, else per-process fallback
      start_idx = if (store = MultiSMTP.state_store)
        store.incr("multi_smtp:rr:index") % list.size
      else
        self.class.__per_process_counter = (self.class.__per_process_counter + 1) % list.size
      end

      list.rotate(start_idx)
    end

    def self.__per_process_counter
      @__per_process_counter ||= 0
    end

    def self.__per_process_counter=(val)
      @__per_process_counter = val
    end

    def smtp_providers
      @smtp_providers ||= MultiSMTP.smtp_providers
    end

    def error_notifier
      @error_notifier ||= MultiSMTP.error_notifier
    end

    def all_providers_failed?(index, providers)
      (providers.size - 1) == index
    end

    attr_reader :default_settings
  end
end
