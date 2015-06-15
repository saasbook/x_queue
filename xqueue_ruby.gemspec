Gem::Specification.new do |s|
  s.name        = 'xqueue_ruby'
  s.version     = '0.0.1'
  s.date        = '2015-06-15'
  s.summary     = "Pull interface to Open edX XQueue"
  s.description = "Pull interface to Open edX XQueue"
  s.authors     = ["Armando Fox", "Aaron Zhang"]
  s.email       = 'fox@cs.berkeley.edu'
  s.files       = %w(lib/xqueue_ruby.rb lib/xqueue_ruby/xqueue_ruby.rb 
                    lib/xqueue_ruby/xqueue_submission.rb)
  s.executables = []
  # dependencies
  s.add_runtime_dependency 'builder'
  s.add_runtime_dependency 'getopt'
  s.homepage    = 'http://github.com/saasbook/x_queue'
  s.license       = 'BSD'
end
