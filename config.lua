Config = {} -- DON'T TOUCH

Config.DrawDistance       = 60.0 -- Change the distance before you can see the marker. Less is better performance.
Config.EnableBlips        = true -- Set to false to disable blips.

Config.Locale             = 'en' -- Change the language. Currently available (en or fr).

Config.NPCEnable          = true -- Set to false to disable NPC Ped at shop location.
Config.NPC	          = {
    {   x = 412.73, y = 313.56, z = 102.02, h = 202.99 , npc = -1267809450}, -- Location of the shop For the npc.
    {   x =182.91, y =-1319.44,z = 28.34, h = 202.99, npc = -1932625649}, 
    {   x =1866.34, y = 307.50,z = 162.12, h = 185.76, npc = -927261102}, 
}
Config.GiveBlack          = false -- Wanna use Blackmoney?


Config.Zones = {
    [1] = {coords = vector3(412.73, 313.56, 103.92), name = _U('map_blip_shop'), color = 50, sprite = 500, radius = 25.0, Pos = { x = 412.73, y = 313.56, z = 103.02}, Size  = { x = 3.0, y = 3.0, z = 1.0 }, opentext  ='Press ~g~[E]~g~ ~w~ to sell to Dylan', closedtext = '~r~Store is currently closed please come back later'},
    [2] = {coords = vector3(182.91, -1319.44, 29.32), name = _U('map_blip_shop2'), color = 25, sprite = 480, radius = 25.0, Pos = { x = 182.85, y = -1319.34, z = 29.32}, Size  = { x = 3.0, y = 3.0, z = 1.0 }, opentext  ='Press ~g~[E]~g~ ~w~ to sell to Joe', closedtext = '~g~Joes busy hitting a bowl with stupid come back later'},
    [3] = {coords = vector3(1866.34, 307.50, 163.12), name = _U('map_blip_shop3'), color = 47, sprite = 280, radius = 25.0, Pos = { x = -1866.34, y = 307.50, z = 163.12}, Size  = { x = 3.0, y = 3.0, z = 1.0 }, opentext  ='Press ~g~[E]~g~ ~w~to sell to Manii', closedtext = '~r~Manni isnt here check back later'},
}

Config.Items = {
    { name = 'water', price = 125, storenumber = 2},
    { name = 'bread', price = 125, storenumber = 1},
    { name = 'carokit', price = 1125, storenumber = 2},
    { name = 'carokit', price = 1125, storenumber = 3},

}

