require 'mechanize'
require 'active_model'
require 'json'
require 'zip'
require 'tempfile'

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
      raise e
    end
  end

  def post_back
    @queue.put_result(@secret, @score, @correct, @message)
  end

  #call on XQueueSubmission to fetch the files if remote format and return XQueueSubmission
  def fetch_files!
    if files
      file_agent = Mechanize.new
      @files = @files.inject({}) {|new_hash, (k,v)| new_hash[k] = file_agent.get_file(v); new_hash}
    end
    self
  end

  #Unzips student submission and modifies file hash so that value is now a string URI pointing to root file path of the submission
  #If student submits a zip_file, then we assume that it is the first and only file uploaded. writes the zip archive into a root root_file_path specified by caller
  #Source for zipping code: 
  # http://stackoverflow.com/questions/19754883/how-to-unzip-a-zip-file-containing-folders-and-files-in-rails-while-keeping-the
  def unzip! (root_file_path)
    tmp_zip = Tempfile.open('zip_file') {|tmp| tmp.write(files.values.first); tmp}  # block should yield tmp at end
    Zip::File.open(tmp_zip) do |zip_file|
      zip_file.each do |f|
        f_path=File.join("#{root_file_path}-#{student_id}", f.name)
        FileUtils.mkdir_p(File.dirname(f_path))
        zip_file.extract(f, f_path) unless File.exist?(f_path)
      end
    end
    files[files.keys.first] = "#{root_file_path}-#{student_id}"
  end


  def self.create_from_JSON(xqueue, json_response)
    json_response = recursive_JSON_parse(json_response)
    header, files, body = json_response['xqueue_header'], json_response['xqueue_files'], json_response['xqueue_body']
    grader_payload = body['grader_payload']
    anonymous_student_id, submission_time = body['student_info']['anonymous_student_id'], Time.parse(body['student_info']['submission_time'])
    XQueueSubmission.new({queue: xqueue, secret: header, files: files, student_id: anonymous_student_id, submission_time: submission_time, grader_payload: grader_payload})
  end

  # The JSON we recieve from the server is nested JSON hashes. Rather than calling JSON.parse at each level to get the JSON we choose to expand it into a multi-level hash immediately for easy
  #access
  def self.recursive_JSON_parse(obj, i=0)
    valid_json_hash = try_parse_JSON(obj)
    if i > 100
      raise "Depth level exceeded in recursive_JSON_parse, depth level : #{i}"
    end
    if valid_json_hash
      valid_json_hash.update(valid_json_hash) do |key, value| 
        value = recursive_JSON_parse(value, i + 1)
      end
      return valid_json_hash
    else
      return obj
    end
  end

  #returns nil if the object is not JSON
  def self.try_parse_JSON(obj)
    begin
      JSON.parse(obj)
    rescue Exception => e
       nil
    end
  end
end
