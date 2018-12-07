ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get_skills()
    return skills;
end

function get_skill(skill_name)
    return skills[skill_name];
end

function get_player_skills(xPlayer)
    local player_skills = xPlayer.get('skills')
    local player_skill = nil

    if not player_skills then -- Skills have not been initiated for this player
        local result = MySQL.Sync.fetchAll('SELECT `identifier`, `name`, `tries` FROM `user_skills` WHERE `us`.`identifier` = @identifier ORDER BY `level`;',
        {
            ['@identifier'] = xPlayer.identifier
        })

        for i=1, #result, 1 do
            skill = get_skill(result[i]['name'])

            if skill then
                get_player_skill(xPlayer, skill.name)
            end
        end

        player_skills = xPlayer.get('skills')
    end

    return player_skills
end

function get_player_skill(xPlayer, skill_name)
    local player_skills = xPlayer.get('skills')
    local player_skill = player_skills[skill_name]

    if not player_skill then
        local skill = get_skill(skill_name)

        if not skill then
            return nil
        end

        MySQL.Sync.execute('INSERT INTO `player_skills` (`identifier`, `name`, `tries`) VALUES (@identifire, @skill_name, @tries)',
        {
            ['@identifire'] = xPlayer.identifier,
            ['@skill_id']   = skill.name,
            ['@tries']      = 0
        })

        player_skill = {
            rate = skill.rate,
            name = skill.name,
            tries = result[i]['tries'],
            level = get_skill_level_from_tries(result[i]['level'], skill.rate),
            used = false
        }

        set_player_skill(xPlayer, skill.name, player_skill)

        TriggerClientEvent('esx:showNotification', xPlayer.source, _U("skill_new", _U(name)))

        --TODO: Trigger server and client event ku_skills:sill_added_to_player xPlayer, player_skill
    end

    return player_skill
end

function get_player_skills_stats(xPlayer)
    local player_skills = get_player_skills(xPlayer)
    local skills_sum = 0
    local skills_count = 0

    for skill_name, player_skill in pairs(player_skills) do
        skills_sum = skills_sum + tonumber(skill.level)
        skills_count = skills_count + 1
    end

    return {sum = skills_sum, count = skills_count}
end

-- CHU RENDU ICI!
function increase_player_skill(xPlayer, player_skill)
    local roll = math.random(1000) / 10

    if player_skill.level < roll then
        set_player_skill_tries(xPlayer, player_skill, player_skill.tries + 1)

        local skills_stats = get_player_skills_stats(xPlayer)

        if skills_stats.sum > configs.max_skill_sum then
            decrease_random_player_skill(xPlayer, player_skill)
        end

        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('skill_up', _U(skill.name), skill.level + 0.1))
    end
end

function set_player_skill(xPlayer, skill_name, player_skill)
    local player_skills = xPlayer.get('skills')

    if not player_skills then
        player_skills = {}
    end

    player_skills[skill_name] = player_skill
    xPlayer.set('skills', player_skills)
end

function get_skill_level_from_tries(skill)
    ----ROUND((SQRT(POWER(@skill_rate, 2) - POWER(@skill_rate - `tries`, 2)) / @skill_rate)*100, 1)

    local skill_rate = get_industry_step(skill).skill_rate

    skill.level = math.sqrt((skill.skill_rate*skill.skill_rate) - ((skill.skill_rate - skill.tries) * (skill.skill_rate - skill.tries)))
    skill.level = ESX.Round(((skill.level/skill.skill_rate)*100),1)

    return skill
end

function remove_player_skill(xPlayer, player_skill)
    set_player_skill(xPlayer, player_skill.name, player_skill)

    MySQL.Async.execute('DELETE FROM `user_skills` WHERE `identifier` = @identifire AND `name` = @name',
    {
        ['@identifire'] = xPlayer.identifier,
        ['@name'] = player_skill.name
    })
end

function execute_player_skill(xPlayer, player_skill)
    local success = player_skill_execution(player_skill)
    player_skill_improvement(player_skill)

    local player_skills = get_player_skills(xPlayer)

    return {
        success = success,
        skill = player_skills[player_skill.name]
    }
end

function commit_player_skills(xPlayer)
    local player_skills = get_player_skills(xPlayer)

    for skill_name, player_skill in pairs(player_skills) do
        commit_player_skill(xPlayer, player_skill)
    end
end

function commit_player_skill(xPlayer, player_skill)
    local player_skills = get_player_skills(xPlayer)

    if skill.used then
        MySQL.Async.execute('UPDATE `user_skills` SET `tries` = @tries, `last_usage` = NOW() WHERE `identifier` = @Identifier AND `skill_id` = @Skill_id',
        {
            ['@tries'] = player_skill.tries,
            ['@Identifier'] = xPlayer.identifier,
            ['@Skill_id']   = player_skill.id
        })
    end
end

function set_player_skill_tries(xPlayer, skill, tries, show_message)
    if tries <= 0 then
        remove_player_skill(xPlayer, skill)

        if show_message == true then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U("skill_removed", _U(skill.name)))
        end
    else
        local player_skills = get_player_skills(xPlayer)

        skill.tries = tries
        skill = get_skill_level_from_tries(skill)
        skill.used = true

        player_skills[skill.industry][skill.name] = skill

        xPlayer.set('skills', player_skills)

        commit_player_skills(xPlayer)

        if show_message == true then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U("skill_modified", _U(skill.name), level))
        end
    end
end

function decrease_random_player_skill(xPlayer, not_skill)
    local player_skills = get_player_skills(xPlayer)
    local skills_stats = get_player_skills_stats(xPlayer)

    if skills_stats.count > 1 then
        local skill = not_skill
        local index = -1
        local counter = -1

        while(skill.name == not_skill.name)
        do
            index = math.random(1, skills_stats.count)
            counter = 1

            for name, loop_skill in pairs(player_skills) do
                if index == counter then
                    skill = loop_skill
                    break
                end
                counter = counter + 1
            end
        end

        set_player_skill_tries(xPlayer, skill, skill.tries - 1)

        TriggerClientEvent('esx:showNotification', xPlayer.source, _U('skill_down', _U(skill.name), skill.tries - 1))
    end
end

function execute_player_skill(skill)
    local step = get_industry_step(skill)
    local mood = "bad"
    local diff = 12.5
    local variace = 0.8
    local add = 0

    local roll_skill = math.random(1000) / 10

    if skill.level > roll_skill then
        mood = "good"

        local roll_qty = rand_normal(skill.level - diff, skill.level + diff, variace, 0.1, 100)
        local multiplyer = 1 --local multiplyer = get_industry_step(skill).add

        add = (math.floor(roll_qty/25)+1)*multiplyer
    end

    xPlayer.addInventoryItem(skill.name, add)

    if Config.PlayAnimation then
        TriggerClientEvent("ku_skills:anim", xPlayer.source, mood)
    end
end

--******************************************************************
-- Execute skill action
--******************************************************************
