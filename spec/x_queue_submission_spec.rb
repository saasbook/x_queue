require 'spec_helper'


describe XQueueSubmission do

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
    it 'should have no errors' do
      expect(@submission.errors).to be_empty
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
end
