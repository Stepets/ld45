local Enemy = {}
function Enemy:new()
    local newObj = {
        x = 120,
        y = 50,
        health = 10,
        scale = 0.4,

        -- The first set of values are for our rudimentary physics system
        xVelocity = 0, -- current velocity on x, y axes
        yVelocity = 0,
        acc = 100, -- the acceleration of our player
        maxSpeed = 300, -- the top speed
        friction = 20, -- slow our player down - we could toggle this situationally to create icy or slick platforms
        gravity = 100, -- we will accelerate towards the bottom

        -- These are values applying specifically to jumping
        isJumping = false, -- are we in the process of jumping?
        isRuninig = false, -- are we in the process of jumping?
        isAttacked = false, -- are we in the process of jumping?
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
        },
    }

    self.__index = self

    return setmetatable(newObj, self)
end

function Enemy:init()
    self.img = love.graphics.newImage('assets/boy.png')

    self.animation.spriteSheet = self.img;
    self.animation.stay = {};
    self.animation.run = {};
    self.animation.jump = {};
    self.animation.attacked = {};

    table.insert(self.animation.stay, love.graphics.newQuad(10, 16, self.baseWidth, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.run,
        love.graphics.newQuad(5, 125, self.baseWidth + 20, self.baseHeight, self.img:getDimensions()))
    table.insert(self.animation.run,
        love.graphics.newQuad(90, 125, self.baseWidth + 5, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.jump,
        love.graphics.newQuad(83, 12, self.baseWidth + 10, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.attacked,
        love.graphics.newQuad(155, 12, self.baseWidth + 10, self.baseHeight, self.img:getDimensions()))

    self.animation.duration = 0.5
    self.animation.currentTime = 0
end

function Enemy:move(dt, world, filter)
    if self.health < 1 then
        return
    end

    local goalX = self.x + self.xVelocity
    local goalY = self.y + self.yVelocity
    local collisions

    -- Apply Friction
    self.xVelocity = self.xVelocity * (1 - math.min(dt * self.friction, 1))
    self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))

    -- Apply gravity
    self.yVelocity = self.yVelocity + self.gravity * dt

    self.x, self.y, collisions = world:move(self, goalX, goalY, filter)
end

function Enemy:draw()
    if self.health < 1 then
        return
    end

    local animation
    if self.isAttacked then
        animation = self.animation.attacked
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
end



return Enemy
