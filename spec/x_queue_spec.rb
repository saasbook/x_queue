# The response files for FakeWeb were generated as follows.
# Setting XXX and YYY to either valid or invalid django_auth credentials,
#   and setting USER:PASS to the valid or invalid BasicAuth username/password:
# For testing authentication:
# curl --include --silent --user 'USER:PASS' --cookie-jar /tmp/cookies.txt  \
#      --data-urlencode 'username=XXX' --data-urlencode 'password=YYY' \
#      https://stage-xqueue.edx.org/xqueue/login/
# For testing queue length: establish a valid session as above, then
# curl --include --silent  --cookie /tmp/cookies.txt  \
#      --data-urlencode 'queue_name=QNAME'  \
#      https://stage-xqueue.edx.org/xqueue/get_queuelen

require 'spec_helper'
require 'fakeweb'
require 'json'

describe XQueue do

  before(:each) { FakeWeb.allow_net_connect = false }
  after(:each) { FakeWeb.clean_registry }
  
  def fixture_response(method, file)
    if file.include? '.json'
      FakeWeb.register_uri(method.to_sym, %r|^https://.*xqueue.edx.org/|,
                 :body => File.open("spec/fixtures/#{file}").read)
    else
      FakeWeb.register_uri(method.to_sym, %r|^https://.*xqueue.edx.org/|,
                :response => "spec/fixtures/#{file}")
    end
  end
  
  describe 'base URI' do
    after(:all) { XQueue.base_uri = XQueue::XQUEUE_DEFAULT_BASE_URI }
    it 'has a default' do
      XQueue.base_uri.to_s.should_not be_empty
    end
    it 'can be changed to a valid URI' do
      expect { XQueue.base_uri = 'http://my.com/URI' }.not_to raise_error
      XQueue.base_uri.should == URI('http://my.com/URI')
    end
    it 'cannot be changed to an invalid URI' do
      expect { XQueue.base_uri = '12%' }.to raise_error(URI::InvalidURIError)
    end
  end

  describe 'new' do
    subject { XQueue.new('django_user', 'django_pass', 'user', 'pass', 'my_q') }
    its(:queue_name) { should == 'my_q' }
    its(:base_uri)   { should == URI('https://xqueue.edx.org') }
    its(:error)      { should be_nil }
    it { should_not be_authenticated }
  end

  describe 'authenticating' do
    it 'with invalid credentials should raise XQueue::AuthenticationError' do
      fixture_response(:post, 'x_queue_bad_credentials.txt')
      expect { XQueue.new('bad', 'bad', 'bad', 'bad', 'q1').authenticate }.
        to raise_error(XQueue::AuthenticationError,
        'Authentication failure: Incorrect login credentials')
    end
    it 'with valid credentials should not raise error' do
      fixture_response(:post, 'x_queue_successful_auth.txt')
      queue = XQueue.new('good','good','good','good','q1')
      expect { queue.authenticate }.not_to raise_error
      queue.should be_authenticated
    end
  end

  describe 'valid session' do
    before :each do
      @q = XQueue.new('good','good','good','good','my_queue')
      @q.stub(:authenticated?).and_return(true)
    end
    it 'should return list of queue names' do
      fixture_response(:get, 'x_queue_no_such_queue.txt')
      @q.list_queues.should == %w(test-pull test-2)
    end
    describe 'get queue length' do
      it 'for existing queue should return an integer' do
        fixture_response(:get, 'x_queue_queuelength.txt')
        @q.queue_length.should == 101
      end
      it 'for nonexistent queue should raise NoSuchQueueError' do
        fixture_response(:get, 'x_queue_no_such_queue.txt')
        expect { @q.queue_length }.to raise_error(XQueue::NoSuchQueueError)
      end
    end
    describe 'retrieving submission' do
      context 'for queue that has submissions' do
        it 'should create a new XQueueSubmission from result' do
          #fixture_response(:get, 'x_queue_queuelength.txt')
          # raw_json = IO.read('spec/fixtures/json_response.txt')
          fixture_response(:get, 'valid_submission_with_file.json')
          # expect { @q.get_submission }.to receive(:new).with(raw_json)
          expect(XQueueSubmission).to receive(:parse_JSON)
          @q.get_submission
        end
      end
      context 'for empty queue'
    end
  end

end

