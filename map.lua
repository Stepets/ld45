local assets = require 'assets'

local bump = require 'bump.bump'
local world = bump.newWorld()

local structure = {
  {0, 0, 0, 0, 0,  0, 0, 0, 1},
  {1, 1, 0, 0, 1,  1, 0, 0, 1},
  {1, 0, 0, 0, 10, 0, 0, 1, 1},
  {1, 0, 0, 0, 10, 0, 1, 1, 1},
  {1, 1, 1, 1, 1,  1, 1, 1, 1},
}

local function load()
  for y, row in ipairs(structure) do
    for x, c in ipairs(row) do
      if c == 1 then
        world:add({assets.wall}, x * assets.w, y * assets.h, assets.w, assets.h)
      elseif c == 10 then
        world:add({assets.fire}, x * assets.w, y * assets.h, assets.w, assets.h)
      end
    end
  end
end

load(structure)
return {structure, world}
