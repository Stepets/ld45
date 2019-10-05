local statuses = require "status"
local Bottle = require "bottle"

local Player = {}
function Player:new()
    local newObj = {
        x = 60,
        y = 50,
        health = 10,

        -- The first set of values are for our rudimentary physics system
        xVelocity = 0, -- current velocity on x, y axes
        yVelocity = 0,
        acc = 100, -- the acceleration of our player
        maxSpeed = 300, -- the top speed
        friction = 20, -- slow our player down - we could toggle this situationally to create icy or slick platforms
        gravity = 100, -- we will accelerate towards the bottom

        -- These are values applying specifically to jumping
        isAttack = false, -- are we in the process of jumping?
        isJumping = false, -- are we in the process of jumping?
        isRuninig = false, -- are we in the process of jumping?
        isBottle = false, -- are we in the process of jumping?
        hasReachedMax = false,
        jumpAcc = 25, -- how fast do we accelerate towards the top
        jumpMaxSpeed = 10, -- our speed limit while jumping
        -- Here are some incidental storage areas
        img = nil,
        animation = {},
        baseHeight = 94,
        baseWidth = 62,
        flip = 1,
        status = {},
        inventory = {
            coins = 0,
            bottles = 0,
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
    local goalX = self.x + self.xVelocity
    local goalY = self.y + self.yVelocity
    local collisions, collisionsLength

    -- Apply Friction
    self.xVelocity = self.xVelocity * (1 - math.min(dt * self.friction, 1))
    self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))

    -- Apply gravity
    self.yVelocity = self.yVelocity + self.gravity * dt

    if love.keyboard.isDown("left", "a") and self.xVelocity > -self.maxSpeed then
        self.xVelocity = self.xVelocity - self.acc * dt

        self.flip = false
        self.isRuninig = true
    elseif love.keyboard.isDown("right", "d") and self.xVelocity < self.maxSpeed then
        self.xVelocity = self.xVelocity + self.acc * dt

        self.flip = true
        self.isRuninig = true
    else
        self.isRuninig = false
    end

    if love.keyboard.isDown("up", "w", "space") then
        if math.abs(self.yVelocity) > self.jumpMaxSpeed then
            self.hasReachedMax = true
        end

        if -self.yVelocity < self.jumpMaxSpeed and not self.hasReachedMax then
            self.yVelocity = self.yVelocity - 250 * dt
            self.isJumping = true
        end
    else
        self.isJumping = false
    end


    self.x, self.y, collisions, collisionsLength = world:move(self, goalX, goalY, filter)

    if love.keyboard.isDown("lctrl", "rctrl", "1") then
        self.isAttack = true
    else
        self.isAttack = false
    end

    if love.keyboard.isDown("lshift", "rshift", "2") and self.inventory.bottles > 0 then
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
            0.5, 0.5)
    else
        love.graphics.draw(self.animation.spriteSheet, activeFrame,
            self.x, self.y,
            0,
            -0.5, 0.5, self.baseWidth, 0)
    end

    for _, bottle in ipairs(self.bottles) do
        bottle:draw()
    end
end

function Player:update_status(dt)
    for i = #self.status, 1, -1 do
        local s = self.status[i]
        if s.duration then
            s.duration = s.duration - dt
            if s.duration <= 0 then
                table.remove(self.status, i)
            end
        end
    end
end

function Player:can_pass(tile_code)
    for _, s in ipairs(self.status) do
        if statuses[s.name]:walkable(tile_code) then
            return true
        end
    end
    return false
end

return Player
