math.randomseed(os.time())

--[[
    This will define the configs that will be used by the menu. You can override any of the configs defined in the config.lua file
]]
RegisterServerEvent('ku_skills:registerConfigs')
AddEventHandler('ku_skills:registerConfigs', function(override_configs)	
    for k,v in paire(override_configs) do
        configs[k] = v
    end
end)

--[[
    The param skill must have this structure:
    {
        name = my_skill, -- Must be unique. It's the primery key
        rate = 5000, -- Number of tries to reach 100%
    }

    The param skill_translations must have this structure (in the example I have fr and en but you can have more than that):
    {
        en = {
            my_skill = "My skill",
        },
        fr = {
            my_skill = "Ma compétence",
        }
    }
]]
RegisterServerEvent('ku_skills:registerSkill')
AddEventHandler('ku_skills:registerSkill', function(skill, skill_translations)	
    configs[skill.name] = skill

    for locale, translations in paire(skill_translations) do
        if not Locales[locale] then
            Locales[locale] = {}
        end

        for key, value in paire(translations) do
            Locales[locale][key] = value
        end
    end
end)

--[[
    This function will make the skill unavailable on the server
]]
RegisterServerEvent('ku_skills:unregisterSkill')
AddEventHandler('ku_skills:unregisterSkill', function(skill_name)	
    skills[skill_name] = nil
end)