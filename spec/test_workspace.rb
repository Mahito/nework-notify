require 'minitest'
require 'minitest/autorun'
require './lib/workspace'

class TestWorkspace < MiniTest::Test
  def setup
    slack = { 'token' => 'test', 'channel' => 'test'}
    @workspace = NeWorkNotify::Workspace.new('test', slack)
  end

  def test_rooms
  end

  def test_message_shows_absent
    expect = 'NeWork (<https://nework.app/workspace/test|test>) のRoomには誰もいないよ〜'
    assert_equal expect, @workspace.message
  end

  def test_message_show_rooms
    data = {'name' => 'test', 'userIds' => {a: 1, b: 2}, 'audienceIds' => {a: 1}}
    @workspace.rooms = { 'workspace_id' => NeWorkNotify::Room.new('workspace_id', data, @workspace.name) }
    expect = "NeWork (<https://nework.app/workspace/test|test>) の現在の状況\n"
    expect += "test (<https://nework.app/workspace/test#workspace_id#|Join>): 2 人（+ 1 人）\n"
    assert_equal expect, @workspace.message
  end
end
