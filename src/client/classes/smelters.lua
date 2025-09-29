ActiveSmeltPoints = {}
SmelterClass = {}
SmelterClass.__index = SmelterClass

function SmelterClass:new(id, position, radius, blipData)
    local obj = {
        id = id,
        position = position,
        blipData = blipData or {},
        radius = radius,
    }
    setmetatable(obj, self)
    ActiveSmeltPoints[id] = obj
    obj:register()
    return obj
end

function SmelterClass:register()
    local match = Config.FoundryLocations[self.id]
    if not match then return false end
    if match.Blip then
        self.blip = Bridge.Utility.CreateBlip(vector3(self.position.x, self.position.y, self.position.z), match.Blip.sprite, match.Blip.color, match.Blip.scale, match.Blip.label, true, 4)
    end
    self.zone = self.id
    Bridge.Target.AddSphereZone(self.id, self.position, self.radius, {
        {
            name = 'Melting '..self.id,
            label = locale("Smelting.TargetLabel"),
            icon = locale("Smelting.TargetIcon"),
            distance = 5,
            onSelect = function()
                GenerateMeltMenu(self.id)
            end
        },
    }, Config.Utility.Debug)
    return true
end

function RegisterSmeltPoints()
    for k, v in pairs(Config.FoundryLocations) do
        SmelterClass:new(k, v.position, v.radius or 2.0, v.Blip)
    end
end

function SmelterClass:destroy()
    if self.blip then Bridge.Utility.RemoveBlip(self.blip) end
    if self.zone then Bridge.Target.RemoveZone(self.zone) end
    ActiveSmeltPoints[self.id] = nil
    return true
end

function RemoveSmelterByID(id)
    if not ActiveSmeltPoints[id] then return false end
    local shop = ActiveSmeltPoints[id]
    shop:destroy()
end

AddEventHandler("community_bridge:Client:OnPlayerLoaded", function()
    if Config.Utility.Debug then return print("Debug mode is enabled, restart the script for testing.") end
    RegisterSmeltPoints()
end)

AddEventHandler("community_bridge:Client:OnPlayerUnload", function()
    for k, v in pairs(ActiveSmeltPoints) do
        v:destroy(k)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for k, v in pairs(ActiveSmeltPoints) do
        v:destroy(k)
    end
end)