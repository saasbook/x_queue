require 'spec_helper'


describe XQueueSubmission do
  context 'is created from a valid JSON string' do
    before :example do 
      @double = instance_double('XQueue')
    end
    it 'should have no errors' do
      xqueue = XQueueSubmission.parse_JSON(@double, IO.read('spec/fixtures/valid_submission_with_file.json'))
      expect xqueue.empty? to be true 
    end
    # its(:errors) { should be_empty }
    # its(:secret) { should == 'some_secret_001' }
    # its(:submission_time) { should == '2013-09-30 00:00:00 GMT' }
    # its(:student_id)  { should == 'abc123' }
    # its(:score) { should be_zero }
    # its(:message) { should be_empty }
  end
end
