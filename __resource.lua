resource_manifest_version 'ac607a4c-abe9-4d83-91e3-dc5c53541d92'

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
}

dependencies {
	'es_extended'
}
