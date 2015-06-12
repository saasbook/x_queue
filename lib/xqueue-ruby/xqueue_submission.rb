require 'active_model'
require 'json'
require 'debugger'

class XQueueSubmission
  include ActiveModel::Validations

  class InvalidSubmissionError < StandardError ;  end

  attr_reader :queue
  # The +XQueue+ from which this assignment was retrieved (and to which the grade should be posted back)
  attr_reader :secret
  # XQueue-server-supplied nonce that will be needed to post back a grade for this submission
  attr_accessor :files
  attr_reader :submission_time
  # When student submitted assignment via edX (a Time object)
  attr_reader :student_id
  # one-way hash of edX student ID
  attr_accessor :score
  # Numeric: score reported by autograder
  attr_accessor :message
  # String: textual feedback from autograder
  attr_accessor :correct
  # Boolean: if true when posted back, shows green checkmark, otherwise red X

  validates_presence_of :student_id
  validates_presence_of :submission_time
  validates_presence_of :secret
  
  def initialize(hash)
    begin
      @correct = true
      @score = 0
      @message = ''
      @errors = ''
      @secret = hash['xqueue_header']
      @submission_time = hash['xqueue_body']['student_info']['submission_time']
      @student_id = hash['xqueue_body']['student_info']['anonymous_student_id']
    rescue NoMethodError => e
      if e.message == "undefined method `[]' for nil:NilClass"
        raise InvalidSubmissionError, "Missing element(s) in JSON: #{hash}"
      end
      raise
    end
  end

  def post_back()
    @queue.put_result(@secret, @score, @message)
  end

  def self.parse_JSON(XQueue, JSON_response)
    parsed = JSON.parse(JSON_response)
    header, files, body = parsed['xqueue_header'], parsed['xqueue_files'], parsed['xqueue_body']
    grader_payload = body['grader_payload']
    anonymous_student_id, submission_time = body['student_info']['anonymous_student_id'], Time.new(body['student_info']['submission_time'])
    XQueueSubmission.new :queue XQueue, header: header, files: files, student_id: anonymous_student_id, submission_time: submission_time

end
