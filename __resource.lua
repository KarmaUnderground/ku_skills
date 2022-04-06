resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'Karma Underground Skills'

version '0.1'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',

	'locales/en.lua',
	'locales/fr.lua',

	'libs/random_normal.lua',

	'config.lua',

	'server/init.lua',
	'server/callbacks.lua',
	'server/main.lua',

	'ui/admin_tab/server.lua'
}

client_scripts {
	'@es_extended/locale.lua',

	'locales/en.lua',
	'locales/fr.lua',

	'config.lua',

	'ui/admin_tab/client.lua'
}

dependencies {
	'es_extended'
}
