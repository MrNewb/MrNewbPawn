Config = {}

Config.Utility = {
    Debug = false,
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
        StoreHours = {
            open = 12,
            close = 16,
        }
    },
    ["Stretchs Pawn Shop"] = {
        position = vector4(181.7478, -1320.8424, 28.3126, 250.1435),
        model = "ig_ramp_hic",
        radius = 100.0,
        Blip = {
            label = "Stretchs Pawn Shop",
            color = 50,
            sprite = 500,
            scale = 0.8,
        },
    },
}

Config.PawnItems = {
    ['metalscrap'] = 10,
    ['iron'] = 3,
    ['diamond_ring'] = 125,
    ['radio'] = 10,
}

Config.FoundryLocations = {
    { name = "Foundry", position = vector4(1087.9452, -2002.0835, 30.8810, 144.2094), blip = { display = true, sprite = 436, color = 6, scale = 0.8} },
}

Config.MeltableItems = {
    ['metalscrap'] = {
        {itemName = 'iron', count = 1}
    },
    ['diamond_ring'] = {
        {itemName = 'diamond', count = 1}
    },
}