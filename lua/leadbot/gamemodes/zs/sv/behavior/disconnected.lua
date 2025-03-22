function LeadBot.Disconnected(bot)
    if not IsValid(bot.ControllerBot) then return end

    bot.ControllerBot:Remove()
end