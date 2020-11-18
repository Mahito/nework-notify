require 'slack-ruby-client'
require "net/http"
require 'json'
require 'uri'

ENDPOINT          = 'https://api.nework.app/v1/workspaces/'
TOKEN_REFRESH_URL = 'https://securetoken.googleapis.com/v1/token?key='

NEWORK_WORKSPACE  = ENV['NEWORK_WORKSPACE']
TOKEN_API_KEY     = ENV['TOKEN_API_KEY']
REFRESH_TOKEN     = ENV['REFRESH_TOKEN']
SLACK_CHANNEL     = ENV['SLACK_CHANNEL']

def refresh_token
  uri = URI.parse(TOKEN_REFRESH_URL + TOKEN_API_KEY)
  body = {
    grant_type: 'refresh_token',
    refresh_token: REFRESH_TOKEN
  }

  response = Net::HTTP.post_form(uri, body)
  data = JSON.parse(response.body)

  return data['id_token']
end

Slack::Web::Client.configure do |config|
  config.token = ENV['SLACK_USER_API_TOKEN']
  raise 'Missing ENV[SLACK_USER_API_TOKEN]!' unless config.token

  STDOUT.sync = true

  config.logger = Logger.new(STDOUT)
  config.logger.level = Logger::INFO
end

slack = Slack::Web::Client.new
token = refresh_token

begin
  count = 0
  ts    = 0

  loop do
    uri = URI.parse(ENDPOINT + NEWORK_WORKSPACE + '/rooms')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    headers = {'authorization' => "Bearer #{token}"}
    response = http.get(uri.path, headers)

    raise Net:HTTPError if response.code == '401'
    rooms = JSON.parse(response.body)

    message = ''
    rooms.each do |room|
      next if room['members'].empty?
      message += "#{room['name']}: #{room['members'].size} 人\n"
    end

    if message == ''
      message = 'NeWorkのRoomには誰もいないよ〜'
    else
      message =  "NeWorkの現在の状況\n" + message
    end

    case count
    when 1..29
      slack.chat_update(channel: SLACK_CHANNEL, text: message, ts: ts)
    else
      result = slack.chat_postMessage(channel: SLACK_CHANNEL, text: message)
      ts = result['ts']
    end

    count = (count + 1) % 30
    puts count
    sleep 60
  end
rescue Net::HTTPError
  token = refresh_token
  retry
end
