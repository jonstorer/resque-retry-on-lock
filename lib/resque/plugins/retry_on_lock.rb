module Resque
  module Plugins
    # If you want only one instance of your job running at a time, 
    # but you want [term] jobs to run later, extend it with
    # this module.
    #
    # For example:
    #
    # require 'resque/plugins/retry_on_lock'
    #
    # class UpdateNetworkGraph
    #   extend Resque::Plugins::RetryOnLock
    #
    #   def self.perform(repo_id)
    #     heavy_lifting
    #   end
    # end
    #
    # While other UpdateNetworkGraph jobs will be placed on the queue,
    # the Lock class will check Redis to see if any others are
    # executing with the same arguments before beginning. If another
    # worker isexecuting the job will be re-enqueued.
    #
    # If you want to define the key yourself you can override the
    # `lock` class method in your subclass, e.g.
    #
    # class UpdateNetworkGraph
    #   extend Resque::Plugins::RetryOnLock
    #
    #   # Run only one at a time, regardless of repo_id.
    #   def self.lock(repo_id)
    #     "network-graph"
    #   end
    #
    #   def self.perform(repo_id)
    #     heavy_lifting
    #   end
    # end
    #
    # The above modification will ensure only one job of class
    # UpdateNetworkGraph is running at a time, regardless of the
    # repo_id. Normally a job is locked using a combination of its
    # class name and arguments.
    module RetryOnLock
      # Override in your job to control the lock key. It is
      # passed the same arguments as `perform`, that is, your job's
      # payload.
      def lock(*args)
        "lock:#{name}-#{args.to_s}"
      end

      # Where the magic happens.
      def around_perform_lock_and_requeue(*args)
        # Re-Enqueue if another job has created a lock.
        if Resque.redis.setnx(lock(*args), true)
          begin
            yield
          ensure
            # Always clear the lock when we're done, even if there is an
            # error.
            Resque.redis.del(lock(*args))
          end
        else
          Resque.enqueue(self, *args)
        end
      end

    end
  end
end
