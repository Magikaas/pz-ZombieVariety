local specialZombieManager = require "SpecialZombies/Manager";

local SpecialZombie = BaseZombie;

function SpecialZombie:isSpecialZombie(zombie)
    local modData = zombie:getModData();
    if not specialZombieManager:appliedSpecialZombieStats(zombie) then
        modData.ZombieVariety.statsApplied = false;
        return false;
    end

    return modData.ZombieVariety.type.name == self.definitionName;
end

function SpecialZombie:getSpecialZombieType(zombie)
    local modData = zombie:getModData();

    if not self:isSpecialZombie(zombie) then
        return "Normal";
    end

    return modData.ZombieVariety.type.name;
end

return function()
    return setmetatable({}, { __index = SpecialZombie });
end