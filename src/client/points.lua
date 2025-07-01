function BuildPedsAndTargets(createdPed, heading, k)
    SetEntityHeading(createdPed, heading)
    SetBlockingOfNonTemporaryEvents(createdPed, true)
    SetPedDiesWhenInjured(createdPed, false)
    SetPedCanPlayAmbientAnims(createdPed, true)
    SetPedCanRagdollFromPlayerImpact(createdPed, false)
    SetEntityInvincible(createdPed, true)
    FreezeEntityPosition(createdPed, true)
    TaskStartScenarioInPlace(createdPed, "WORLD_HUMAN_SMOKING", 0, true)
    Bridge.Target.AddLocalEntity(createdPed, {
        {
            name = 'PawnShop ' .. k,
            label = locale("PawnShop.TargetLabel"),
            icon  = locale("PawnShop.TargetIcon"),
            distance = 5,
            onSelect = function()
                if not VerifyDayTime(k) then return false, NotifyPlayer(locale("PawnShop.ShopClosed"), "error", 3000) end
                GeneratePawnMenus(k)
            end
        },
    })
end

function RegisterPawnPoints()
    for k, v in pairs(Config.PawnShops) do
            if v.Blip then
                local shopBlip = Bridge.Utility.CreateBlip(v.position, v.Blip.sprite, v.Blip.color, v.Blip.scale, v.Blip.label, true, 4)
                ShopBlips[k] = shopBlip
            end
            Bridge.Point.Register(k, v.position, 50, { CreatedPed = nil },
            function(point, args)
                local timeOfDayValid = VerifyDayTime(k)
                DebugInfo("Shop is currently open: " .. tostring(timeOfDayValid))
                if timeOfDayValid then
                    local createdPed = Bridge.Utility.CreatePed(v.model, v.position, v.position.w, false, nil)
                    BuildPedsAndTargets(createdPed, v.position.w, k)
                    args.CreatedPed = createdPed
                    CreatedPeds[k] = createdPed
                end
                return args
            end,
            function(point, args)-- OnExit
                if args and args.CreatedPed and DoesEntityExist(args.CreatedPed) then
                    SetEntityAsMissionEntity(args.CreatedPed, false, true)
                    DeleteEntity(args.CreatedPed)
                    CreatedPeds[k] = nil
                end
                return args
            end,
            function()
                -- unused
            end
        )
        ActivePoints[k] = k
    end
end