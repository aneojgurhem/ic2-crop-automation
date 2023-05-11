local config = require("config")

-- WORKING FARM SLOT MAP
--  _________________
-- |06 07 18 19 30 31|
-- |05 08 17 20 29 32|
-- |04 09 16 21 28 33|
-- |03 10 15 22 27 34|
-- |02 11 14 23 26 35|
-- |01 12 13 24 25 36|
--  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

local function posToSlot(farmSize, pos)
    local Row

    if pos[1] % 2 == 1 then
        Row = farmSize - pos[2] + 1
    else
        Row = pos[2]
    end

    return (-pos[1])*farmSize + Row
end


local function slotToPos(farmSize, slot)
    local x = (slot - 1) // farmSize
    local Row = (slot - 1) % farmSize
    local y

    if x % 2 == 1 then
        y = Row + 1
    else
        y = farmSize - Row
    end

    return {x, y}
end


local function globalToFarm(globalPos)
    return posToSlot(config.farmSize, globalPos)
end


local function farmToGlobal(farmSlot)
    return slotToPos(config.farmSize, farmSlot)
end


local function globalToStorage(globalPos)
    return posToSlot(config.storageFarmSize, {-globalPos[1], globalPos[2]})
end


local function storageToGlobal(storageSlot)
    local globalPos = slotToPos(config.storageFarmSize, storageSlot)
    globalPos[1] = -globalPos[1];
    return globalPos
end


local function multifarmPosInFarm(pos)
    local absX = math.abs(pos[1])
    local absY = math.abs(pos[2])
    return (absX + absY) <= config.multifarmSize and (absX > 2 or absY > 2) and absX < config.multifarmSize-1 and absY < config.multifarmSize-1
end


local function globalPosToMultifarmPos(pos)
    return {pos[1]-config.multifarmCentorOffset[1], pos[2]-config.multifarmCentorOffset[2]}
end


local function multifarmPosToGlobalPos(pos)
    return {pos[1]+config.multifarmCentorOffset[1], pos[2]+config.multifarmCentorOffset[2]}
end


local function multifarmPosIsRelayFarmland(pos)
    for i = 1, #config.multifarmRelayFarmlandPoses do
        local rPos = config.multifarmRelayFarmlandPoses[i]
        if rPos[1] == pos[1] and rPos[2] == pos[2] then
            return true
        end
    end
    return false
end


local function nextRelayFarmland(pos)
    if pos == nil then
        return config.multifarmRelayFarmlandPoses[1]
    end
    for i = 1, #config.multifarmRelayFarmlandPoses do
        local rPos = config.multifarmRelayFarmlandPoses[i]
        if rPos[1] == pos[1] and rPos[2] == pos[2] and i < #config.multifarmRelayFarmlandPoses then
            return config.multifarmRelayFarmlandPoses[i+1]
        end
    end
end


local function findOptimalDislocator(pos)
    local minDistance = 100
    local minPosI
    for i = 1, #config.multifarmDislocatorPoses do
        local rPos = config.multifarmDislocatorPoses[i]
        local distance = math.max(math.abs(pos[1] - rPos[1]), math.abs(pos[2] - rPos[2]))
        if distance < minDistance then
            minDistance = distance
            minPosI = i
        end
    end
    return {multifarmPosToGlobalPos(config.multifarmDislocatorPoses[minPosI]),
            multifarmPosToGlobalPos(config.multifarmRelayFarmlandPoses[minPosI])}
end


return {
    globalToFarm = globalToFarm,
    farmToGlobal = farmToGlobal,
    globalToStorage = globalToStorage,
    storageToGlobal = storageToGlobal,
    multifarmPosInFarm = multifarmPosInFarm,
    multifarmPosIsRelayFarmland = multifarmPosIsRelayFarmland,
    globalPosToMultifarmPos = globalPosToMultifarmPos,
    multifarmPosToGlobalPos = multifarmPosToGlobalPos,
    findOptimalDislocator = findOptimalDislocator,
    nextRelayFarmland = nextRelayFarmland
}