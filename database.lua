local gps = require('gps')
local posUtil = require('posUtil')
local action = require('action')
local scanner = require('scanner')
local config = require('config')
local storage = {}
local reverseStorage = {}
local farm = {}

-- ======================== WORKING FARM ========================

local function getFarm()
    return farm
end


local function updateFarm(slot, crop)
    farm[slot] = crop
end


local function scanFarm()
    gps.save()
    for slot=1, config.workingFarmArea, 2 do
        gps.go(posUtil.workingSlotToPos(slot))
        local crop = scanner.scan()
            farm[slot] = crop
    end
    action.restockAll()
    gps.resume()
end

-- ======================== STORAGE FARM ========================

local function getStorage()
    return storage
end


local function resetStorage()
    storage = {}
end


local function addToStorage(crop)
    storage[#storage+1] = crop
    reverseStorage[crop.name] = #storage
end


local function existInStorage(crop)
    if reverseStorage[crop.name] then
        return true
    else
        return false
    end
end


local function water(slot)
    if config.storageFarmSize == 7 then
        if (slot == 17) or (slot == 19) or (slot == 31) or (slot == 33) then
            return true
        else
            return false
        end

    elseif config.storageFarmSize == 9 then
        if (slot == 21) or (slot == 25) or (slot == 57) or (slot == 61) then
            return true
        else
            return false
        end

    elseif config.storageFarmSize == 11 then
        if (slot == 25) or (slot == 31) or (slot == 91) or (slot == 97) then
            return true
        else
            return false
        end

    elseif config.storageFarmSize == 13 then
        if (slot == 29) or (slot == 33) or (slot == 37) or (slot == 61)
        or (slot == 81) or (slot == 85) or (slot == 89) or (slot == 133)
        or (slot == 133) or (slot == 137) then
            return true
        else
            return false
        end
    end
end


local function nextStorageSlot()
    if water(#storage + 1) then
        return #storage + 2
    else
        return #storage + 1
    end
end


return {
    getFarm = getFarm,
    updateFarm = updateFarm,
    scanFarm = scanFarm,
    getStorage = getStorage,
    resetStorage = resetStorage,
    addToStorage = addToStorage,
    existInStorage = existInStorage,
    notWater = water,
    nextStorageSlot = nextStorageSlot
}