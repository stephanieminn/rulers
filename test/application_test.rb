require "erubis"
require_relative "test_helper"

class TestApp < Rulers::Application; end

class RulersAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    TestApp.new
  end

  def test_request
    get "/test/index"
    assert last_response.ok?
    body = last_response.body
    assert body["Hello!"]
  end

  def test_request_with_variables
    get "/test/index"
    assert last_response.ok?
    body = last_response.body
    assert body["Controller Name: TestController"]
  end
end
