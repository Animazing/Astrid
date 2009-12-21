require 'net/http'
require "open-uri"
require 'rubygems'
require 'yaml'


class Astrid 
  VERSION = 0.2
  attr_accessor :torrent_url, :announce_mask, :bot, :irc_server, :listen_nick
  attr_accessor :auth_key, :torrent_pass, :owner_nick, :bot_nick, :channels
  attr_accessor :series_regexp, :series_names, :download_path

  def initialize
    self.torrent_url = "http://www.sharetheremote.org/torrents.php?action=download&id="
    self.announce_mask =  /::\s(.*)\sS(\d*)E(\d*)|torrentid=(\d*)/
    self.irc_server = "irc.sharetheremote.org"
    self.channels = "#announce"
    self.listen_nick = "TVGuide"
    self.series_regexp = []
    self.series_names = []
    self.load_config
    self.bot = BotWrapper.new(self)
    self.bot.start
  end
  
  protected
  def load_config
    if File.exists?("config.yml")
      config = YAML.load_file("config.yml")
      self.auth_key = config["config"]["auth_key"]
      self.torrent_pass = config["config"]["torrent_pass"]
      self.owner_nick = config["config"]["owner_nick"]
      self.bot_nick = config["config"]["bot_nick"]
      self.download_path = config["config"]["download_path"]

      config["config"]["series"].each do |serie|
        self.series_names << serie[0]
        self.series_regexp << eval("/#{serie[1]}/i")
      end  
    else
      raise "Config file not found, exiting."
    end
  end
end
