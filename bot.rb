require "discordrb"
require "mechanize"
require "json"
require "dotenv/load"

bot = Discordrb::Commands::CommandBot.new token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix: ["$", "＄"]

bot.command [:ping], channels: ["bot_control"] do |event|
  event.respond "pong"
end

bot.command [:airdrop, :エアドロップ, :ad] do |event, addr|
  a = Mechanize.new
  begin
    r = a.get("https://insight-b.xpjp.online/api/addr/#{addr}/balance")
    j = JSON.parse(r.body)
    j = j.to_f
    j = j * 0.00000001
    event.send_message "たぶん `#{j} XPC` 受け取れるよ。楽しみに待っててね。"
  rescue
    event.send_message "アドレスを正しく指定してね"
  end
end

bot.run
