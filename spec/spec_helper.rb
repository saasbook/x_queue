require 'fake_web'
Dir[File.join(File.dirname(__FILE__), '..', 'lib', '*.rb')].each { |f|  load f }
def fixture_response(method, file)  # TODO: stop hardcoding these use cases! only should be differentiating between files and actual page responses.
  puts "FILE REQUESTED: file.zip"
  if file.include? '.json'
    FakeWeb.register_uri(method.to_sym, %r|^https://.*xqueue.edx.org/|,
               :body => File.open("spec/fixtures/#{file}").read)
  elsif file.include? 'file.txt'
    FakeWeb.register_uri(method.to_sym, %r|^http://fakedownload.com/|,
              :body => File.open("spec/fixtures/#{file}").read)
  elsif file.include? 'example.zip'
    FakeWeb.register_uri(method.to_sym, %r|^http://fakedownload.com/|,
                         :body => File.open("spec/fixtures/#{file}", 'rb').read)  # should this be read byte mode or regular? not sure depends on how mechanize handles it normally.
  else
    FakeWeb.register_uri(method.to_sym, %r|^https://.*xqueue.edx.org/|,
              :response => "spec/fixtures/#{file}")
  end
end
