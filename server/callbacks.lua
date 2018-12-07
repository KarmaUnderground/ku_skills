ESX.RegisterServerCallback('ku_skills:getPlayerSkills', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local player_skills = get_player_skills(xPlayer)

    cb(player_skills)
end)

ESX.RegisterServerCallback('ku_skills:getPlayerSkill', function(source, cb, skill_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local player_skill = get_player_skill(xPlayer, skill_name)

    cb(player_skill)
end)

ESX.RegisterServerCallback('ku_skills:getPlayerSkillStats', function(source, cb, skill_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local player_skill_stats = get_player_skills_stats(xPlayer, skill_name)

    cb(player_skill_stats)
end)

ESX.RegisterServerCallback('ku_skills:executeSkill', function(source, cb, skill_name)
    local xPlayer = ESX.GetPlayerFromId(source)
    local player_skill = get_player_skill(xPlayer, skill_name)

    cb(execute_player_skill(xPlayer, player_skill))
end)
