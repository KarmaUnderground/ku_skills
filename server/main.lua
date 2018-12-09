ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function get_skills()
    return Skills;
end

function get_skill(skill_name)
    local skill = Skills[skill_name]

    if not skill then
        print(('ku_skills: ERROR: The skill %s has not been registered'):format(skill_name))
        return nil
    end

    return skill;
end

function get_player_skills(xPlayer)
    local player_skills = xPlayer.get('skills')
    local player_skill = nil
    local skill = nil

    if not player_skills then -- Skills have not been initiated for this player
        xPlayer.set('skills', {})

        local result = MySQL.Sync.fetchAll('SELECT `identifier`, `name`, `tries` FROM `user_skills` WHERE `identifier` = @identifier ORDER BY `name`;',
        {
            ['@identifier'] = xPlayer.identifier
        })

        for i=1, #result, 1 do
            skill = get_skill(result[i].name)

            player_skill = {
                rate = skill.rate,
                name = skill.name,
                tries = result[i].tries,
                level = 0,
                used = false
            }

            player_skill.level = get_skill_level_from_tries(player_skill),
            
            set_player_skill(xPlayer, skill.name, player_skill)
        end

        player_skills = xPlayer.get('skills')
    end

    return player_skills
end

function get_player_skill(xPlayer, skill_name)
    local skill = get_skill(skill_name)

    local player_skills = get_player_skills(xPlayer)
    local player_skill = player_skills[skill_name]

    if not player_skill then
        MySQL.Sync.execute('INSERT INTO `user_skills` (`identifier`, `name`, `tries`) VALUES (@identifire, @skill_name, @tries)',
        {
            ['@identifire'] = xPlayer.identifier,
            ['@skill_name'] = skill.name,
            ['@tries'] = 0
        })

        player_skill = {
            rate = skill.rate,
            name = skill.name,
            tries = 0,
            level = 0.0,
            used = false
        }

        set_player_skill(xPlayer, skill.name, player_skill)

        if Config.show_notifications then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U("skill_added", _U(player_skill.name)))
        end

        TriggerEvent('ku_skills:skillAdded', xPlayer.source, player_skill)
        TriggerClientEvent('ku_skills:skillAdded', xPlayer.source, player_skill)
    end

    return player_skill
end

function get_player_skills_stats(xPlayer)
    local player_skills = get_player_skills(xPlayer)
    local skills_sum = 0
    local skills_count = 0

    for skill_name, player_skill in pairs(player_skills) do
        skills_sum = skills_sum + tonumber(player_skill.level)
        skills_count = skills_count + 1
    end

    return {sum = skills_sum, count = skills_count}
end

function increase_player_skill_roll(xPlayer, player_skill)
    local roll = math.random(1000) / 10

    if player_skill.level < roll then
        local originals = {
            tries = player_skill.tries,
            value = player_skill.value
        }
        set_player_skill_tries(xPlayer, player_skill, player_skill.tries + 1)

        local skills_stats = get_player_skills_stats(xPlayer)

        if skills_stats.sum > Config.max_skill_sum then
            decrease_random_player_skill(xPlayer, player_skill)
        end

        player_skill = get_player_skill(xPlayer, player_skill.name)
        if Config.show_notifications then
            TriggerClientEvent('esx:showNotification', xPlayer.source, _U("skill_increased", _U(player_skill.name), originals.value))
        end

        TriggerEvent('ku_skills:skillIncreased', xPlayer.source, player_skill, originals)
        TriggerClientEvent('ku_skills:skillIncreased', xPlayer.source, player_skill, originals)
    end
end

function decrease_random_player_skill(xPlayer, skill)
    local player_skills = get_player_skills(xPlayer)
    local skills_stats = get_player_skills_stats(xPlayer)

    if skills_stats.count > 1 then
        local player_skill = skill
        local index = -1
        local counter = -1

        while(player_skill.name == skill.name)
        do
            counter = 1
            index = math.random(1, skills_stats.count)
            for name, loop_skill in pairs(player_skills) do
                if index == counter then
                    player_skill = loop_skill
                    break
                end
                counter = counter + 1
            end
        end

        --TODO: Is the skills sum still over max?
        set_player_skill_tries(xPlayer, player_skill, player_skill.tries - 1)

        --TODO: Notifies, hooks, ...
    end
end

function set_player_skill_tries(xPlayer, player_skill, tries)
    local original_tries = 0
    if tries <= 0 then
        set_player_skill(xPlayer, player_skill.name, nil)
    else
        original_tries = player_skill.tries

        player_skill.used = true
        player_skill.tries = tries
        player_skill.level = get_skill_level_from_tries(player_skill)

        set_player_skill(xPlayer, player_skill.name, player_skill)

        --TODO: Trigger server and client event ku_skills:player_skill_up xPlayer, player_skill, original_value
    end
end

function set_player_skill(xPlayer, skill_name, player_skill)
    local player_skills = get_player_skills(xPlayer)

    if not player_skill then
        MySQL.Async.execute('DELETE FROM `user_skills` WHERE `identifier` = @identifire AND `name` = @name',
        {
            ['@identifire'] = xPlayer.identifier,
            ['@name'] = skill_name
        })
    end

    if not player_skills then
        player_skills = {}
    end

    player_skills[skill_name] = player_skill
    xPlayer.set('skills', player_skills)

    commit_player_skills(xPlayer) -- TODO: Where that should be done? Not here!
    --TODO: Notifies + hooks
end

function get_skill_level_from_tries(player_skill)
    --TODO: Try to use math.power()
    local level = 0

    level = math.sqrt((player_skill.rate*player_skill.rate) - ((player_skill.rate - player_skill.tries) * (player_skill.rate - player_skill.tries)))
    level = ESX.Round(((player_skill.level/player_skill.rate)*100),1)

    return level
end

function commit_player_skills(xPlayer)
    local player_skills = get_player_skills(xPlayer)

    for skill_name, player_skill in pairs(player_skills) do
        commit_player_skill(xPlayer, player_skill)
    end
end
    
function commit_player_skill(xPlayer, player_skill)
    if player_skill.used then
        MySQL.Async.execute('UPDATE `user_skills` SET `tries` = @tries, `last_usage` = NOW() WHERE `identifier` = @identifier AND `name` = @skill_name',
        {
            ['@tries'] = player_skill.tries,
            ['@identifier'] = xPlayer.identifier,
            ['@skill_name']   = player_skill.name
        })
    end
end

function player_skill_roll(xPlayer, player_skill)
    local roll_skill = math.random(1000) / 10
    local result = player_skill.level > roll_skill

    increase_player_skill_roll(xPlayer, player_skill)

    return result

    -- TODO: Notification + Hooks
    -- TODO: Ajouter une animation d'exécution, de succès et de fail
end

function execute_player_skill(xPlayer, player_skill)
    local success = player_skill_roll(xPlayer, player_skill)
    local player_skills = get_player_skills(xPlayer)

    return {
        success = success,
        skill = player_skills[skill_name]
    }
end