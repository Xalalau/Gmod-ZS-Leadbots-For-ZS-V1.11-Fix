function LeadBot.Disconnected(bot)
    if IsValid(bot.ControllerBot) then
        bot.ControllerBot:Remove()
    end
end