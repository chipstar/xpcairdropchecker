require "discordrb"
require "mechanize"
require "json"
require "dotenv/load"

bot = Discordrb::Commands::CommandBot.new token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix: ["$", "＄"]

bot.command [:ping], channels: ["bot_control"] do |event|
  event.respond "pong"
end

bot.command [:airdrop, :エアドロップ, :エアドロ, :ad] do |event, addr|
  event.message.react "\u23f3"
  a = Mechanize.new
  begin
    r = a.get("https://insight-b.xpjp.online/api/addr/#{addr}/balance")
    j = JSON.parse(r.body)
    j = j.to_f
    j = j * 0.00000001
    event.message.react "\u2705"
    if j <= 0
      event.send_message "#{event.user.mention} 残念だけどスナップショット時に残高がないので受け取れません。:sob:"
    else
      event.send_message "#{event.user.mention} **Xp-QtウォレットかCCWalletのアドレスなら**\nたぶん `#{j} XPC` 受け取れるよ。\n楽しみに待っててね。\n取引所やPoSプールのアドレスだと受け取れないよ。ごめんね。"
    end
  rescue
    event.message.react "\u274c"
    event.send_message "#{event.user.mention} アドレスを正しく指定してね"
  end
end

bot.run
