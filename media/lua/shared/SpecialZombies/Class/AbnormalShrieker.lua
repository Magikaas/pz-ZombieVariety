local specialZombieManager = require "SpecialZombies/Manager";

ABNORMALSHRIEKER_COOLDOWN = 20;
ABNORMALSHRIEKER_DEBUG = true;

local AbnormalShrieker = require("SpecialZombies/Class/Shrieker")():new("AbnormalShrieker");

function AbnormalShrieker:handleShriekLogic(zombie)
    local timestamp = os.time(os.date("!*t"));
    local modData = zombie:getModData();
    if timestamp > (modData.ZombieVariety.lastShriek + ABNORMALSHRIEKER_COOLDOWN) then
        self:makeNoise(zombie);

        printzv("Making noise for no reason!");

        modData.ZombieVariety.lastShriek = timestamp;
    end
end

function AbnormalShrieker.Update(zombie)
    local modData = zombie:getModData();

    if not AbnormalShrieker:isSpecialZombie(zombie) then
        return;
    end

    if modData.ZombieVariety then
        modData.ZombieVariety.definitionName = "AbnormalShrieker";
    end

    if not modData.ZombieVariety.lastShriek then
        local defaultShriekTimestamp = os.time(os.date("!*t"));
        modData.ZombieVariety.lastShriek = defaultShriekTimestamp - 5;
    end

    AbnormalShrieker:handleShriekLogic(zombie, modData.ZombieVariety.type.shriekTarget);
end

Events.OnZombieUpdate.Add(AbnormalShrieker.Update);

return function()
    return setmetatable({}, { __index = AbnormalShrieker });
end