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

        local cropInfo = scanner.scan()
        if cropInfo.name == 'air' then
            cropInfo.tier = 0
            cropInfo.gr = 0
            cropInfo.ga = 0
            cropInfo.re = 100
            farm[slot] = cropInfo
        elseif cropInfo.isCrop then
            farm[slot] = cropInfo
        end
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


local function scanStorage()
    gps.save()
    for slot=1, config.storageFarmArea do
        gps.go(posUtil.storageSlotToPos(slot))
        local cropInfo = scanner.scan()
        if cropInfo.name ~= 'air' then
            storage[slot] = cropInfo
            reverseStorage[cropInfo.name] = slot
        else
            break
        end
    end
    gps.resume()
end


local function existInStorage(crop)
    if reverseStorage[crop.name] then
        return true
    else
        return false
    end
end


local function notWater(slot)
    if (slot == 21) or (slot == 25) or (slot == 57) or (slot == 61) then
        return false
    else
        return true
    end
end


local function nextStorageSlot()
    if notWater(#storage + 1) then
        return #storage + 1
    else
        return #storage + 2
    end
end


return {
    getFarm = getFarm,
    updateFarm = updateFarm,
    scanFarm = scanFarm,
    getStorage = getStorage,
    resetStorage = resetStorage,
    addToStorage = addToStorage,
    scanStorage = scanStorage,
    existInStorage = existInStorage,
    notWater = notWater,
    nextStorageSlot = nextStorageSlot
}