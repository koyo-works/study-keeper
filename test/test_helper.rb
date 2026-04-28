# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'factory_bot_rails'

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    include FactoryBot::Syntax::Methods
  end
end

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers
    include FactoryBot::Syntax::Methods
  end
end
