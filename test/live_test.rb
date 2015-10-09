require "minitest/autorun"
require "hurley"
require "hurley/test"
require "hurley/test/integration"
require File.expand_path("../../lib/hurley-typhoeus", __FILE__)

module HurleyTyphoeus
  class Test < MiniTest::Test
    Hurley::Test::Integration.apply(self)

    def connection
      @connection ||= HurleyTyphoeus::Connection.new
    end
  end
end
