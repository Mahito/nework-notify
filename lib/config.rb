module NeWorkNotify
  class Config
    attr_reader :workspace_name, :nework_api_token, :nework_refresh_token,
                :slack_api_token, :slack_channel

    def initialize
      @workspace_name       = ENV['NEWORK_WORKSPACE']
      @nework_api_token     = ENV['TOKEN_API_KEY']
      @nework_refresh_token = ENV['REFRESH_TOKEN']
      @slack_api_token      = ENV['SLACK_API_TOKEN']
      @slack_channel        = ENV['SLACK_CHANNEL']
    end
  end
end
