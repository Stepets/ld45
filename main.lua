local Bump, Player

local assets, map, status, world, hero

local statuses

local ground_0 = {}
local ground_1 = {}

function love.load()
    Bump = require 'bump.bump'
    Player = require "player"

    assets = require "assets"
    map = require "map"
    status = require "status"

    statuses = {
        default = status.new { 0 },
        fire_proof = status.new { 0, 10 },
    }

    hero = Player:new()
    hero:init()

    world = Bump.newWorld(16) -- 16 is our tile size

    world:add(hero, hero.x, hero.y, hero.img:getWidth(), hero.img:getHeight())

    -- Draw a level
    world:add(ground_0, 120, 360, 640, 16)
    world:add(ground_1, 0, 448, 640, 32)
end

function love.update(dt)
    hero:move(dt, world)
end

-- Draw a coloured rectangle.
function love.draw()
    love.graphics.setBackgroundColor(0, 0.4, 0.4)
    local height = #map
    for y, row in ipairs(map) do
        for x, c in ipairs(row) do
            if c == 1 then
                love.graphics.draw(assets.wall, x * assets.w, y * assets.h)
            end
        end
    end

    love.graphics.rectangle('fill', world:getRect(ground_0))
    love.graphics.rectangle('fill', world:getRect(ground_1))

    hero:draw()
end
