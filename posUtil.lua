local config = require('config')

-- ======================== WORKING FARM ========================
--  _________________
-- |31 30 19 18 07 06|  Slot Map
-- |32 29 20 17 08 05|
-- |33 28 21 16 09 04|  One down from 01 is (0,0)
-- |34 27 22 15 10 03|
-- |35 26 23 14 11 02|
-- |36 25 24 13 12 01|
--  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

local function workingPosToSlot(pos)
    local Row

    if pos[1] % 2 == 1 then
        Row = config.workingFarmSize - pos[2] + 1
    else
        Row = pos[2]
    end

    return (-pos[1])*config.workingFarmSize + Row
end


local function workingSlotToPos(slot)
    local x = (slot - 1) // config.workingFarmSize
    local Row = (slot - 1) % config.workingFarmSize
    local y

    if x % 2 == 1 then
        y = -Row + config.workingFarmSize
    else
        y = Row + 1
    end

    return {-x, y}
end

-- ======================== STORAGE FARM ========================
--  __________________________
-- |09 10 27 28 45 46 63 64 81|  Slot Map
-- |08 11 26 29 44 47 62 65 80|
-- |07 12 25 30 43 48 61 66 79|  Two Left from 03 is (0,0)
-- |06 13 24 31 42 49 60 67 78|
-- |05 14 23 32 41 50 59 68 77|
-- |04 15 22 33 40 51 58 69 76|
-- |03 16 21 34 39 52 57 70 75|
-- |02 17 20 35 38 53 56 71 74|
-- |01 18 19 36 37 54 55 72 73|
--  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

local function storagePosToSlot(pos)
    local Row

    if pos[1] % 2 == 1 then
        Row = config.storageFarmSize - pos[2] + 1
    else
        Row = pos[2]
    end

    return (-pos[1])*config.storageFarmSize + Row
end


local function storageSlotToPos(slot)
    local x = (slot - 1) // config.storageFarmSize + 2
    local Row = (slot - 1) % config.storageFarmSize
    local y

    if x % 2 == 1 then
        y = -Row + config.storageFarmSize - 3
    else
        y = Row - 2
    end

    return {x, y}
end

-- ========================= MULTI FARM =========================

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
    workingPosToSlot = workingPosToSlot,
    workingSlotToPos = workingSlotToPos,
    storagePosToSlot = storagePosToSlot,
    storageSlotToPos = storageSlotToPos,
    multifarmPosInFarm = multifarmPosInFarm,
    multifarmPosIsRelayFarmland = multifarmPosIsRelayFarmland,
    globalPosToMultifarmPos = globalPosToMultifarmPos,
    multifarmPosToGlobalPos = multifarmPosToGlobalPos,
    findOptimalDislocator = findOptimalDislocator,
    nextRelayFarmland = nextRelayFarmland
}