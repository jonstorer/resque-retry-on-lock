Gem::Specification.new do |s|
  s.name              = "resque-retry-on-lock"
  s.version           = "0.0.2"
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "A Resque plugin for ensuring only one instance of your job is running at a time, re-enqueuing duplicates."
  s.homepage          = "https://github.com/jonstorer/resque-retry-on-lock"
  s.email             = "me@jonathonstorer.com"
  s.authors           = [ "Jonathon Storer", "Mark Kassal" ]
  s.has_rdoc          = false

  s.files             = %w( README.md Rakefile LICENSE )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("test/**/*")

  s.description       = <<desc
A Resque plugin. If you want only one instance of your job
running at a time, but want to re-enqueue rejected jobs, 
extend it with this module.

For example:

    class UpdateNetworkGraph
      extend Resque::Jobs::RetryOnLocked

      def self.perform(repo_id)
        heavy_lifting
      end
    end
desc
end
