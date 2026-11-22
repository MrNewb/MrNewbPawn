fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'MrNewbPawn'
description 'Pawn shops with optional stock buy-back and foundry smelting'
author 'MrNewb'
version '1.5.2'

shared_scripts {
	'@ox_lib/init.lua',
	'@Newb_Bridge/import.lua',
	'resource/open/shared/config.lua',
	'resource/modules/core/shared/locale.lua',
}

client_scripts {
	'resource/modules/shops/client/shops.lua',
	'resource/modules/foundry/client/foundry.lua',
	'resource/modules/core/client/debug.lua',
}

server_scripts {
	'resource/modules/shops/server/shops.lua',
	'resource/modules/foundry/server/foundry.lua',
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
	'**/*',
}
