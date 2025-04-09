fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'MrNewbPawn'
description 'A very old pawn shop system, slightly modernized to keep working. This script focuses on a minimilistic approach, with no fancy features. It is a simple pawn shop system that allows you to buy and sell items.'
version '0.0.2'

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
	'src/shared/*.lua',     	-- Config files
	'src/open/client/*.lua',   	-- open files
	'src/open/server/*.lua',   	-- open files
}