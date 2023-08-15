require_relative 'helper'
require 'sidekiq/api'

class TestJobEnqueuer < Sidecloq::Test
  describe 'job_enqueuer' do
    before { Sidekiq.redis(&:flushdb) }
    let(:enqueuer) { Sidecloq::JobEnqueuer.new(spec) }

    describe 'normal job' do
      let(:spec) { { 'cron' => '1 * * * *', 'class' => 'DummyJob', 'args' => [] } }

      it 'is queued' do
        enqueuer.enqueue
        job = Sidekiq::Queue.new.first
        assert_equal 'DummyJob', job.klass
      end

      it 'applies the job class sidekiq options' do
        DummyJob.sidekiq_options retry: false
        enqueuer.enqueue
        job = Sidekiq::Queue.new.first
        assert_equal false, job.item['retry']
      end

      it 'keeps the origininal spec' do
        original_spec = spec.dup
        enqueuer.enqueue
        assert_equal original_spec, spec
      end
    end
  end
end
