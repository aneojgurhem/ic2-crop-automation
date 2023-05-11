local robot = require("robot")
local gps = require("gps")
local action = require("action")
local database = require("database")
local scanner = require("scanner")
local posUtil = require("posUtil")
local config = require("config")
local args = {...}
local lowestStat
local lowestStatSlot
local targetCrop

-- ==================== HANDLING STATS ======================

local function updateLowest()
    lowestStat = 64
    lowestStatSlot = 0
    local farm = database.getFarm()

    for slot=1, config.workingFarmArea, 2 do
        local crop = farm[slot]

        if crop ~= nil then
            if crop.name == 'crop' then
                lowestStatSlot = slot
                break
            else
                local stat = crop.gr + crop.ga - crop.re
                if stat < lowestStat then
                    lowestStat = stat
                    lowestStatSlot = slot
                end
            end
        end
    end
end


local function findSuitableFarmSlot(crop)
    if crop.gr + crop.ga - crop.re > lowestStat then
        return lowestStatSlot
    else
        return 0
    end
end

-- ====================== SCANNING ======================

local function isWeed(crop)
    return crop.name == "weed" or
        crop.name == "Grass" or
        crop.gr > 21 or
        (crop.name == "venomilia" and crop.gr > 7)
end


local function checkChildren(slot, crop)
    if crop.name == "air" then
        action.placeCropStick(2)

    elseif (not config.assumeNoBareStick) and crop.name == "crop" then
        action.placeCropStick()

    elseif crop.isCrop then
        if isWeed(crop) then
            action.deweed()
            action.placeCropStick()

        elseif crop.name == targetCrop then
            local suitableSlot = findSuitableFarmSlot(crop)
            if suitableSlot == 0 then
                action.deweed()
                action.placeCropStick()
            else
                action.transplant(posUtil.farmToGlobal(slot), posUtil.farmToGlobal(suitableSlot))
                action.placeCropStick(2)
                database.updateFarm(suitableSlot, crop)
                updateLowest()
            end

        elseif config.keepMutations and (not database.existInStorage(crop)) then
            action.transplant(posUtil.farmToGlobal(slot), posUtil.storageToGlobal(database.nextStorageSlot()))
            action.placeCropStick(2)
            database.addToStorage(crop)

        else
            action.deweed()
            action.placeCropStick()
        end
    end
end


local function checkParent(slot, crop)
    if crop.name == "air" then
        database.updateFarm(slot, 'crop')
        updateLowest()

    elseif crop.isCrop and isWeed(crop) then
        action.deweed()
        database.updateFarm(slot, 'crop')
        updateLowest()
    end
end

-- ====================== STATTING ======================

local function statOnce()
    for slot=1, config.workingFarmArea, 1 do

        -- Terminal Condition
        if lowestStat == config.autoStatThreshold then
            action.restockAll()
            print('Minimum Stat Threshold Reached!')
            return true
        end

        -- Scan
        gps.go(posUtil.farmToGlobal(slot))
        local crop = scanner.scan()

        if slot % 2 == 0 then
            checkChildren(slot, crop)
        else
            checkParent(slot, crop)
        end

        if action.needCharge() then
            action.charge()
        end
    end
    return false
end

-- ======================== MAIN ========================

local function init()
    print('Beginning Initial Scan')
    database.scanFarm()
    database.scanStorage()
    updateLowest()
    targetCrop = database.getFarm()[1].name
    print(string.format('Target Crop Recognized: %s', targetCrop))
end


local function main()
    init()

    -- Loop+
    while not statOnce() do
        gps.go({0,0})
        action.restockAll()
    end

    -- Finish
    gps.go({0,0})
    if #args == 0 then
        action.cleanup()
        gps.go({0,0})
    end
    
    gps.turnTo(1)
    print('autoStat Complete!')
end

main()