--		___  ___       _   _                  _      _____              _         _
--		|  \/  |      | \ | |                | |    /  ___|            (_)       | |
--		| .  . | _ __ |  \| |  ___ __      __| |__  \ `--.   ___  _ __  _  _ __  | |_  ___
--		| |\/| || '__|| . ` | / _ \\ \ /\ / /| '_ \  `--. \ / __|| '__|| || '_ \ | __|/ __|
--		| |  | || |   | |\  ||  __/ \ V  V / | |_) |/\__/ /| (__ | |   | || |_) || |_ \__ \
--		\_|  |_/|_|   \_| \_/ \___|  \_/\_/  |_.__/ \____/  \___||_|   |_|| .__/  \__||___/
--									          							  | |
--									          							  |_|
--
--		  Need support? Join our Discord server for help: https://discord.gg/mrnewbscripts
--		  Check out my paid scripts and freebies at https://mrnewbscripts.tebex.io/
--		  If you need help with configuration or have any questions, please do not hesitate to ask.
--		  Docs Are Always Available At -- https://mrnewb.github.io/docs/
--

Config = Config or {}

Config.Debug = false
Config.Logging = false
Config.PurchaseStock = true
Config.PurchaseMarkup = 20 -- percent over sell price when buying stock back

-- Optional hours use the client game clock (GetClockHours). Omit, or set open == close, for always open.
-- Example: storeHours = { open = 8, close = 22 },

local pawnItemList = {
	metalscrap = 8,
	iron = 4,
	steel = 7,
	copper = 9,
	aluminum = 6,
	plastic = 3,
	glass = 3,
	rubber = 3,
	radio = 15,
	phone = 40,
	laptop = 90,
	rolex = 140,
	goldchain = 75,
	diamond_ring = 100,
	sapphire_ring = 110,
	emerald_necklace = 130,
	ruby_ring = 140,
	diamond_necklace = 185,
	gold = 45,
	diamond = 80,
}

Config.PawnShops = {
	['Christians Pawn Shop'] = {
		position = vector4(412.5550, 314.4313, 103.0210, 220.8834),
		model = 'a_m_m_farmer_01',
		radius = 100.0,
		-- storeHours = { open = 8, close = 22 },
		Blip = {
			label = 'Christians Pawn Shop',
			color = 50,
			sprite = 500,
			scale = 0.8,
		},
		itemlist = pawnItemList,
	},
	['Stretchs Pawn Shop'] = {
		position = vector4(183.1389, -1319.7739, 29.3186, 246.9986),
		model = 'ig_ramp_hic',
		radius = 100.0,
		-- storeHours = { open = 8, close = 22 },
		Blip = {
			label = 'Stretchs Pawn Shop',
			color = 50,
			sprite = 500,
			scale = 0.8,
		},
		itemlist = pawnItemList,
	},
	['Robbies Pawn Shop'] = {
		position = vector4(-1459.8115, -413.8209, 35.7551, 178.0825),
		model = 'a_m_m_bevhills_02',
		radius = 100.0,
		-- storeHours = { open = 8, close = 22 },
		Blip = {
			label = 'Robbies Pawn Shop',
			color = 50,
			sprite = 500,
			scale = 0.8,
		},
		itemlist = pawnItemList,
	},
}

Config.FoundryLocations = {
	Foundry = {
		Zone = {
			coords = vector3(1086.18, -2003.78, 30.98),
			size = vector3(4.55, 3.00, 3.05),
			rotation = 229.48,
		},
	},
	Foundry2 = {
		Zone = {
			coords = vector3(1112.93, -2010.13, 32.64),
			size = vector3(4.50, 7.50, 10.50),
			rotation = 236.29,
		},
		Blip = { label = 'Foundry', color = 6, sprite = 436, scale = 0.8 },
		lerpProp = {
			lerpSpeed = 0.25,
			waypoints = {
				vector3(1114.6724, -2011.4340, 34.8549),
				vector3(1112.0618, -2009.6460, 34.8549),
				vector3(1112.0618, -2009.6460, 32.7968),
			},
		},
	},
}

Config.MeltableItems = {
	metalscrap = {
		prop = 'prop_rub_scrap_06',
		rewards = {
			{ itemName = 'iron', count = 1 },
		},
	},
	diamond_ring = {
		rewards = {
			{ itemName = 'diamond', count = 1 },
		},
	},
	goldchain = {
		rewards = {
			{ itemName = 'gold', count = 1 },
		},
	},
	rolex = {
		rewards = {
			{ itemName = 'gold', count = 1 },
			{ itemName = 'metalscrap', count = 1 },
		},
	},
}
