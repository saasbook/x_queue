require 'spec_helper'


describe XQueueSubmission do
  context 'is created from a valid JSON string' do
    before(:each) do 
      double = double('XQueue')
      @xqueue = XQueueSubmission.parse_JSON(double, IO.read('spec/fixtures/valid_submission_with_file.json'))
    end 
    it 'should have no errors' do
      expect(@xqueue.errors).to be_empty
    end
    it 'should have secret some_secret_001' do
      expect(@xqueue.secret).to be == 'some_secret_001'
    end
    it 'should have submission_time 2013-09-30 00:00:00 GMT' do
      expect(@xqueue.submission_time).to be == Time.parse('2013-09-30 00:00:00 GMT')
    end
    it 'should have secret some_secret_001' do
      expect(@xqueue.secret).to be == 'some_secret_001'
    end
    # its(:errors) { should be_empty }
    # its(:secret) { should == 'some_secret_001' }
    # its(:submission_time) { should == '2013-09-30 00:00:00 GMT' }
    # its(:student_id)  { should == 'abc123' }
    # its(:score) { should be_zero }
    # its(:message) { should be_empty }
  end
end
