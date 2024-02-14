module Sidecloq
  class MissedJobsEnqueuer
    def redis
      Sidekiq.redis_pool.checkout
    end

    def enqueue_missed_jobs(schedule)
      schedule.job_specs.each do |item|
        name, spec = item

        next if (last_enqueued_at(name) || Time.now.to_i) >= previous_time(spec['cron'])

        JobEnqueuer.new(spec).enqueue
        log_last_enqueued(name)
      end
    end

    def log_last_enqueued(name)
      redis.set("sidecloq_enqueued_last_at_#{name}", Time.now.to_i)
    end

    private

    def last_enqueued_at(name)
      redis.get("sidecloq_enqueued_last_at_#{name}")&.to_i
    end

    def previous_time(cron)
      Rufus::Scheduler.parse_cron(cron).previous_time.to_i
    end
  end
end
