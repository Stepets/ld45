local Bump, Player, MapTileset

local assets, map, status, world, hero, items, mTileset

local statuses

function love.load()
    Bump = require 'bump.bump'
    Player = require "player"
    MapTileset = require "mapTileset"

    assets = require "assets"
    map, world = unpack(require "map")
    status = require "status"
    items = require "items"

    statuses = {
        default = status.new {},
        fire_proof = status.new { assets.fire },
    }

    hero = Player:new()
    hero:init()
    hero.status = 'default'
    hero.inventory = {
        coins = 0
    }

    world:add(hero, hero.x, hero.y, hero.baseWidth * 0.5, hero.baseHeight * 0.5)

    mTileset = MapTileset:new()
    mTileset:loadTileSet()
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
        items.alco:use(hero)
    elseif key == "s" then
        print("stats", hero.inventory.coins, hero.status)
    end
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
end
