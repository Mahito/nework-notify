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
      when %r{^workspaces/.+/rooms/(.+)/userIds$}
        @rooms[$1].speakers = body['d'].size
      when %r{^workspaces/.+/rooms/(.+)/audienceIds$}
        @rooms[$1].audiences = body['d'].size
      when %r{^workspaces/.+/rooms/.+/(user|audience)Ids/.+$}
        # skip
      when %r{^workspaces/.+/rooms/(.+)$}
        if body['d']['name'] == ''
          @rooms.delete($1)
        else
          @rooms[$1].name = body['d']['name']
        end
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

