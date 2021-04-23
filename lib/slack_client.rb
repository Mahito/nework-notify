require 'slack-ruby-client'
require 'time'

module NeWorkNotify
  class SlackClient
    def initialize(token, channel, update=60)
      @client = create(token)
      @channel = channel
      @ts = 0
      @update = update
    end

    def post(message)
      begin
        if expired?
          @client.chat_delete(channel: @channel, ts: @ts) unless @ts.to_i.zero?
          result = @client.chat_postMessage(channel: @channel, text: message)
          @ts = result['ts']
        else
          @client.chat_update(channel: @channel, text: message, ts: @ts)
        end
      rescue Slack::Web::Api::Errors::SlackError => e
        p e
        puts e.backtrace
        sleep 300
        retry
      end
    end

    def post_nobody(message)
      begin
        @client.chat_update(channel: @channel, text: message, ts: @ts) unless expired?
      rescue Slack::Web::Api::Errors::SlackError => e
        p e
        puts e.backtrace
        sleep 300
        retry
      end
    end

    private
    def create(token)
      Slack::Web::Client.configure do |config|
        config.token = token
        raise 'Missing SLACK_API_TOKEN !' unless config.token

        $stdout.sync = true
        config.logger = Logger.new($stdout)
        config.logger.level = Logger::INFO
      end
      Slack::Web::Client.new
    end

    def expired?
      durartion = (Time.now - @ts.to_i).to_i
      durartion > @update * 60
    end
  end
end
