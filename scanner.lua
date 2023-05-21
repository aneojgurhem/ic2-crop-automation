local component = require('component')
local sides = require('sides')
local config = require('config')
local geolyzer = component.geolyzer


local function scan()
    local rawResult = geolyzer.analyze(sides.down)

    -- AIR
    if rawResult.name == 'minecraft:air' or rawResult.name == 'GalacticraftCore:tile.brightAir' then
        return {isCrop=true, name='air'}

    elseif rawResult.name == 'IC2:blockCrop' then

        -- EMPTY CROP STICK
        if rawResult['crop:name'] == nil then
            return {isCrop=true, name='emptyCrop'}

        -- FILLED CROP STICK
        else
            return {
                isCrop=true,
                name = rawResult['crop:name'],
                gr = rawResult['crop:growth'],
                ga = rawResult['crop:gain'],
                re = rawResult['crop:resistance'],
                tier = rawResult['crop:tier']
            }
        end

    -- RANDOM BLOCK
    else
        return {isCrop=false, name='block'}
    end
end


local function isWeed(crop)
    return crop.name == 'weed' or
        crop.name == 'Grass' or
        crop.gr > config.maxGrowth or
        crop.re > config.maxResistance or
        (crop.name == 'venomilia' and crop.gr > 7)
end


return {
    scan = scan,
    isWeed = isWeed
}