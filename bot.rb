require "discordrb"
require "mechanize"
require "json"
require "dotenv/load"
require "yaml"
require "active_record"
require "./models/airdrop.rb"
require 'logger'

messages = {
  "JA" => {
    :airdrop_message => "**Xp-QtウォレットかCCWalletのアドレスなら**\nたぶん `__AMOUNT__ XPC` 受け取れるよ。\n楽しみに待っててね。\n取引所やPoSプールのアドレスだと受け取れないよ。ごめんね。",
    :zero_balance => "残念だけどスナップショット時に残高がないので受け取れません。:sob:",
    :address_error => "アドレスを正しく指定してね",
  },
  "EN" => {
    :airdrop_message => "**If this address is Xp-Qt wallet or CCWallet,**\nyou may get `__AMOUNT__ XPC`.\Please look forward to it.\nYou won’t be able to receive the Airdrop if it is the address of an exchange, XP-Bot or PoS Pool. Sorry.:cry:",
    :zero_balance => "Sorry, but you won’t receive an Airdrop because there was no balance at the time of the Snapshot.:sob:",
    :address_error => "Please type address correctly",
  },
  "KO" =>
  {
    :airdrop_message => "이 주소가 XP-Qt 지갑이나 CCWallet 주소라면, 당신은 `__AMOUNT__ XPC` 를 받을 수 있습니다. 추후 공지를 기다려주시기 바랍니다.\n이 주소가 거래소 주소, XP-Bot 또는 PoS Pool 주소라면 에어드롭을 받을 수 없습니다, 죄송합니다.  :disappointed_relieved:
",
    :zero_balance => "죄송합니다. 스냅샷에 잔액이 찍히지 않아 에어드롭을 받을 수 없습니다. :sob:",
    :address_error => "주소를 정확히 입력해 주세요.",
  }
}

config = YAML.load_file( './database.yml' )
ActiveRecord::Base.establish_connection(config["db"]["development"])
ActiveRecord::Base.logger = Logger.new(STDOUT)

bot = Discordrb::Commands::CommandBot.new token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix: [ENV["PREFIX1"], ENV["PREFIX2"]]

bot.command [:ping], channels: ["bot_control"] do |event|
  event.respond "pong"
end

bot.command [:airdrop, :エアドロップ, :エアドロ, :ad] do |event, addr|
  message = messages[ENV["_LANG"]]
  puts ENV["_LANG"]
  event.message.react "\u23f3"
  a = Mechanize.new
  begin
    j = 0.0
    is_exists = Airdrop.where(address:addr).count > 0
    unless is_exists
      r = a.get("https://insight-b.xpjp.online/api/addr/#{addr}/balance")
      j = JSON.parse(r.body)
      j = j.to_f
      j = j * 0.00000001
    else
      airdrop = Airdrop.find_by(address:addr)
      j = airdrop.amount
    end

    unless is_exists
      airdrop = Airdrop.create(address: addr, amount: j)
    end

    event.message.react "\u2705"
    if j <= 0
      event.send_message "#{event.user.mention} #{message[:zero_balance]}"
    else
      event.send_message "#{event.user.mention} #{message[:airdrop_message].sub(/__AMOUNT__/, j.to_s)}"
    end

  rescue => e
    puts e
    event.message.react "\u274c"
    event.send_message "#{event.user.mention} #{message[:address_error]}"
  end
end

bot.run
