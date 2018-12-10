ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

--TODO: Check if table exists. If not, create
math.randomseed(os.time())