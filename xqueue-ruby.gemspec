Gem::Specification.new do |s|
  s.name        = 'xqueue-ruby'
  s.version     = '0.0.1'
  s.date        = '2014-01-03'
  s.summary     = "Pull interface to Open edX XQueue"
  s.description = "Pull interface to Open edX XQueue"
  s.authors     = ["Armando Fox"]
  s.email       = 'fox@cs.berkeley.edu'
  s.files       = %w(lib/x_queue.rb  
                      lib/x_queue/x_queue.rb  lib/x_queue/x_queue_submission.rb) #fix this
  s.executables = []
  # dependencies
  s.add_runtime_dependency 'builder'
  s.add_runtime_dependency 'getopt'
  s.homepage    = 'http://github.com/saasbook/x_queue'
  s.license       = 'BSD'
end
