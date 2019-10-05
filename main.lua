local Bump, Player

local assets, map, status, world, hero

local statuses

local ground_0 = {}
local ground_1 = {}

function love.load()
    Bump = require 'bump.bump'
    Player = require "player"

    assets = require "assets"
    map, world = unpack(require "map")
    status = require "status"

    statuses = {
        default = status.new { },
        fire_proof = status.new { assets.fire },
    }

    hero = Player:new()
    hero:init()
    hero.status = 'default'
    hero.inventory = {
      coins = 0
    }

    -- world = Bump.newWorld(16) -- 16 is our tile size

    world:add(hero, hero.x, hero.y, 32, 64)

    -- Draw a level
    world:add(ground_0, 120, 360, 640, 16)
    world:add(ground_1, 0, 448, 640, 32)
end

function love.update(dt)
    local to_delete = {}

    hero:move(dt, world, function(item, other)
      if statuses[item.status]:walkable(other.asset) then
        return false
      elseif other.asset == assets.coin then
        if item == hero and not to_delete[other] then
          to_delete[other] = function()
            hero.inventory.coins = hero.inventory.coins + 1
            world:remove(other)
            map[other.y][other.x] = nil
          end
        end
        return "cross"
      else
        return "slide"
      end
    end)

    for item, effect in pairs(to_delete) do
      effect()
    end
end

function love.keyreleased(key, scancode)
  if key == "f" then
    if hero.status == 'default' then
      hero.status = 'fire_proof'
    else
      hero.status = 'default'
    end
  end
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0.4, 0.4)

    local height = #map
    for y, row in ipairs(map) do
      for x = 1, map.w do
        local c = row[x]
        if c and c.asset then
          love.graphics.draw(c.asset, x * assets.w, y * assets.h)
        end
      end
    end

    love.graphics.rectangle('fill', world:getRect(ground_0))
    love.graphics.rectangle('fill', world:getRect(ground_1))

    hero:draw()
end
