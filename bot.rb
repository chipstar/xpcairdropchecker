require "discordrb"
require "mechanize"
require "json"
require "dotenv/load"

bot = Discordrb::Commands::CommandBot.new token: ENV["TOKEN"], client_id: ENV["CLIENT_ID"], prefix: ["$", "＄"]

bot.command [:ping], channels: ["bot_control"] do |event|
  event.respond "pong"
end

bot.command [:airdrop, :エアドロップ, :エアドロ, :ad] do |event, addr|
  # event.message.create_reaction("hourglass_flowing_sand")
  a = Mechanize.new
  begin
    r = a.get("https://insight-b.xpjp.online/api/addr/#{addr}/balance")
    j = JSON.parse(r.body)
    j = j.to_f
    j = j * 0.00000001
    event.send_message "#{event.user.mention} **Xp-QtウォレットかCCWalletのアドレスなら**\nたぶん `#{j} XPC` 受け取れるよ。\n楽しみに待っててね。\n取引所やPoSプールのアドレスだと受け取れないよ。ごめんね。"
  rescue
    event.send_message "#{event.user.mention} アドレスを正しく指定してね"
  end
end

bot.run
