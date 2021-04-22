# frozen_string_literal: true
#
require 'faye/websocket'
require 'net/http'
require 'json'
require 'permessage_deflate'
require 'uri'

module NeWorkNotify
  module NeWorkClient
    WS_ENDPOINT = 'wss://s-usc1c-nss-378.firebaseio.com/.ws?v=5&ns=sys3468091-9-45922838-default-rtdb'
    TOKEN_REFRESH_URL = 'https://securetoken.googleapis.com/v1/token?key='

    # @return [String] Auth Query with token
    def self.auth_query
      credential = credential = { 'cred': refresh_token }
      data = { 't' => 'd' }
      data['d'] = { 'r' => 1, 'a' => 'auth', 'b' => credential }
      JSON.dump(data)
    end

    def self.create(config)
      @config = config
      Faye::WebSocket::Client.new(WS_ENDPOINT, [],
                                  headers: {'Origin' => 'https://nework.app'},
                                  extensions: [PermessageDeflate],
                                  ping: 30)
    end

    def self.refresh_token
      uri = URI.parse(TOKEN_REFRESH_URL + @config.nework_api_token)
      body = {
        grant_type: 'refresh_token',
        refresh_token: @config.nework_refresh_token
      }

      response = Net::HTTP.post_form(uri, body)
      data = JSON.parse(response.body)

      data['id_token']
    end
  end
end
