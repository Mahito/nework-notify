# frozen_string_literal: true

require 'eventmachine'
require 'json'
require 'yaml'

require './lib/config'
require './lib/nework_client'
require './lib/workspace'

module NeWorkNotify
  def self.config
    @config = Config.new
    @workspace = Workspace.new(@config)
  end


  def self.start_auth
    @ws.send(NeWorkClient.auth_query)
    @ws.send(JSON.dump({"t":"d","d":{"r":2,"a":"q","b":{"p":"/workspaces/#{@workspace.name}/rooms","h":""}}}))
  end

  def self.run
    EM.run do
      @ws = NeWorkClient.create(@config)

      @ws.on :open do |event|
        p [:open, @ws.headers]
      end

      @ws.on :message do |event|
        p [:message, event.data]
        begin
          data = JSON.parse(event.data)
          case data['t']
          when 'c'
            start_auth
          when 'd'
            body = data['d']['b']

            if body['s'] == 'expired_token'
              start_auth
              next
            end

            if body['p']
              if body['p'] =~ %r{^workspaces/(.+)/rooms.*$}
                @workspace.room_update(body)
                @workspace.post_slack
              end
            end
          end
        rescue => e
          p e
          puts e.backtrace
        end
      end

      @ws.on :close do |event|
        p [:close, event.code, event.reason]
        @ws = nil
        exit
      end
    end
  end
end

NeWorkNotify.config
NeWorkNotify.run

