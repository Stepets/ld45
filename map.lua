local assets = require 'assets'

local bump = require 'bump.bump'
local world = bump.newWorld()

local w = {asset = assets.wall}
local f = {asset = assets.fire}
local c = {asset = assets.coin}
local p = {"player"}
local e = {"enemy"}
local structure = {
  w = 9,
  {_, p, _, _, _, e, _, _, w},
  {w, w, _, _, w, w, _, _, w},
  {w, _, _, _, f, _, _, w, w},
  {w, c, c, c, f, _, w, w, w},
  {w, w, w, w, w, w, w, w, w},
}

local function load()
  for y, row in ipairs(structure) do
    for x, c in ipairs(row) do
      if c and c.asset then
        world:add({asset = c.asset, x = x, y = y}, x * assets.w, y * assets.h, assets.w, assets.h)
      end
    end
  end
end

load(structure)
return {structure, world}
