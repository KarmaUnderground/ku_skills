TriggerEvent('ku_skills:registerConfigs',{
    locale = "fr"
})

TriggerEvent('ku_skills:registerSkill', {
    name = my_skill,
    rate = 5000,
},{
    en = {
        my_skill = "My skill",
    },
    fr = {
        my_skill = "Ma compétence",
    }
})
