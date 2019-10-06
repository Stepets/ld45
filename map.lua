local assets = require 'assets'

local bump = require 'bump.bump'

local function load(structure)
    local world = bump.newWorld()
    for y, row in ipairs(structure) do
        for x = 1, structure.w do
            local c = row[x]
            if c and c.name ~= 'enemy'and c.name ~= 'enemy2' and c.name ~= 'player' then
                world:add({asset = c, x = x, y = y}, x * assets.w, y * assets.h, assets.w, assets.h)
            end
        end
    end
    return structure, world
end

return load
