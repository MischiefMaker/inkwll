ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

# A real visitor's request starts with nothing remembered. In tests the test
# itself shares memory with the requests it makes, so forget what the game
# remembered (like the settings) after each request.
module ForgetBetweenRequests
  def process(*, **)
    super.tap { Current.reset }
  end
end
ActionDispatch::Integration::Session.prepend ForgetBetweenRequests
