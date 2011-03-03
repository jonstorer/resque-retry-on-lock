Resque Lock
===========

A [Resque][rq] plugin. Requires Resque 1.7.0.

This plugin is a modification of defunkt's resque-lock plugin
located at https://github.com/defunkt/resque-lock

All credit goes to defunkt.

If you want only one instance of your job running at a time, but 
to also re-enqueue rejected jobs, extend it with this module.


For example:

    require 'resque/plugins/retry_on_lock'

    class UpdateNetworkGraph
      extend Resque::Plugins::RetryOnLock

      def self.perform(repo_id)
        heavy_lifting
      end
    end

While other UpdateNetworkGraph jobs will be placed on the queue,
the Locked class will check Redis to see if any others are
executing with the same arguments before beginning. If another
is executing the job will be re-enqueued.

If you want to define the key yourself you can override the
`lock` class method in your subclass, e.g.

    class UpdateNetworkGraph
      extend Resque::Plugins::RetryOnLock

      Run only one at a time, regardless of repo_id.
      def self.lock(repo_id)
        "network-graph"
      end

      def self.perform(repo_id)
        heavy_lifting
      end
    end

The above modification will ensure only one job of class
UpdateNetworkGraph is running at a time, regardless of the
repo_id. Normally a job is locked using a combination of its
class name and arguments.

[rq]: http://github.com/jonstorer/resque-retry-on-lock
