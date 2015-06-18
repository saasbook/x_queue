require 'mechanize'
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
  attr_reader :grader_payload

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
  attr_reader :files


  validates_presence_of :student_id
  validates_presence_of :submission_time
  validates_presence_of :secret
  
  DEFAULTS = {correct: false, score: 0, message: '', errors: ''}
  def initialize(hash)
    begin
      fields_hash = DEFAULTS.merge(hash)
      fields_hash.each {|key, value| instance_variable_set("@#{key}", value)}
    rescue NoMethodError => e
      if e.message == "undefined method `[]' for nil:NilClass"
        raise InvalidSubmissionError, "Missing element(s) in JSON: #{hash}"
      end
      raise StandardError 'yoloswag'
    end
  end

  def post_back()
    @queue.put_result(@secret, @score, @correct, @message)
  end

  def self.parse_JSON(xqueue, json_response)
    header, files, body = json_response['xqueue_header'], json_response['xqueue_files'], json_response['xqueue_body']
    grader_payload = body['grader_payload']
    anonymous_student_id, submission_time = body['student_info']['anonymous_student_id'], Time.parse(body['student_info']['submission_time'])
    XQueueSubmission.new({queue: xqueue, secret: header, files: files, student_id: anonymous_student_id, submission_time: submission_time, grader_payload: grader_payload})
  end


  def fetch_files
    if files
      file_agent = Mechanize.new
      @files = @files.values.map {|file_uri| file_agent.get_file(file_uri)}
    end
    self
  end

end