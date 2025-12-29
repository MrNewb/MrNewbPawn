fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'MrNewb'
name 'MrNewbPawn'
description 'A pawn shop system built for pure efficiency. Trade items with fast transactions buy, sell, profit. Zero bloat.'
version '1.4.0'

shared_scripts {
	'data/config.lua',
	'core/init.lua',
}

client_scripts {
	'modules/**/client/*.lua',
}

server_scripts {
	'modules/**/server/*.lua',
}

files {
	'locales/*.*',
}

dependencies {
	'/server:6116',
	'/onesync',
	'community_bridge',
}

escrow_ignore {
	'***/**/*.lua',
}