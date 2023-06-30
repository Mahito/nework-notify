# frozen_string_literal: true

require 'json'

module NeWorkNotify
  class Room
    attr_reader :id, :workspace
    attr_writer :name
    attr_accessor :speakers, :audiences

    WORKSPACE_URL = 'https://nework.app/workspace/'

    def initialize(id, data, workspace)
      @id = id
      @workspace = workspace
      @name = data['name']
      @speakers = count_ids(data['userIds'])
      @audiences = count_ids(data['audienceIds'])
    end

    # speakers と audiences を更新する関数
    def update(data)
      @speakers = count_ids(data['userIds'])
      @audiences = count_ids(data['audienceIds'])
    end

    # null なら 0, それ以外は数字を返す
    def count_ids(data)
      case data
      when nil
        0
      when Hash || Array
        data.size
      when String || Integer
        data.to_i
      end
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
