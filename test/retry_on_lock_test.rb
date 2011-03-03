require 'rubygems'
require 'test/unit'
require 'resque'
require 'resque/plugins/retry_on_lock'

$counter = 0

class TestJob
  extend Resque::Plugins::RetryOnLock
  @queue = :test

  def self.perform
    $counter += 1
    sleep 1
  end
end

class LockTest < Test::Unit::TestCase
  def test_lint
    assert_nothing_raised do
      Resque::Plugin.lint(Resque::Plugins::RetryOnLock)
    end
  end

  def test_version
    major, minor, patch = Resque::Version.split('.')
    assert_equal 1, major.to_i
    assert minor.to_i >= 7
  end

  def test_lock
    (count = 3).times { Resque.enqueue(TestJob) }
    worker = Resque::Worker.new(TestJob.instance_eval{@queue})

    until (size = Resque.size(TestJob.instance_eval{@queue}.to_s)).zero? do
      workers = []
      size.times { workers << Thread.new { worker.process } }
      workers.each { |t| t.join }

      assert_equal (count - size + 1), $counter
      assert_equal (size - 1 ), Resque.size(TestJob.instance_eval{@queue}.to_s)
    end

    assert_equal count, $counter

  end
end
