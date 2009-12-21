class BotWrapper
  attr_accessor :bot, :options
  
  def start
    self.bot.start
  end
  
  def initialize(options)
    self.options = options
    self.bot = Isaac::Bot.new(options) do
      configure do |c|
        c.nick    = options.bot_nick
        c.server  = options.irc_server
        c.port    = 6667
        c.realname = "A.S.T.R.I.D"
        c.environment = :development
      end

      helpers do
        def welcome
          msg(options.owner_nick, "STRAuto Booted up version: #{Astrid::VERSION}")
          msg(options.owner_nick, "Joined channel: #{options.channels}")
          msg(options.owner_nick, "Loaded filters")
          msg(options.owner_nick, options.series_names.join(", "))
        end
        
        def parse(line)
          match =  line.scan(options.announce_mask)
          series_name = match[0][0]
          season_number = match[0][1]          
          episode_number = match[0][2]
    
          torrent_id = match[1][3]
        
          msg(options.owner_nick,"New Announce")
          msg(options.owner_nick,"Series-name: #{series_name}, Season: #{season_number}, Episode: #{episode_number}, TorrentID: #{torrent_id} ")
          options.series_regexp.each do |serie|
            if series_name =~ serie
              get_download(torrent_id)
            end
          end
        end

        def get_download(torrent_id)
          msg(options.owner_nick, "Torrent matched, downloading #{torrent_id}")
          url = "#{options.torrent_url}#{torrent_id}&authkey=#{options.auth_key}&torrent_pass=#{options.torrent_pass}"
          file = open("#{options.download_path}auto_ptp_#{torrent_id}.torrent", "wb")
          file.write(open(url).read)
          file.close
        end

      end
      on :connect do
        join(options.channels)
        puts("Connected to IRC")
        welcome
      end
      
      on :channel, // do
        if nick == options.listen_nick
          parse(message)
        end
      end
  
    end
  end
end