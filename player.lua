local Player = {}
function Player:new()
    local newObj = {
        x = 16,
        y = 16,

        -- The first set of values are for our rudimentary physics system
        xVelocity = 0, -- current velocity on x, y axes
        yVelocity = 0,
        acc = 100, -- the acceleration of our player
        maxSpeed = 600, -- the top speed
        friction = 20, -- slow our player down - we could toggle this situationally to create icy or slick platforms
        gravity = 100, -- we will accelerate towards the bottom

        -- These are values applying specifically to jumping
        isJumping = false, -- are we in the process of jumping?
        isRuninig = false, -- are we in the process of jumping?
        hasReachedMax = false,
        jumpAcc = 25, -- how fast do we accelerate towards the top
        jumpMaxSpeed = 10, -- our speed limit while jumping
        -- Here are some incidental storage areas
        img = nil,
        animation = {},
        baseHeight = 94,
        baseWidth = 62,
        flip = 1,
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

    table.insert(self.animation.stay, love.graphics.newQuad(10, 16, self.baseWidth, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.run,
        love.graphics.newQuad(5, 125, self.baseWidth + 20, self.baseHeight, self.img:getDimensions()))
    table.insert(self.animation.run,
        love.graphics.newQuad(90, 125, self.baseWidth + 5, self.baseHeight, self.img:getDimensions()))

    table.insert(self.animation.jump,
        love.graphics.newQuad(83, 12, self.baseWidth + 10, self.baseHeight, self.img:getDimensions()))

    self.animation.duration = 0.5
    self.animation.currentTime = 0
end

function Player:move(dt, world, filter)
    local goalX = self.x + self.xVelocity
    local goalY = self.y + self.yVelocity
    local collisions

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

        if -self.yVelocity < self.jumpMaxSpeed and not self.hasReachedMax  then
            self.yVelocity = self.yVelocity - 250 * dt
            self.isJumping = true
        end
    else
        self.isJumping = false
    end

    self.x, self.y, collisions = world:move(self, goalX, goalY, filter)

    for i, coll in ipairs(collisions) do
        if coll.touch.y > goalY then
            self.hasReachedMax = true
            self.isJumping = true
        elseif coll.normal.y < 0 then
            self.hasReachedMax = false
            self.isJumping = false
        end
    end

    self.animation.currentTime = self.animation.currentTime + dt
    if self.animation.currentTime >= self.animation.duration then
        self.animation.currentTime = self.animation.currentTime - self.animation.duration
    end
end

function Player:draw()
    local animation
    if self.isJumping or self.hasReachedMax then
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
end

return Player
