load './lib/xqueue_ruby.rb'
load './lib/xqueue_ruby/xqueue_ruby.rb'
load './lib/xqueue_ruby/xqueue_submission.rb'

a = XQueue.new('berkeley_001', 'E|^3LL}fN6cFGGrxKdHm', 'anant', 'agarwal',  'test-pull')
b = a.get_submission
b.message = 'yoloswag'
b.correct = true
b.score = 100.0
b.post_back