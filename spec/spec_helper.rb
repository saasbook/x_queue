require 'ruby-debug'
Dir[File.join(File.dirname(__FILE__), '..', 'lib', '*.rb')].each { |f|  load f }
#Dir[File.join(File.dirname(__FILE__), '/support', '**', '*.rb')].each {|f| load f}

def fixture_response(method, file)
  if file.include? '.json'
    FakeWeb.register_uri(method.to_sym, %r|^https://.*xqueue.edx.org/|,
               :body => File.open("spec/fixtures/#{file}").read)
  elsif file.include? 'file.txt'
    FakeWeb.register_uri(method.to_sym, %r|^http://fakedownload.com/|,
              :body => File.open("spec/fixtures/#{file}").read)
  else
    FakeWeb.register_uri(method.to_sym, %r|^https://.*xqueue.edx.org/|,
              :response => "spec/fixtures/#{file}")
  end
end