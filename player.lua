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
        hasReachedMax = false,
        jumpAcc = 50, -- how fast do we accelerate towards the top
        jumpMaxSpeed = 9.5, -- our speed limit while jumping
        -- Here are some incidental storage areas
        img = nil,
        animation = {}
    }

    self.__index = self

    return setmetatable(newObj, self)
end

function Player:init()
    self.img = love.graphics.newImage('assets/adventurer.png')

    self.animation.spriteSheet = self.img;
    self.animation.quads = {};

    local duration = 1
    local height = 120
    local width = 70

    table.insert(self.animation.quads, love.graphics.newQuad(0, 0, width, height, self.img:getDimensions()))

    self.animation.duration = duration or 1
    self.animation.currentTime = 0
end

function Player:runAnimation(type)
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
    elseif love.keyboard.isDown("right", "d") and self.xVelocity < self.maxSpeed then
        self.xVelocity = self.xVelocity + self.acc * dt
    end

    if love.keyboard.isDown("up", "w", "space") then
        if self.yVelocity > 0 and not self.isJumping and not self.hasReachedMax then
            self.yVelocity = -self.jumpAcc
            self.isJumping = true
        elseif math.abs(self.yVelocity) > self.jumpMaxSpeed then
            self.hasReachedMax = true
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
    local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
    local activeFrame = self.animation.quads[spriteNum]

    love.graphics.draw(self.animation.spriteSheet, activeFrame,
        self.x,
        self.y,
        0, 0.5, 0.5)
end

function getImageScaleForNewDimensions(image, newWidth, newHeight)
    local currentWidth, currentHeight = image:getDimensions()
    return (newWidth / currentWidth), (newHeight / currentHeight)
end

return Player
