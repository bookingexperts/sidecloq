module Sidecloq
  class JobEnqueuer
    attr_reader :spec

    def initialize(spec)
      # Dup to prevent JID reuse in subsequent enqueue's
      @spec = spec.dup
      @spec['class'] = Object.const_get(spec['class'])
    end

    def enqueue
      Sidekiq::Client.push(spec)
    end

    private unless $TESTING

    def klass
      spec['class']
    end
  end
end
