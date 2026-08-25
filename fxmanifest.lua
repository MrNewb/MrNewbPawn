fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'MrNewbPawn'
description 'Pawn shops with optional stock buy-back and foundry smelting'
author 'MrNewb'
version '1.5.1'

shared_scripts {
	'@ox_lib/init.lua',
	'@Newb_Bridge/import.lua',
	'configs/config.lua',
	'resource/shared/locale.lua',
}

client_scripts {
	'resource/client/shops.lua',
	'resource/client/foundry.lua',
	'resource/client/debug.lua',
}

server_scripts {
	'resource/server/shops.lua',
	'resource/server/foundry.lua',
}

files {
	'locales/*.json',
}

dependencies {
	'/server:6116',
	'/onesync',
	'ox_lib',
	'Newb_Bridge',
}

escrow_ignore {
	'configs/*.lua',
	'locales/*.json',
	'resource/**/*.lua',
}
