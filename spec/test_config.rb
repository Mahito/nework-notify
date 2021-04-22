require 'minitest'
require 'minitest/autorun'
require './lib/config'

class TestConfig < MiniTest::Test
  def setup
    @config = NeWorkNotify::Config.new
  end
end
