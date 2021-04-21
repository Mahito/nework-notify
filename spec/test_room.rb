require 'minitest/unit'
require 'minitest/autorun'
require './lib/room'

class TestRoom < MiniTest::Unit::TestCase
  def setup
    @id = '00-0c3671ba-86a4-44a7-8ed5-202275acaef4'
    @ws =  'test_workspace'
    data = { 'audienceIds' => '', 'name' => 'ランチ', 'seqNo' => 0, 'userIds' => '' }
    @room = NeWorkNotify::Room.new(@id, data, @ws)
  end

  def test_show_empty
    assert_equal '', @room.to_s
  end

  def test_show_room_name_with_speaker
    @room.speakers = 1
    assert_equal "ランチ (<https://nework.app/workspace/#{@ws}##{@id}#|Join>): 1 人", @room.to_s
  end

  def test_show_room_name_with_audience
    @room.audiences = 1
    assert_equal "ランチ (<https://nework.app/workspace/#{@ws}##{@id}#|Join>): 0 人（+ 1 人）", @room.to_s
  end

  def test_show_room_name_with_audience
    @room.speakers = 1
    @room.audiences = 1
    assert_equal "ランチ (<https://nework.app/workspace/#{@ws}##{@id}#|Join>): 1 人（+ 1 人）", @room.to_s
  end
end
