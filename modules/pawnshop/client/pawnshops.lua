ActivePawnShops = {}
PawnShopClass = {}
PawnShopClass.__index = PawnShopClass

function PawnShopClass:new(id, position, model, radius)
    local obj = {
        id = id,
        position = position,
        model = model,
        radius = radius,
    }
    setmetatable(obj, self)
    ActivePawnShops[id] = obj
    obj:register()
    return obj
end

function PawnShopClass:register()
    local match = Config.PawnShops[self.id]
    if not match then return false end
    if match.Blip then
        self.blip = Bridge.Utility.CreateBlip(vector3(self.position.x, self.position.y, self.position.z), match.Blip.sprite, match.Blip.color, match.Blip.scale, match.Blip.label, true, 4)
    end
    Bridge.ClientEntity.Create({
        id = self.id,
        entityType = "ped",
        model = self.model,
        coords = self.position,
        heading = self.position.w,
        spawnDistance = self.radius,
        OnSpawn = function(entityData)
            SetBlockingOfNonTemporaryEvents(entityData.spawned, true)
            SetPedDiesWhenInjured(entityData.spawned, false)
            SetPedCanPlayAmbientAnims(entityData.spawned, true)
            SetPedCanRagdollFromPlayerImpact(entityData.spawned, false)
            SetEntityInvincible(entityData.spawned, true)
            FreezeEntityPosition(entityData.spawned, true)
            TaskStartScenarioInPlace(entityData.spawned, "WORLD_HUMAN_SMOKING", 0, true)
            Bridge.Target.AddLocalEntity(entityData.spawned, {
                {
                    name = 'PawnShop ' .. entityData.id,
                    label = locale("PawnShop.TargetLabel"),
                    icon  = locale("PawnShop.TargetIcon"),
                    distance = 5,
                    onSelect = function()
                        if not self:checkOpenHours() then return false, Bridge.Notify.SendNotify(locale("PawnShop.ShopClosed"), "error", 3000) end
                        GeneratePawnMenus(entityData.id)
                    end
                },
            })
            self.entityID = entityData.spawned
        end,
        OnRemove = function(entityData)
            if not entityData.spawned then return end
            Bridge.Target.RemoveLocalEntity(entityData.spawned)
            self.entityID = nil
        end
    })
    return true
end

function RegisterPawnPoints()
    for k, v in pairs(Config.PawnShops) do
        PawnShopClass:new(k, v.position, v.model, v.radius or 200.0)
    end
end

function PawnShopClass:destroy()
    if not ActivePawnShops[self.id] then return false end
    Bridge.ClientEntity.Destroy(self.id)
    if self.blip then Bridge.Utility.RemoveBlip(self.blip) end
    ActivePawnShops[self.id] = nil
end

function PawnShopClass:removeByID(id)
    if not ActivePawnShops[id] then return false end
    local shop = ActivePawnShops[id]
    shop:destroy()
end

function PawnShopClass:checkOpenHours()
    if not Config.PawnShops[self.id].storeHours then return true end
    local currenthour = GetClockHours()
    local storeHours = Config.PawnShops[self.id].storeHours
    if storeHours.open <= currenthour and storeHours.close >= currenthour then return true end
    return false
end

function DestroyAllPawnShops()
    for k, v in pairs(ActivePawnShops) do
        v:destroy(k)
    end
end

RegisterNetEvent("community_bridge:Client:OnPlayerLoaded", function()
    if Config.Utility.Debug then return end
    RegisterPawnPoints()
end)

RegisterNetEvent("community_bridge:Client:OnPlayerUnload", function()
    DestroyAllPawnShops()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DestroyAllPawnShops()
end)