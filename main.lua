local Bump, Player, Enemy, MapTileset

local assets, map, status, world, hero, items, mTileset, ui, enemy1

local statuses

function love.load()
    Bump = require 'bump.bump'
    Player = require "player"
    Enemy = require "enemy"
    MapTileset = require "mapTileset"

    assets = require "assets"
    map, world = unpack(require "map")
    status = require "status"
    items = require "items"
    ui = require "ui"

    hero = Player:new()
    hero:init()

    enemy1 = Enemy:new()
    enemy1:init()

    ui:init(hero)

    world:add(hero, hero.x, hero.y, 20, hero.baseHeight * 0.5)
    world:add(enemy1, enemy1.x, enemy1.y, 20, enemy1.baseHeight * 0.5)

    mTileset = MapTileset:new()
    mTileset:loadTileSet()
end

function love.update(dt)
    local to_delete = {}

    hero:move(dt, world, function(item, other)
      if item:can_pass(other.asset) then
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

    enemy1:move(dt, world)

    for item, effect in pairs(to_delete) do
        effect()
    end
    ui.update(dt)
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0.4, 0.4)

    local height = #map
    for y, row in ipairs(map) do
        for x = 1, map.w do
            local c = row[x]
            if c and c.asset then
                mTileset:drawTile(c.name, x, y)
            end
        end
    end

    hero:draw()
    enemy1:draw()
    ui.draw()
end


function love.mousepressed(x, y, button)
	ui.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	ui.mousereleased(x, y, button)
end

function love.wheelmoved(x, y)
	ui.wheelmoved(x, y)
end

function love.keypressed(key, isrepeat)
	ui.keypressed(key, isrepeat)
end

function love.keyreleased(key)
  if key == "f" then
    items.alco:use(hero)
  elseif key == "s" then
    print("stats", hero.inventory.coins, hero.status)
  end
	ui.keyreleased(key)
end

function love.textinput(text)
	ui.textinput(text)
end
