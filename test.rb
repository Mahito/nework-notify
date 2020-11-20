require 'net/http'

begin
  count = 0

  loop do
    #raise Net::HTTPError.new("Tokenの認証切れ", 404) if count == 5

    case count
    when 1..9
      puts count
    else
      puts '0のはず'
    end

    count = (count + 1) % 10
    sleep 1
  end
rescue Net::HTTPError => e
  puts 'れすきゅー'
  retry
end
