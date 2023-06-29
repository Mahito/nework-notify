# frozen_string_literal: true

require './lib/room'
require './lib/slack_client'

module NeWorkNotify
  class Workspace
    attr_reader :name
    attr_accessor :rooms

    ENDPOINT = 'https://nework.app/workspace/'

    def initialize(config)
      @name = config.workspace_name
      @rooms = {}
      @slack_client = SlackClient.new(config.slack_api_token, config.slack_channel)
    end

    def room_update(body)
      case body['p']
      when %r{^workspaces/.+/rooms$}
        return if body['d'].nil?

        @rooms = {}
        body['d'].each do |k, v|
          @rooms[k] = Room.new(k, v, @name)
        end
      when %r{^workspaces/.+/rooms/(.+)/userIds/%w+$}
        @rooms[$1].speakers += 1 unless body['d'].nil?
      when %r{^workspaces/.+/rooms/(.+)/audienceIds/%w+$}
        @rooms[$1].audiences += 1 unless body['d'].nil?
      when %r{^workspaces/.+/rooms/([-0-9a-f]+)$}
        @rooms[$1].update(body['d'])
      end
    end

    def post_slack
      msg = "NeWork (<#{ENDPOINT}#{@name}|#{@name}>) の"
      if (m = message) == ''
        msg += "Roomには誰もいないよ〜"
        @slack_client.post_nobody(msg)
      else
        msg += "現在の状況\n#{m}"
        @slack_client.post(msg)
      end
    end

    def message
      message = ''
      @rooms.each do |_, room|
        m = room.to_s
        message += "#{m}\n" if m != ''
      end
      message
    end
  end
end

