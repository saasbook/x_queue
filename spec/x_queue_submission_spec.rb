require 'spec_helper'

describe XQueueSubmission do
  describe 'new' do
    subject { XQueueSubmission.new(JSON(IO.read('spec/fixtures/valid_submission_with_file.json'))) }
    its(:errors) { should be_empty }
    its(:secret) { should == 'some_secret_001' }
    its(:submission_time) { should == '2013-09-30 00:00:00 GMT' }
    its(:student_id)  { should == 'abc123' }
    its(:score) { should be_zero }
    its(:message) { should be_empty }
  end
end
