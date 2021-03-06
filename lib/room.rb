require 'json'

module NeWorkNotify
  class Room
    attr_reader :id, :workspace
    attr_writer :name, :speakers, :audiences

    WORKSPACE_URL = 'https://nework.app/workspace/'

    def initialize(id, data, workspace)
      @id = id
      @workspace = workspace
      @name = data['name']
      @speakers = count_ids(data['userIds'])
      @audiences = count_ids(data['audienceIds'])
    end

    def count_ids(data)
      data.instance_of?(String) ? 0 : data.size
    end

    def to_s
      message = ''
      unless @speakers.zero? && @audiences.zero?
        message = "#{@name} (<#{WORKSPACE_URL}#{@workspace}\##{@id}|Join>): "
        message += "#{@speakers} 人"
        message += "（+ #{@audiences} 人）" unless @audiences.zero?
      end
      message
    end
  end
end
