local Bump, Player, MapTileset, Enemy, camera

local assets, map, status, world, hero, mTileset, ui

local enemies
local map_to_load

function load_map(map_name)
    map_to_load = map_name
end

function deffered_load_map()
    local loader = require "map"
    package.loaded["levels"] = nil
    local levels = require "levels"
    map, world = loader(levels[map_to_load])
    map_to_load = nil

    world:add(hero, hero.x, hero.y, hero.baseWidth * hero.scale, hero.baseHeight * hero.scale)


    enemies = {}

end

function love.load()
    Bump = require 'bump.bump'
    Player = require "player"
    MapTileset = require "mapTileset"
    Enemy = require "enemy"
    camera = (require 'hump.camera').new()
    assets = require "assets"
    status = require "status"
    ui = require "ui"

    hero = Player:new()
    hero:init()

    ui:init(hero)

    load_map('e1m1')

    mTileset = MapTileset:new()
    mTileset:loadTileSet()
end

function love.update(dt)
    if map_to_load then
        deffered_load_map()
    end

    local to_delete = {}

    hero:move(dt, world, function(item, other)
        if not other.asset or item:can_pass(other.asset.name) then
            return false
        elseif other.asset.type == 'item' then
            if item == hero and not to_delete[other] then
                to_delete[other] = function()
                    world:remove(other)
                    map[other.y][other.x] = nil
                    if other.asset.effect then other.asset.effect(hero) end
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
                    world:add(enemy, enemy.x, enemy.y, enemy.baseWidth * enemy.scale, enemy.baseHeight * enemy.scale)
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
