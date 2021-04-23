require 'minitest'
require 'minitest/autorun'
require './lib/config'
require './lib/workspace'

class TestWorkspace < MiniTest::Test
  def setup
    @config = NeWorkNotify::Config.new
    @workspace = NeWorkNotify::Workspace.new(@config)
  end

  def test_rooms
  end

  def test_message_shows_absent
    expect = ''
    assert_equal expect, @workspace.message
  end

  def test_message_show_rooms
    data = {'name' => 'test', 'userIds' => {a: 1, b: 2}, 'audienceIds' => {a: 1}}
    @workspace.rooms = { 'test_room_id' => NeWorkNotify::Room.new('test_room_id', data, @workspace.name) }
    expect = "test (<https://nework.app/workspace/#{@config.workspace_name}#test_room_id#|Join>): 2 人（+ 1 人）\n"
    assert_equal expect, @workspace.message
  end
end
