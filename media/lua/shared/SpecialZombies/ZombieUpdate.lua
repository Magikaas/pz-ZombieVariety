local specialZombieManager = require "SpecialZombies/Manager";

local ZombieUpdate = {};

function ZombieUpdate.Prepare(zombie)
    if not zombie or zombie:isDead() then
        return
    end

    local modData = zombie:getModData();

    if not modData.ZombieVariety then
        modData.ZombieVariety = {
            mustApplySpecial = false,
            applied = false,
            rolled = false,
            status = {}
        };
    end

    if not modData.ZombieVariety.status then
        modData.ZombieVariety.status = {};
    end

    if not modData.ZombieVariety.rolled then
        specialZombieManager:rollSpecialZombieProbability(zombie);
    end

    if modData.ZombieVariety.mustApplySpecial and not specialZombieManager:appliedSpecialZombieStats(zombie) then
        if not modData.ZombieVariety.type then
            printzv("Type not properly defined for application");
        else
            specialZombieManager:applySpecialZombieProperties(zombie, modData.ZombieVariety.type);
        end
    end

    if modData.ZombieVariety.type then
        modData.ZombieVariety.status.type = "Type " .. modData.ZombieVariety.type.name;
    end

    if modData.ZombieVariety.status then
        local statusMessage = "Status";

        --for key, value in pairs(modData.ZombieVariety.status) do
        --    statusMessage = statusMessage .. " : " .. key .. " = " .. value;
        --end

        for key, value in pairs(modData.ZombieVariety) do
            if type(value) == "table" then
                -- Do nothing for tables
            else
                statusMessage = statusMessage .. " : " .. key .. " = " .. tostring(value);
            end
        end

        zombie:addLineChatElement(statusMessage);
    end
end

Events.OnZombieUpdate.Add(ZombieUpdate.Prepare);

return ZombieUpdate;