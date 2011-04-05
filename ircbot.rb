#/usr/
require 'cinch'
require 'sequel'
require 'yaml'

configuration = YAML.load_file("./settings.yaml")

if ARGV.include? "-dev"
  database = configuration["dev_db"]
else
  database = configuration["prod_db"]
end

DB = Sequel.connect(database)

require './models/quote'
require './models/user'

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = configuration["bot_server"]
    c.nick     = configuration["bot_nick"]
    c.channels = configuration["bot_channels"]
  end
  
  on :message, /^\.quote (.+)/ do |m, query|
    #How does it know what database to use? MAGIC.
    quote = Quote.filter(:content.like("%"+query+"%")).order{random{}}.first
    if quote
      m.reply(quote.content)
    end
  end
  
  on :message, /^\.quote$/ do |m|
    quote = Quote.order{random{}}.first
    if quote
      m.reply(quote.content)
    end
  end
  
  on :message, /^\.addquote (.+)/ do |m, quote|
    name_parts = m.user.realname.split
    user = User.find_or_create(:username => m.user.nick) {|u|
      if !name_parts[0].nil?
        u.first_name = name_parts[0]
        if name_parts.length > 1
          u.last_name = name_parts[1]
        else
          u.last_name = "Anonymous"
        end
      else
        u.first_name = m.user.nick
        u.last_name = "Anonymous"
      end
    }
    Quote.create(
      :user_id => user.id,
      :content => quote,
      :votes => 0
    )
  end
end

bot.start
