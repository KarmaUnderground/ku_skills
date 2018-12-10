--**************************************************
--  Server functions
--**************************************************
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

    local response = nil

    if not player_skill then
        reponse = nil
    else
        response = execute_player_skill(xPlayer, player_skill)
    end

    cb(reponse)
end)

--[[****************************************************
    This will define the configs that will be used by the menu. You can override any of the configs defined in the config.lua file
--[[****************************************************]]
AddEventHandler('ku_skills:registerConfigs', function(override_configs)	
    for k,v in pairs(override_configs) do
        Config[k] = v
    end
end)

--[[****************************************************
    The param skill must have this structure:
    {
        name = "carpenter", -- Must be unique. It's the primery key
        rate = 5000, -- Number of tries to reach 100%
        prerequisites = {
            skill = {
                {
                    name = "nail", -- Name of a prerequisit skill
                    level = "25" -- Minimum level that the player must have of that skill to use the main skill
                }
            },
            item = {
                "hammer", -- Name of a prerequisit item
                "box_of_nails"
            }
        }
    }

    The param skill_translations must have this structure (in the example I have fr and en but you can have more than that):
    {
        en = {
            carpenter = "Carpenter",
            carpenter_skill_roll_failed = "You missed building",
            carpenter_skill_roll_success = "You succeed building",
        },
        fr = {
            carpenter = "Menuisier",
            carpenter_skill_roll_failed = "Vous n'avez pas réussi votre construction",
            carpenter_skill_roll_success = "Vous avez réussi votre construction",
        }
    }
--[[****************************************************]]
AddEventHandler('ku_skills:registerSkill', function(skill, skill_translations)	
    Skills[skill.name] = skill

    for locale, translations in pairs(skill_translations) do
        if not Locales[locale] then
            Locales[locale] = {}
        end

        for key, value in pairs(translations) do
            Locales[locale][key] = value
        end
    end

    print(('ku_skills: Skill %s has been registered'):format(skill.name))
end)

--[[****************************************************
    This function will make the skill unavailable on the server
--[[****************************************************]]
RegisterServerEvent('ku_skills:unregisterSkill')
AddEventHandler('ku_skills:unregisterSkill', function(skill_name)	
    if Skills[skill_name] then
        Skills[skill_name] = nil
        print(('ku_skills: Skill %s has been unregistered'):format(skill_name))
    end
end)