module Sidecloq
  # Useful stuff
  module Utils
    # Sets the Sidekiq::Logging context automatically with direct calls to
    # *.logger
    class ContextLogger
      def initialize(ctx)
        @context = ctx
      end

      def method_missing(meth, *args)
        Sidekiq::Context.with(@context) do
          Sidekiq.logger.send(meth, *args)
        end
      end
    end

    def logger
      @logger ||= ContextLogger.new(
        defined?(Sidekiq::Logging) ? 'Sidecloq' : { sidecloq: true }
      )
    end

    def redis(&block)
      self.class.redis(&block)
    end

    # finds cron lines that are impossible, like '0 5 31 2 *'
    # note: does not attempt to fully validate the cronline
    def will_never_run(cronline)
      # look for non-existent day of month
      split = cronline.split(/\s+/)
      if split.length > 3 && split[2] =~ /\d+/ && split[3] =~ /\d+/

        month = split[3].to_i
        day = split[2].to_i
        # special case for leap-year detection
        return true if month == 2 && day <= 29

        return !Date.valid_date?(0, month, day)

      else
        false
      end
    end

    module ClassMethods
      def redis(&block)
        if block
          Sidekiq.redis(&block)
        else
          Sidekiq.redis_pool.checkout
        end
      end
    end

    def self.included(klass)
      klass.extend(ClassMethods)
    end
  end
end
