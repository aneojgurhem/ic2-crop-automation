local robot = require('robot')
local gps = require('gps')
local action = require('action')
local database = require('database')
local scanner = require('scanner')
local posUtil = require('posUtil')
local config = require('config')
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

-- ====================== SCANNING ======================

local function isWeed(crop)
    return crop.name == 'weed' or
        crop.name == 'Grass' or
        crop.gr > 21 or
        (crop.name == 'venomilia' and crop.gr > 7)
end


local function checkChildren(slot, crop)
    if crop.name == 'air' then
        action.placeCropStick(2)

    elseif (not config.assumeNoBareStick) and crop.name == 'crop' then
        action.placeCropStick()

    elseif crop.isCrop then
        if isWeed(crop) then
            action.deweed()
            action.placeCropStick()

        elseif crop.name == targetCrop then
            local stat = crop.gr + crop.ga - crop.re

            if stat > lowestStat then
                action.transplant(posUtil.workingSlotToPos(slot), posUtil.workingSlotToPos(lowestStatSlot))
                action.placeCropStick(2)
                database.updateFarm(lowestStatSlot, crop)
                updateLowest()

            else
                action.deweed()
                action.placeCropStick()
            end

        elseif config.keepMutations and (not database.existInStorage(crop)) then
            action.transplant(posUtil.workingSlotToPos(slot), posUtil.storageSlotToPos(database.nextStorageSlot()))
            action.placeCropStick(2)
            database.addToStorage(crop)

        else
            action.deweed()
            action.placeCropStick()
        end
    end
end


local function checkParent(slot, crop)
    if crop.isCrop and isWeed(crop) then
        action.deweed()
        database.updateFarm(slot, 'crop')
        updateLowest()
    end
end

-- ====================== STATTING ======================

local function statOnce()
    for slot=1, config.workingFarmArea, 1 do

        -- Terminal Condition
        if lowestStat >= config.autoStatThreshold then
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
    updateLowest()

    targetCrop = database.getFarm()[1].name
    print(string.format('Target Crop Recognized: %s', targetCrop))
end


local function main()
    init()

    -- Loop
    while not statOnce() do
        action.restockAll()
    end

    -- Finish
    if config.cleanUp then
        action.cleanUp()
    end

    print('autoStat Complete!')
end

main()