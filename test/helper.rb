require 'simplecov'
SimpleCov.start

$TESTING = true
# disable minitest/parallel threads
ENV['N'] = '0'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sidecloq'

require 'minitest/autorun'

# from sidekiq's test helper:

REDIS_URL = ENV['REDIS_URL'] || 'redis://localhost/15'

Sidekiq.configure_client do |config|
  config.redis = { url: REDIS_URL }
end

Sidekiq.logger.level = ENV['LOG_LEVEL'] || Logger::ERROR

module Sidecloq
  class Test < Minitest::Test
  end
end

class DummyLocker
  def with_lock
    yield
  end

  def locked?
    true
  end

  def stop(timeout = nil)
  end
end

class DummyScheduler
  def run
  end

  def stop(timeout = nil)
  end
end

class DummyJob
  include Sidekiq::Worker
end

def define_rails!
  unless defined? Rails
    Object.const_set('Rails', Class.new do
      @env = 'development'

      def self.root
        File.expand_path('../', __FILE__)
      end

      def self.env
        @env
      end

      def self.env=(env = nil)
        @env = env
      end
    end)
  end
end

def undefine_rails!
  if defined? Rails
    Object.send(:remove_const, :Rails)
  end
end

# also courtesy of sidekiq:
trap 'USR1' do
  threads = Thread.list

  puts
  puts '=' * 80
  puts "Received USR1 signal; printing all #{threads.count} thread backtraces."

  threads.each do |thr|
    description = thr == Thread.main ? 'Main thread' : thr.inspect
    puts
    puts "#{description} backtrace: "
    puts thr.backtrace.join("\n")
  end

  puts '=' * 80
end
