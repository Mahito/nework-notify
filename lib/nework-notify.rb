# frozen_string_literal: true

require 'slack-ruby-client'
require 'net/http'
require 'json'
require 'uri'
require 'time'

ENDPOINT          = 'https://nework.app/workspaces/'
API_ENDPOINT      = 'https://api.nework.app/v1/workspaces/'
TOKEN_REFRESH_URL = 'https://securetoken.googleapis.com/v1/token?key='

NEWORK_WORKSPACE  = ENV['NEWORK_WORKSPACE']
TOKEN_API_KEY     = ENV['TOKEN_API_KEY']
REFRESH_TOKEN     = ENV['REFRESH_TOKEN']
SLACK_CHANNEL     = ENV['SLACK_CHANNEL']
UPDATE_MINUTES    = ENV['UPDATE_MINUTES'] || 60
WORKSPACE_URL     = ENDPOINT + NEWORK_WORKSPACE

def refresh_token
  uri = URI.parse(TOKEN_REFRESH_URL + TOKEN_API_KEY)
  body = {
    grant_type: 'refresh_token',
    refresh_token: REFRESH_TOKEN
  }

  response = Net::HTTP.post_form(uri, body)
  data = JSON.parse(response.body)

  data['id_token']
end

Slack::Web::Client.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
  raise 'Missing ENV[SLACK_API_TOKEN]!' unless config.token

  $stdout.sync = true

  config.logger = Logger.new($stdout)
  config.logger.level = Logger::INFO
end

slack = Slack::Web::Client.new
ts    = 0
uri   = URI.parse("#{API_ENDPOINT}#{NEWORK_WORKSPACE}/rooms")

begin
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  token = refresh_token
  headers = { 'authorization' => "Bearer #{token}" }

  loop do
    response = http.get(uri.path, headers)

    raise Net::HTTPError.new('Tokenの認証切れ', 401) if response.code == '401'

    rooms = JSON.parse(response.body)

    message = ''
    rooms.each do |room|
      next if room['members'].empty?

      message += "#{room['name']} (<#{WORKSPACE_URL}?room=#{room['roomId']}#|Join>): "
      message += "#{room['members'].size} 人"
      message += "（+ #{room['listeners'].size} 人）" unless room['listeners'].empty?
      message += "\n"
    end

    msg = "NeWork (<#{WORKSPACE_URL}|#{NEWORK_WORKSPACE}>) の"
    msg += message == '' ? 'Roomには誰もいないよ〜' : "現在の状況\n#{message}"

    durartion = (Time.now - ts.to_i).to_i
    if ts.to_i.zero? && message == ''
      # Pass
    elsif durartion > UPDATE_MINUTES * 60 && message != ''
      slack.chat_delete(channel: SLACK_CHANNEL, ts: ts) unless ts.to_i.zero?
      result = slack.chat_postMessage(channel: SLACK_CHANNEL, text: msg)
      ts = result['ts']
    else
      slack.chat_update(channel: SLACK_CHANNEL, text: msg, ts: ts)
    end

    sleep 60
  end
rescue Net::HTTPError => e
  p e
  retry
rescue Slack::Web::Api::Errors::SlackError => e
  p e
  puts e.backtrace
  sleep 300
  retry
rescue => e
  p e
  puts e.backtrace
end
