local robot = require('robot')
local database = require('database')
local gps = require('gps')
local posUtil = require('posUtil')
local scanner = require('scanner')
local action = require('action')
local config = require('config')
local emptySlot
local targetCrop

-- ================== HANDLING SPREAD ====================

local function FindEmpty()
    local farm = database.getFarm()

    for slot=1, config.workingFarmArea, 2 do
        local crop = farm[slot]
        if crop == 'empty' then
            emptySlot = slot
            return true
        end
    end
    return false
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
            if stat >= config.autoSpreadThreshold then

                -- Make sure no parent on the working farm is empty
                if FindEmpty() then
                    action.transplant(posUtil.workingSlotToPos(slot), posUtil.workingSlotToPos(emptySlot))
                    action.placeCropStick(2)
                    database.updateFarm(emptySlot, crop)

                -- No parent is empty, put in storage
                else
                    action.transplant(posUtil.workingSlotToPos(slot), posUtil.storageSlotToPos(database.nextStorageSlot()))
                    database.addToStorage(crop)
                    action.placeCropStick(2)
                end
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
    if crop.name == 'air' then
        database.updateFarm(slot, 'empty')

    elseif crop.isCrop and isWeed(crop) then
        action.deweed()
        database.updateFarm(slot, 'empty')
    end
end

-- ====================== SPREADING ======================

local function spreadOnce()
    for slot=1, config.workingFarmArea, 1 do

        -- Terminal Condition
        if #database.getStorage() >= config.storageFarmArea then
            print('Storage Full!')
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
    database.resetStorage()
    database.scanFarm()

    targetCrop = database.getFarm()[1].name
    print(string.format('Target Crop Recognized: %s', targetCrop))
end


local function main()
    init()

    -- Loop
    while not spreadOnce() do
        action.restockAll()
    end

    -- Finish
    if config.cleanUp then
        action.cleanUp()
    end

    print('autoSpread Complete!')
end

main()