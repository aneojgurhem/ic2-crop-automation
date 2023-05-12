local robot = require('robot')
local gps = require('gps')
local action = require('action')
local database = require('database')
local scanner = require('scanner')
local posUtil = require('posUtil')
local config = require('config')
local lowestTier
local lowestTierSlot
local lowestStat
local lowestStatSlot
local breedRound

-- ==================== HANDLING TIERS ======================

local function updateLowest()
    lowestTier = 64
    lowestTierSlot = 0
    lowestStat = 64
    lowestStatSlot = 0
    local farm = database.getFarm()

    -- Find lowest tier slot.
    for slot=1, config.workingFarmArea, 2 do
        local crop = farm[slot]
        if crop == nil then
            lowestTierSlot = slot
            lowestStatSlot = slot
            return
        end

        if crop.tier < lowestTier then
            lowestTier = crop.tier
            lowestTierSlot = slot
        end
    end


    -- Find lowest stats slot amongst the lowest tier crops
    if config.statWhileTiering then
        for slot=1, config.workingFarmArea, 2 do
            local crop = farm[slot]
            if (crop ~= nil and crop.tier == lowestTier) then
                local stat = crop.gr + crop.ga - crop.re
                if stat < lowestStat then
                    lowestStat = stat
                    lowestStatSlot = slot
                end
            end
        end
    end
end

-- ===================== SCANNING ======================

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

        -- Seen before, tier up working farm
        elseif database.existInStorage(crop) then
            local stat = crop.gr + crop.ga - crop.re

            if crop.tier > lowestTier then
                action.transplant(posUtil.workingSlotToPos(slot), posUtil.workingSlotToPos(lowestTierSlot))
                action.placeCropStick(2)
                database.updateFarm(lowestTierSlot, crop)
                updateLowest()
 
            elseif (config.statWhileTiering and crop.tier == lowestTier and stat > lowestStat) then
                action.transplant(posUtil.workingSlotToPos(slot), posUtil.workingSlotToPos(lowestStatSlot))
                action.placeCropStick(2)
                database.updateFarm(lowestStatSlot, crop)
                updateLowest()

            else
                action.deweed()
                action.placeCropStick()
            end

        -- Not seen before, move to storage
        else
            action.transplant(posUtil.workingSlotToPos(slot), posUtil.storageSlotToPos(database.nextStorageSlot()))
            action.placeCropStick(2)
            database.addToStorage(crop)
        end
    end
end


local function checkParent(slot, crop)
    if crop.isCrop and isWeed(crop) then
        action.deweed()
        database.updateFarm(slot, nil)
        updateLowest()
    end
end

-- =================== TIERING ======================

local function tierOnce()
    for slot=1, config.workingFarmArea, 1 do

        -- Terminal Condition
        breedRound = breedRound + 1
        if (config.maxBreedRound and breedRound > config.maxBreedRound) then
            print('Max Round Reached!')
            return true
        end

        -- Terminal Condition
        if #database.getStorage() >= config.storageFarmArea then
            print('Storage Full!')
            return true
        end

        -- Scan
        gps.go(posUtil.workingSlotToPos(slot))
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

-- ====================== MAIN ======================

local function init()
    print('Beginning Initial Scan')
    database.resetStorage()
    database.scanFarm()
    updateLowest()

    action.restockAll()
    breedRound = 0
end


local function main()
    init()

    -- Loop
    while not tierOnce() do
        action.restockAll()
    end

    -- Finish
    if config.cleanUp then
        action.cleanUp()
    end

    print('autoTier Complete!')
end

main()