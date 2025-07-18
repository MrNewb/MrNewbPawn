fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'MrNewbPawn'
description 'A basic, minimally featured pawn shop system. Its an older system, slightly updated to remain functional, focusing solely on buying and selling items without any extra frills.'
version '1.1.2'

shared_scripts {
	'@ox_lib/init.lua',
	'src/shared/config.lua',
	'src/shared/init.lua',
}

client_script {
	'src/client/*.lua',
}

server_scripts {
	'src/server/*.lua',
}

files {
	'locales/*.*',
}

dependencies {
	'/server:6116',
	'/onesync',
	'ox_lib',
	'community_bridge',
}

escrow_ignore {
	'src/**/*.lua',
}