local assets = require 'assets'

local bump = require 'bump.bump'
local world = bump.newWorld()

local w = {asset = assets.wall, name = 'wall'}
local f = {asset = assets.fire, name = 'fire'}
local c = {asset = assets.coin, name = 'coin'}
local p = {"player"}
local e = {"enemy"}
local structure = {
  w = 47,
  {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,_,_,_,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,},
  {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,_,_,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,},
  {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,_,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,},
  {_, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,},
  {w, w, w, w, w, w, w, w, w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,w,},
}

local function load()
  for y, row in ipairs(structure) do
    for x = 1, structure.w do
      local c = row[x]
      if c and c.asset then
        world:add({asset = c.asset, x = x, y = y}, x * assets.w, y * assets.h, assets.w, assets.h)
      end
    end
  end
end

load(structure)
return {structure, world}
