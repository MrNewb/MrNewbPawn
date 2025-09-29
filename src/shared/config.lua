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
--		  If you need help with configuration or have any questions, please do not hesitate to ask.
--		  Docs Are Always Available At -- https://mrnewbs-scrips.gitbook.io/guide


Config = {}

Config.Utility = {
    Debug = false, -- Set to true for debug mode, this will enable debug prints and some extra functionality.
}

Config.Settings = {
    EnableLogging = false, -- Set to false to disable logging.
    PurchasePawnedItems = true, -- Set to false to disable the ability for players to purchase pawned items.
}

Config.PawnShops = {
    Dylan = {
        position = vector4(411.3616, 313.7914, 102.0207, 211.4422),
        model = "a_m_m_farmer_01",
        radius = 100.0,
        Blip = {
            label = "Dylans Pawn Shop",
            color = 50,
            sprite = 500,
            scale = 0.8,
        },
        --storeHours = { open = 8, close = 20 }, -- option open/close hours, just comment this out if you dont want to use it
        itemlist = {
            ['metalscrap'] = 10,
            ['iron'] = 3,
            ['diamond_ring'] = 125,
            ['radio'] = 10,
        }
    },
    ["Stretchs Pawn Shop"] = {
        position = vector4(173.6201, -1323.1860, 28.3635, 325.7649),
        model = "ig_ramp_hic",
        radius = 100.0,
        Blip = {
            label = "Stretchs Pawn Shop",
            color = 50,
            sprite = 500,
            scale = 0.8,
        },
        itemlist = {
            ['metalscrap'] = 10,
            ['iron'] = 3,
            ['diamond_ring'] = 125,
            ['radio'] = 10,
        }
    },
    ["Robbies Pawn Shop"] = {
        position = vector4(-1459.5859, -414.3852, 34.7232, 173.9407),
        model = "a_m_m_bevhills_02",
        radius = 100.0,
        Blip = {
            label = "Robbies Pawn Shop",
            color = 50,
            sprite = 500,
            scale = 0.8,
        },
        itemlist = {
            ['metalscrap'] = 10,
            ['iron'] = 3,
            ['diamond_ring'] = 125,
            ['radio'] = 10,
        }
    },
}

Config.FoundryLocations = {
    ["Foundry"] = {
        position = vector4(1087.4078, -2002.4720, 31.3718, 134.9108),
        radius = 1.0,
        Blip = { label = "Foundry", color = 6, sprite = 436, scale = 0.8, },
    },
    ["Foundry2"] = {
        position = vector4(1112.2117, -2009.7408, 32.0977, 240.2337),
        radius = 2.0,
        --Blip = { label = "Foundry", color = 6, sprite = 436, scale = 0.8, },
    },
}

Config.MeltableItems = {
    ['metalscrap'] = {
        {itemName = 'iron', count = 1},
        {itemName = 'diamond', count = 1}
    },
    ['diamond_ring'] = {
        {itemName = 'diamond', count = 1}
    },
}