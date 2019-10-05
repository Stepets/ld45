local assets, map, status

local statuses
local player = {
  status = 'default',
  inventory = {
    coins = 0
  },
}

function love.load()
    assets = require "assets"
    map = require "map"
    status = require "status"

    statuses = {
      default = status.new{ 0 },
      fire_proof = status.new{ 0, 10 },
    }
end

function love.update(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0.4, 0.4)
    local height = #map
    for y, row in ipairs(map) do
      for x, c in ipairs(row) do
        if c == 1 then
          love.graphics.draw(assets.wall, x * assets.w, y * assets.h)
        elseif c == 10 then
          love.graphics.draw(assets.fire, x * assets.w, y * assets.h)
        end
      end
    end
end
