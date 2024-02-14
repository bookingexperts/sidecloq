module Sidecloq
  class MissedJobsEnqueuer
    def enqueue_missed_jobs(schedule)
      schedule.job_specs.each do |item|
        name, spec = item

        last_time = last_enqueued_at(name)
        next if last_time.nil? # Never enqueued before, probably a new job. Skip it.
        next if last_time >= previous_time(spec['cron'])

        JobEnqueuer.new(spec).enqueue
        log_last_enqueued(name)
      end
    end

    def log_last_enqueued(name)
      Sidekiq.redis_pool.with { |redis| redis.set("sidecloq_enqueued_last_at_#{name}", Time.now.to_i) }
    end

    private

    def last_enqueued_at(name)
      Sidekiq.redis_pool.with { |redis| redis.get("sidecloq_enqueued_last_at_#{name}")&.to_i }
    end

    def previous_time(cron)
      Rufus::Scheduler.parse_cron(cron).previous_time.to_i
    end
  end
end
