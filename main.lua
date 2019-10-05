local Bump, Player, MapTileset, Enemy, camera

local assets, map, status, world, hero, items, mTileset, ui

local statuses
local enemies = {}

function love.load()
    Bump = require 'bump.bump'
    Player = require "player"
    MapTileset = require "mapTileset"
    Enemy = require "enemy"
    camera = (require 'hump.camera').new()
    assets = require "assets"
    map, world = unpack(require "map")
    status = require "status"
    items = require "items"
    ui = require "ui"

    hero = Player:new()
    hero:init()

    ui:init(hero)

    world:add(hero, hero.x, hero.y, 20, hero.baseHeight * 0.5)


    local enemy = Enemy:new()
    enemy:init()
    enemy.x = 10 * 32
    enemy.y = 32
    world:add(enemy, enemy.x, enemy.y, 20, enemy.baseHeight * 0.5)
    table.insert(enemies, enemy)

    mTileset = MapTileset:new()
    mTileset:loadTileSet()
end

function love.update(dt)
    local to_delete = {}

    hero:move(dt, world, function(item, other)
        if item:can_pass(other.asset) then
            return false
        elseif other.name == 'coin' then
            if item == hero and not to_delete[other] then
                to_delete[other] = function()
                    hero.inventory.coins = hero.inventory.coins + 1
                    world:remove(other)
                    map[other.y][other.x] = nil
                end
            end
            return "cross"
        elseif other.name == 'bottle' then
            if item == hero and not to_delete[other] then
                to_delete[other] = function()
                    hero.inventory.bottles = hero.inventory.bottles + 1
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
    ui.update(dt)
    camera:lookAt(hero.x, hero.y)

    for _, enemy in ipairs(enemies) do
        enemy:move(dt, world)
    end
end

function love.draw()
    camera:attach()
    love.graphics.setBackgroundColor(0, 0.4, 0.4)

    local height = #map
    for y, row in ipairs(map) do
        for x = 1, map.w do
            local c = row[x]
            if c then
                if c.name == 'enemy' then
                    local enemy = Enemy:new()
                    enemy:init()
                    enemy.x = x * 32
                    enemy.y = y * 32
                    world:add(enemy, enemy.x, enemy.y, 20, enemy.baseHeight * 0.5)
                    table.insert(enemies, enemy)
                    map[y][x] = nil
                else
                    mTileset:drawTile(c.type, c.name, x, y)
                end
            end
        end
    end
    for _, enemy in ipairs(enemies) do
        enemy:draw()
    end

    hero:draw()
    camera:detach()
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
    ui.keyreleased(key)
end

function love.textinput(text)
    ui.textinput(text)
end
