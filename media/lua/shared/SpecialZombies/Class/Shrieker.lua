local specialZombieManager = require "SpecialZombies/Manager";

-- Must load after the ZombieUpdater, to make sure some fields are set
require "SpecialZombies/ZombieUpdate";

SHRIEKER_COOLDOWN = 10;
SHRIEKER_DEBUG = true;
SHRIEKER_CHASE_DISTANCE = 2;

--Shrieker = SpecialZombie:new("Shrieker");
local Shrieker = require("SpecialZombies/Class/SpecialZombie")():new("Shrieker");

function Shrieker:handleShriekLogic(zombie, targetType)
    local target = zombie:getTarget();
    local modData = zombie:getModData();
    local timestamp = os.time(os.date("!*t"));

    if modData.ZombieVariety.shrieking then
        -- Make silent 'noise' for the next SHRIEKER_COOLDOWN * 4 seconds
        if  timestamp > (modData.ZombieVariety.lastShriek + (SHRIEKER_COOLDOWN *1.5)) or
                timestamp > (modData.ZombieVariety.lastShriek + (SHRIEKER_COOLDOWN *2)) or
                timestamp > (modData.ZombieVariety.lastShriek + (SHRIEKER_COOLDOWN *2.5)) or
                timestamp > (modData.ZombieVariety.lastShriek + (SHRIEKER_COOLDOWN *3)) or
                timestamp > (modData.ZombieVariety.lastShriek + (SHRIEKER_COOLDOWN *3.5)) or
                timestamp > (modData.ZombieVariety.lastShriek + (SHRIEKER_COOLDOWN *4)) then
            self:makeNoise(zombie, false);

            if timestamp > (modData.ZombieVariety.lastShriek + SHRIEKER_COOLDOWN *4) then
                modData.ZombieVariety.shrieking = false;
            end
        end
    end

    if not target then
        return;
    end

    if instanceof(target, targetType) then
        if timestamp > (modData.ZombieVariety.lastShriek + SHRIEKER_COOLDOWN) then
            self:makeNoise(zombie, true);

            modData.ZombieVariety.lastShriek = timestamp;
            modData.ZombieVariety.shrieking = true;
        end
    end
end

function Shrieker.Update(zombie)
    local modData = zombie:getModData();

    if not Shrieker:isSpecialZombie(zombie) then
        modData.ZombieVariety.isSpecial = false;
        return;
    else
        modData.ZombieVariety.isSpecial = true;
    end

    if modData.ZombieVariety then
        modData.ZombieVariety.definitionName = "Shrieker";
    end

    local timestamp = os.time(os.date("!*t"));
    if not modData.ZombieVariety.lastShriek then
        modData.ZombieVariety.lastShriek = timestamp - 5;
    end

    Shrieker:handleShriekLogic(zombie, modData.ZombieVariety.type.shriekTarget);

    local target = zombie:getTarget();

    -- We don't want the shrieker attacking, just chasing the players, so it should clear its target
    if instanceof(target, modData.ZombieVariety.type.shriekTarget) then
        local distance = IsoUtils.DistanceManhatten(zombie:getX() + .0, zombie:getY() + .0, target:getX() + .0, target:getY() + .0);

        --zombie:addLineChatElement("I'm here! " .. distance);

        if distance < SHRIEKER_CHASE_DISTANCE then
            printzv("I'm close enough to " .. target:getUsername() .. "! (" .. distance .. ")");
            modData.ZombieVariety.myTarget = target;
            modData.ZombieVariety.clearedTargetTimestamp = timestamp;
            zombie:setTarget(nil);
        end
    end

    -- And then reacquire the previous target after 2 seconds, if it's far away enough
    if not target and modData.ZombieVariety.myTarget then
        if timestamp > modData.ZombieVariety.clearedTargetTimestamp + 2 then
            zombie:setTarget(modData.ZombieVariety.myTarget);

            local zombieStats = modData.ZombieVariety.type.stats;
            zombie:setWalkType(zombieStats.speed);
            modData.ZombieVariety.myTarget = nil;
        end
    end
end

Events.OnZombieUpdate.Add(Shrieker.Update);

return function()
    return setmetatable({}, { __index = Shrieker });
end