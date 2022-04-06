ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('ku_admin:registerUIAdminTabs', GetCurrentResourceName(), {
    skills = {
        label = _U('skills'),
        root = 'ui/admin_tab',
        main_file = 'index.html',
        files = {
            'index.html',
            'index.js',
            'index.css'
        }
    }
})