![Sidecloq](assets/clock_a_clock_on_the_side.png)

# Sidecloq

Recurring / Periodic / Scheduled / Cron job extension for
[Sidekiq](https://github.com/mperham/sidekiq)

## Why

There are several options for running periodic tasks with Sidekiq,
including [sidekiq-scheduler](https://github.com/Moove-it/sidekiq-scheduler),
[sidekiq-cron](https://github.com/ondrejbartas/sidekiq-cron), as well as
[Sidekiq Enterprise](https://sidekiq.org/products/enterprise.html).  Each tackles the
problem slightly differently. Sidecloq is inspired by various facets
of these projects, as well as
[resque-scheduler](https://github.com/resque/resque-scheduler). I urge
you to take a look at all of these options to see what works best for
you.

Sidecloq is:

- **Lightweight:** Celluloid is not required.  This coincides well with
  Sidekiq 4/5, which no longer use Celluloid.
- **Clean:** Sidecloq leverages only the public API of Sidekiq, and does
  not pollute the Sidekiq namespace.
- **Easy to deploy:** Sidecloq boots with all Sidekiq processes,
  automatically.  Leader election ensures only one process enqueues
  jobs, and a new leader is automatically chosen should the current
  leader die.
- **Easy to configure:** Schedule configuration is done in YAML, using
  the familiar cron syntax. No special DSL or job class mixins required.

## Installation

Clone the source code to a local directory and add the following lines to your application's Gemfile:

```ruby
path 'relative/path/to/parent/directory/of/gem' do
  gem 'sidecloq'
end
```

And then execute:

  $ bundle

## Configuration

### Quickstart

Tell Sidecloq where your schedule file is located:

```ruby
Sidecloq.configure do |config|
  config[:schedule_file] = "path/to/myschedule.yml"
end
```
### Rails

If using Rails, and your schedule is located at config/sidecloq.yml,
Sidecloq will find the schedule automatically (ie, you don't have to use
the above configuration block).

## Schedule file format

### Example:

```yaml
my_scheduled_job: # a unique name for this schedule
  class: Jobs::DoWork # the job class
  args: [100]       # (optional) set of arguments
  cron: "* * * * *" # cron formatted schedule
  queue: "queue_name" # Sidekiq queue for job

my_scheduled_job_with_args:
  class: Jobs::WorkerWithArgs
  args:
    batch_size: 100
  cron: "1 1 * * *"
  queue: "queue_name"

my_other_scheduled_job:
  class: Jobs::AnotherClassName
  cron: "1 1 * * *"
  queue: "a_different_queue"
```

### Rails

If using Rails, you can nest the schedules under top-level environment
keys, and Sidecloq will select the correct group based on the Rails
environment.  This is useful for development/staging scenarios. For
example:

```yaml
production:
  # these will only run in production
  my_scheduled_job:
    class: Jobs::ClassName
    cron: "* * * * *"
    queue: "queue_name"

staging:
  # this will only run in staging
  my_other_scheduled_job:
    class: Jobs::AnotherClassName
    cron: "1 1 * * *"
    queue: "a_different_queue"
```

## Web Extension

Add Sidecloq::Web after Sidekiq::Web:

```ruby
require 'sidekiq/web'
require 'sidecloq/web'
```

This will add a "Recurring" tab to the sidekiq web ui, where the loaded
schedules are displayed.  You can enqueue a job immediately by clicking
it's corresponding "Enqueue now" button.

![Sidecloq web ui extension screenshot](assets/screenshot.png)

## Supported Ruby Versions

This library aims to support and is tested against the following Ruby versions:

* Ruby 3.1.x
* Ruby 3.2.x

If something doesn't work on one of these versions, it's a bug.

This library may inadvertently work (or seem to work) on other Ruby versions,
however support will only be provided for the versions listed above.

If you would like this library to support another Ruby version or
implementation, you may volunteer to be a maintainer. Being a maintainer
entails making sure all tests run and pass on that implementation. When
something breaks on your implementation, you will be responsible for providing
patches in a timely fashion. If critical issues for a particular implementation
exist at the time of a major release, support for that Ruby version may be
dropped.

## Supported Sidekiq Versions

This library aims to support and work with following Sidekiq versions:

* Sidekiq 6.5.x
* Sidekiq 7.0.x
* Sidekiq 7.1.x

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
