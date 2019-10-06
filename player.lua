local statuses = require "status"
local Bottle = require "bottle"

local Player = {}
function Player:new()
    local newObj = {
        x = 60,
        y = 50,
        health = 10,
        scale = 0.5,

        -- The first set of values are for our rudimentary physics system
        xVelocity = 0, -- current velocity on x, y axes
        yVelocity = 0,

        maxSpeed = 300, -- the top speed
        gravity = 1400, -- we will accelerate towards the bottom


        isAttack = false,
        isJumping = false,
        isRuninig = false,
        isBottle = false,
        hasReachedMax = false,

        jumpMaxSpeed = 600, -- our speed limit while jumping


        img = nil,
        animation = {},
        baseHeight = 94,
        baseWidth = 62,
        flip = 1,
        status = {},
        inventory = {
            coins = 0,
            bottles = 100,
        },
        bottles = {}
    }

    self.__index = self

    return setmetatable(newObj, self)
end

function Player:init()
    self.img = love.graphics.newImage('assets/adventurer.png')

    self.animation.spriteSheet = self.img;
    self.animation.stay = {};
    self.animation.run = {};
    self.animation.jump = {};
    self.animation.attack = {};
    self.animation.bottle = {};

    table.insert(self.animation.stay, love.graphics.newQuad(10, 16, self.baseWidth, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.run,
        love.graphics.newQuad(5, 125, self.baseWidth + 20, self.baseHeight, self.img:getDimensions()))
    table.insert(self.animation.run,
        love.graphics.newQuad(90, 125, self.baseWidth + 5, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.jump,
        love.graphics.newQuad(83, 12, self.baseWidth + 10, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.attack,
        love.graphics.newQuad(400, 125, self.baseWidth + 15, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.bottle,
        love.graphics.newQuad(320, 125, self.baseWidth + 15, self.baseHeight, self.img:getDimensions()))

    self.animation.duration = 0.5
    self.animation.currentTime = 0
end

function Player:move(dt, world, filter)
    local goalX = self.x + self.xVelocity * dt
    local goalY = self.y + self.yVelocity * dt
    local collisions, collisionsLength

    self.isJumping = ({world:check(self, self.x, self.y + 1)})[2] == self.y + 1

    -- Apply gravity
    if self.isJumping then
        self.yVelocity = self.yVelocity + self.gravity * dt * (self.status["Icarus"] and -1 or 1)
    else
        self.yVelocity = 0
    end

    if love.keyboard.isDown("left", "a") then
        self.xVelocity = - self.maxSpeed

        self.flip = false
        self.isRuninig = true
    elseif love.keyboard.isDown("right", "d") then
        self.xVelocity = self.maxSpeed

        self.flip = true
        self.isRuninig = true
    else
        self.xVelocity = 0
        self.isRuninig = false
    end

    if love.keyboard.isDown("up", "w", "space") and not self.isJumping   then
        -- if math.abs(self.yVelocity) > self.jumpMaxSpeed then
        --     self.hasReachedMax = true
        -- end

        -- if -self.yVelocity < self.jumpMaxSpeed and not self.hasReachedMax then
            self.yVelocity = - self.jumpMaxSpeed * (self.status["Froggy"] and 1.5 or 1)
            self.isJumping = true
        -- end
    end


    self.x, self.y, collisions, collisionsLength = world:move(self, goalX, goalY, filter)

    if love.keyboard.isDown("lctrl", "rctrl", "1") and not self.isAttack then
        self.isAttack = true
    else
        self.isAttack = false
    end

    if love.keyboard.isDown("lshift", "rshift", "2") and not self.isBottle and self.inventory.bottles > 0 then
        self.inventory.bottles = self.inventory.bottles - 1
        self.isBottle = true

        local bottle1 = Bottle:new()
        bottle1:init()

        if self.flip then
            bottle1.x = self.x + 32
        else
            bottle1.x = self.x - 10
        end
        bottle1.y = self.y + 8
        bottle1.flip = self.flip

        world:add(bottle1, bottle1.x, bottle1.y, bottle1.baseWidth * 0.1, bottle1.baseHeight * 0.1)
        table.insert(self.bottles, bottle1)
    else
        self.isBottle = false
    end

    for i, coll in ipairs(collisions) do
        if coll.touch.y > goalY then
            self.hasReachedMax = true
            self.isJumping = true
        elseif coll.normal.y < 0 then
            self.hasReachedMax = false
            self.isJumping = false
        end
    end

    for i = 1, collisionsLength do
        if self.isAttack and collisions[i].other.health then
            collisions[i].other.health = collisions[i].other.health - 1
            collisions[i].other.isAttacked = true
            if collisions[i].other.health < 1 then
                world:remove(collisions[i].other)
            end
        end
    end


    self.animation.currentTime = self.animation.currentTime + dt
    if self.animation.currentTime >= self.animation.duration then
        self.animation.currentTime = self.animation.currentTime - self.animation.duration
    end

    self:update_status(dt)

    for _, bottle in ipairs(self.bottles) do
        bottle:move(dt, world)
    end
end

function Player:draw()
    local animation
    if self.isBottle then
        animation = self.animation.bottle
    elseif self.isAttack then
        animation = self.animation.attack
    elseif self.isJumping or self.hasReachedMax then
        animation = self.animation.jump
    elseif self.isRuninig then
        animation = self.animation.run
    else
        animation = self.animation.stay
    end

    local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #animation) + 1
    local activeFrame = animation[spriteNum]

    if self.flip then
        love.graphics.draw(self.animation.spriteSheet, activeFrame,
            self.x, self.y,
            0,
            self.scale, self.scale)
    else
        love.graphics.draw(self.animation.spriteSheet, activeFrame,
            self.x, self.y,
            0,
            -self.scale, self.scale, self.baseWidth, 0)
    end

    for _, bottle in ipairs(self.bottles) do
        bottle:draw()
    end
end

function Player:update_status(dt)
    for name, duration in pairs(self.status) do
        duration = duration - dt
        if duration <= 0 then
            self.status[name] = nil
        else
            self.status[name] = duration
        end
    end
end

function Player:can_pass(tile_code)
    for name, duration in pairs(self.status) do
        if statuses[name]:walkable(tile_code) then
            return true
        end
    end
    return false
end

return Player
