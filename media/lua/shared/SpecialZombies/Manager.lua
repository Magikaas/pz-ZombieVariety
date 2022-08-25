local Manager = {
    types = {},                             -- List of all special zombie types and their probabilities+stats
    totalWeights = 0,                       -- Total weight, for use in rolling for special zombie type
    specialZombieProbability = 1,           -- Probability of a zombie being a special zombie
    specialZombieProbabilityRollMax = 100   -- Max roll for zombie probability roll
};

function Manager:getTotalWeights()
    local totalWeights = 0;
    local i = 0;
    for k in pairs(self.types) do
        totalWeights = totalWeights + self.types[k].weight;
        i = i + 1;
    end
    return totalWeights;
end

function Manager:getRandomSpecialZombieType()
    -- Once we have a decent enough base of weights, remove the BaseZombie zombie
    -- We don't need it to pad the numbers anymore
    if self.totalWeights > 99 then
        self:removeType("BaseZombie");
    end

    local roll = ZombRand(0, self.totalWeights);
    local counter = 0;

    for type, typeObject in pairs(self.types) do
        counter = counter + typeObject.weight;

        if counter > roll then
            return typeObject;
        end
    end
    return false;
end

function Manager:getSpecialZombieType(typeName)
    if self.types[typeName] then
        return self.types[typeName];
    else
        return nil;
    end
end

function Manager:removeType(type)
    table.remove(self.types, type);
    self.totalWeights = self:getTotalWeights();
end

function Manager:hasType(name)
    return not not self.types[name];
end

function Manager:addSpecialZombieType(definition)
    self.types[definition.name] = definition;

    self:sortWeights();
    self:fixWeights();
end

function Manager:importSpecialZombieStatsByType(name)
    local zombieTypeDefinition = require("SpecialZombies/Definition/" .. name);

    self:addSpecialZombieType(zombieTypeDefinition);

    --printzv("Imported type " .. name);
end

function Manager:sortWeights()
    self.types = table.sort(self.types, function (a, b) return a.weight > b.weight end);
end

function Manager:fixWeights()
    self.totalWeights = self:getTotalWeights();
end

function Manager:appliedSpecialZombieStats(zombie)
    local modData = zombie:getModData();
    if not modData.ZombieVariety then
        modData.ZombieVariety = {};
        modData.ZombieVariety.status = {};
        modData.ZombieVariety.status.zombiestats = "Zombiestats no";
        return false;
    end

    if not modData.ZombieVariety.applied then
        modData.ZombieVariety.status.applied = "Not applied";
        return false;
    end
    return modData.ZombieVariety and modData.ZombieVariety.applied;
end

function Manager:applySpecialZombieProperties(zombie, type)
    local modData = zombie:getModData();

    self:applySpecialZombieStats(zombie, type);
    self:applySpecialZombieOutfit(zombie, type);

    modData.ZombieVariety.status.zombiestats = "Zombiestats applied";

    modData.ZombieVariety.applied = true;
end

function Manager:applySpecialZombieStats(zombie, type)
    local specialZombieType = type;

    local modData = zombie:getModData();
    local zombieStats = specialZombieType.stats;

    zombie:setWalkType(zombieStats.speed);
    zombie:setHealth(zombieStats.health);

    printzv("Applied special zombie stats");

    return;
end

function Manager:applySpecialZombieOutfit(zombie, type)
    zombie:setDressInRandomOutfit(false);
    zombie:dressInNamedOutfit("Spiffo");
    zombie:resetModelNextFrame();
end

function Manager:rollSpecialZombieProbability(zombie)
    local modData = zombie:getModData();
    local roll = ZombRand(0, self.specialZombieProbabilityRollMax);
    local minRoll = self.specialZombieProbabilityRollMax * self.specialZombieProbability;
    modData.ZombieVariety.rolled = true;
    if roll < minRoll then
        modData.ZombieVariety.mustApplySpecial = true;
    else
        modData.ZombieVariety.mustApplySpecial = false;
        modData.ZombieVariety.type = self:getSpecialZombieType("Basic");
        return;
    end

    local specialZombieType = self:getRandomSpecialZombieType();
    modData.ZombieVariety.type = specialZombieType;

    modData.ZombieVariety.status.specialRoll = "Special Roll " .. roll;

    printzv("Set zombie type to " .. specialZombieType.name);
end

return Manager;