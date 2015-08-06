require 'spec_helper'
describe XQueueSubmission do
  before(:each) { FakeWeb.allow_net_connect = false }
  after(:each) { FakeWeb.clean_registry }

  def mock_grade(submission)
    submission.correct = true
    submission.score = 1.3
    submission.message = 'good job student!'
    submission
  end

  context 'is created from a valid JSON string' do
    before(:each) do
      double = double('XQueue')
      @submission = XQueueSubmission.create_from_JSON(double, JSON.parse(IO.read('spec/fixtures/valid_submission_with_file.json'))['content'])
    end
    it 'should have secret some_secret_001' do
      expect(@submission.secret).to be == 'some_secret_001'
    end
    it 'should have submission_time 2013-09-30 00:00:00 GMT' do
      expect(@submission.submission_time).to be == Time.parse('2013-09-30 00:00:00 GMT')
    end
    it 'should have secret some_secret_001' do
      expect(@submission.secret).to be == 'some_secret_001'
    end
    it 'should have score of 0' do
      expect(@submission.score).to be_zero
    end
    it 'should have student_id abc123' do
      expect(@submission.student_id).to be == 'abc123'
    end
    it 'should have file name and uri' do 
      expect(@submission.files.first).to be == ['file.txt', 'http://fakedownload.com/file.txt']
    end
  end

  context 'will retrieve files if the corresponding x_queue has retrieve file option set' do
    before(:each) do 
      @q = XQueue.new('good','good','good','good','my_queue', true)
      @q.stub(:authenticated?).and_return(true)
      fixture_response(:get, 'valid_submission_with_file.json')
      fixture_response(:get, 'file.txt')
      @q.stub(:queue_length).and_return(1)
    end
    it 'downloads files' do 
      expect(@q.get_submission.files.first).to be == ['file.txt', 'this is a file']
    end
  end

  context 'can be submitted to a XQueue once graded' do 
    before(:each) do
      @xq = double('XQueue')
      @xq.stub(:put_result)
      @submission = XQueueSubmission.create_from_JSON(@xq, JSON.parse(IO.read('spec/fixtures/valid_submission_with_file.json'))['content'])
      @submission = mock_grade(@submission)
    end

    it 'should submit to its XQueue valid fields' do 
      expect(@xq).to receive(:put_result).with('some_secret_001', 1.3, true, 'good job student!')
      @submission.post_back
    end
  end

  context 'can download files to local locations' do
    FakeFS.activate!

    before(:each) do
      @q = XQueue.new('good','good','good','good','my_queue', true)
      @q.stub(:authenticated?).and_return(true)
      fixture_response(:get, 'valid_submission_with_zip.json')
      fixture_response(:get, 'example.zip')
      @q.stub(:queue_length).and_return(1)
    end

    it 'will unzip files and place them in the correct directory ' do
      FakeWeb.allow_net_connect = false
      submission = @q.get_submission
      submission.write_to_location! File.join('submissions', 'abc123')
      expect(File.readable? 'submissions/abc123/spec/').to be_truthy
      expect(submission.files.values.first).to be == 'submissions/abc123'
    end
    it 'will put regular files in the correct directory ' do

    end
    FakeFS.deactivate!
  end

  context 'has convenience grading methods for autograders' do
    before(:each) do
      @q = XQueue.new('good','good','good','good','my_queue', true)
      @q.stub(:authenticated?).and_return(true)
      fixture_response(:get, 'valid_submission_with_zip.json')
      fixture_response(:get, 'example.zip')
      @q.stub(:queue_length).and_return(1)
      @submission = @q.get_submission
    end

    it 'will escape html' do
      @submission.grade!('<yolo>', 0, 100)
      expect(@submission.message).to be == '<pre>&lt;yolo&gt;</pre>'
    end

    it 'will mark submissions correct if they get full points' do
      @submission.grade!('<yolo>', 100, 100)
      expect(@submission.correct).to be true
    end

    it 'will not mark submissions correct if they don\'t get full points' do
      @submission.grade!('<yolo>', 80, 100)
      expect(@submission.correct).to be false
    end
  end

end
