local gps = require('gps')
local action = require('action')
local database = require('database')
local scanner = require('scanner')
local posUtil = require('posUtil')
local config = require('config')
local breedRound = 0
local lowestTier
local lowestTierSlot
local lowestStat
local lowestStatSlot

-- ==================== HANDLING TIERS ======================

local function updateLowest()
    local farm = database.getFarm()
    lowestTier = 99
    lowestTierSlot = 0
    lowestStat = 99
    lowestStatSlot = 0

    -- Find lowest tier slot
    for slot=1, config.workingFarmArea, 2 do
        local crop = farm[slot]
        if crop.isCrop then

            if crop.name == 'air' or crop.name == 'emptyCrop' then
                lowestTier = 0
                lowestTierSlot = slot
                break

            elseif crop.tier < lowestTier then
                lowestTier = crop.tier
                lowestTierSlot = slot
            end
        end
    end

    -- Find lowest stat slot amongst the lowest tier
    if config.statWhileTiering then
        for slot=1, config.workingFarmArea, 2 do
            local crop = farm[slot]
            if crop.isCrop then

                if crop.name == 'air' or crop.name == 'emptyCrop' then
                    lowestStat = 0
                    lowestStatSlot = slot
                    break

                elseif crop.tier == lowestTier then
                    local stat = crop.gr + crop.ga - crop.re
                    if stat < lowestStat then
                        lowestStat = stat
                        lowestStatSlot = slot
                    end
                end
            end
        end
    end
end

-- ===================== SCANNING ======================

local function isWeed(crop)
    return crop.name == 'weed' or
        crop.name == 'Grass' or
        crop.gr > config.workingMaxGrowth or
        crop.re > config.workingMaxResistance or
        (crop.name == 'venomilia' and crop.gr > 7)
end


local function checkChild(slot, crop)
    if crop.isCrop and crop.name ~= 'emptyCrop' then

        if crop.name == 'air' then
            action.placeCropStick(2)

        elseif isWeed(crop) then
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

            -- Not higher tier, stat up working farm
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
    if crop.isCrop and crop.name ~= 'air' and crop.name ~= 'emptyCrop' then
        if isWeed(crop) then
            action.deweed()
            database.updateFarm(slot, {isCrop=true, name='emptyCrop'})
            updateLowest()
        end
    end
end

-- =============== DICTIONNARY ======================

local function dictToString(d)
    s = ""
    for k, v in pairs(d) do
        s = s..k..toString(v)
    end
    return s
end

-- =================== TIERING ======================

local function tierOnce()
    for slot=1, config.workingFarmArea, 1 do

        -- Terminal Condition
        if breedRound > config.maxBreedRound then
            print('autoTier: Max Breeding Round Reached!')
            return false
        end

        -- Terminal Condition
        if #database.getStorage() >= config.storageFarmArea then
            print('autoTier: Storage Full!')
            return false
        end

        -- Terminal Condition
        if lowestTier >= config.autoTierThreshold then
            print('autoTier: Minimum Tier Threshold Reached!')
            return false
        end

        -- Scan
        gps.go(posUtil.workingSlotToPos(slot))
        local crop = scanner.scan()
        print(breedRound, slot, dictToString(crop))

        if slot % 2 == 0 then
            checkChild(slot, crop)
        else
            checkParent(slot, crop)
        end

        if action.needCharge() then
            action.charge()
        end
    end
    return true
end

-- ====================== MAIN ======================

local function init()
    database.resetStorage()
    database.scanFarm()
    action.restockAll()
    updateLowest()

    print(string.format('autoTier: Target Tier %s', config.autoTierThreshold))
end


local function main()
    init()

    -- Loop
    while tierOnce() do
        breedRound = breedRound + 1
        action.restockAll()
    end

    -- Finish
    if config.cleanUp then
        action.cleanUp()
    end

    print('autoTier: Complete!')
end

main()