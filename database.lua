local gps = require("gps")
local posUtil = require("posUtil")
local action = require("action")
local scanner = require("scanner")
local config = require("config")
local storage = {}
local reverseStorage = {}
local farm = {}
local lastMultifarmPos = {0, 0}


local function getStorage()
    return storage
end


local function getFarm()
    return farm
end


local function getLastMultifarmPos()
    return lastMultifarmPos
end


local function setLastMultifarmPos(pos)
    lastMultifarmPos = pos
end


local function scanFarm()
    for slot=1, config.workingFarmArea, 2 do
        gps.go(posUtil.farmToGlobal(slot))
        local cropInfo = scanner.scan()
        if cropInfo.name == "air" then
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
end


local function scanStorage()
    gps.save()
    for slot=1, config.storageFarmArea do
        gps.go(posUtil.storageToGlobal(slot))
        local cropInfo = scanner.scan()
        if cropInfo.name ~= "air" then
            storage[slot] = cropInfo
            reverseStorage[cropInfo.name] = slot
        else
            break
        end
    end
    gps.resume()
end


local function resetStorage()
    storage = {}
end


local function addToStorage(crop)
    storage[#storage+1] = crop
    reverseStorage[crop.name] = #storage
end


local function updateFarm(slot, crop)
    farm[slot] = crop
end


local function nextMultifarmPos()
    local x = lastMultifarmPos[1]
    local y = lastMultifarmPos[2]

    if posUtil.multifarmPosIsRelayFarmland(lastMultifarmPos) then
        return posUtil.nextRelayFarmland(lastMultifarmPos)
    end

    local d = math.abs(x) + math.abs(y)
    local nextPossiblePos

    if x == 0 and y == 0 then
        nextPossiblePos = {0, 4}
    elseif x == -1 and y == d - 1 then
        if d == config.multifarmSize then
            return posUtil.nextRelayFarmland()
        else
            nextPossiblePos = {0, d+1}
        end
    elseif x >= 0 and y > 0 then
        nextPossiblePos = {x+1, y-1}
    elseif x > 0 and y <= 0 then
        nextPossiblePos = {x-1, y-1}
    elseif x <= 0 and y < 0 then
        nextPossiblePos = {x-1, y+1}
    elseif x < 0 and y >= 0 then
        nextPossiblePos = {x+1, y+1}
    end

    if posUtil.multifarmPosIsRelayFarmland(nextPossiblePos) or not posUtil.multifarmPosInFarm(nextPossiblePos) then
        lastMultifarmPos = nextPossiblePos
        return nextMultifarmPos()
    else
        return nextPossiblePos
    end
end


local function updateMultifarm(pos)
    lastMultifarmPos = pos
end


local function scanMultifarm()
    gps.save()
    gps.go(config.elevatorPos)
    gps.down(3)
    while true do
        local nextPos = nextMultifarmPos()
        local nextGlobalPos = posUtil.multifarmPosToGlobalPos(nextPos)
        gps.go(nextGlobalPos)
        local cropInfo = scanner.scan()
        if cropInfo.name == "air" then
            break
        else
            updateMultifarm(nextPos)
        end
    end
    gps.go(config.elevatorPos)
    gps.up(3)
    gps.resume()
end


local function existInStorage(crop)
    if reverseStorage[crop.name] then
        return true
    else
        return false
    end
end


local function nextStorageSlot()
    return #storage+1
end


return {
    getStorage = getStorage,
    getFarm = getFarm,
    getLastMultifarmPos = getLastMultifarmPos,
    setLastMultifarmPos = setLastMultifarmPos,
    scanFarm = scanFarm,
    scanStorage = scanStorage,
    resetStorage = resetStorage,
    scanMultifarm = scanMultifarm,
    existInStorage = existInStorage,
    nextStorageSlot = nextStorageSlot,
    addToStorage = addToStorage,
    updateFarm = updateFarm,
    nextMultifarmPos = nextMultifarmPos,
    updateMultifarm = updateMultifarm
}