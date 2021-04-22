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
      @slack_client.post(message)
    end

    def message
      message = ''
      @rooms.each do |_, room|
        m = room.to_s
        message += "#{m}\n" if m != ''
      end

      msg = "NeWork (<#{ENDPOINT}#{@name}|#{@name}>) の"
      msg += message == '' ? 'Roomには誰もいないよ〜' : "現在の状況\n#{message}"
      msg
    end
  end
end

