local specialZombieManager = require "SpecialZombies/Manager";

-- Must load after the ZombieUpdater, to make sure some fields are set
require "SpecialZombies/ZombieUpdate";
require "Globals";

BaseZombie = {
    name = "BaseZombie",
    definition = require("BaseZombie"),
    definitionName = "BaseZombie",
    soundSettings = {
        group = "Default",
        length = 5
    },
    definitionName = "Basic"
}

function BaseZombie:getSoundGroup(zombie)
    local modData = zombie:getModData();
    local type = modData.ZombieVariety.type;

    return type.soundGroup;
end

function BaseZombie:makeNoise(zombie, playSound)
    if zombie:isDead() then
        return;
    end
    addSound(nil, zombie:getX(), zombie:getY(), zombie:getZ(), 250, 250);
    if playSound then
        local soundGroup = self:getSoundGroup(zombie);
        local timestamp = os.time(os.date("!*t"));
        if not SoundStarted[soundGroup.group] or SoundStarted[soundGroup.group] < (timestamp - soundGroup.length) then
            local emitter = zombie:getEmitter();
            if not emitter then
                return;
            end

            emitter:playSound(self:getSound(), zombie);
            SoundStarted[soundGroup.group] = timestamp;
        end
    end
end

function BaseZombie:getSound()
    if not self.definition or not self.definition.sound then
        return "";
    end
    return self.definition.sound;
end

function BaseZombie:new(type, skipImport)
    local o = {};
    setmetatable(o, self);
    self.__index = self;
    local definition = require("SpecialZombies/Definition/" .. type);
    o.name = type;
    o.definition = definition;
    o.definitionName = type;
    o.soundGroup = definition.soundGroup;

    if not skipImport then
        if definition.enabled and not specialZombieManager:hasType(type) then
            specialZombieManager:importSpecialZombieStatsByType(type);
        end
    end

    return o;
end