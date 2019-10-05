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
        img = nil -- store the sprite we'll be drawing
    }

    self.__index = self

    return setmetatable(newObj, self)
end

function Player:init()
    self.img = love.graphics.newImage('assets/player.png')
end

function Player:move(dt, world)
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

    self.x, self.y, collisions = world:move(self, goalX, goalY)

    for i, coll in ipairs(collisions) do
        if coll.touch.y > goalY then
            self.hasReachedMax = true
            self.isJumping = true
        elseif coll.normal.y < 0 then
            self.hasReachedMax = false
            self.isJumping = false
        end
    end
end

function Player:draw()
    love.graphics.draw(self.img, self.x, self.y)
end

return Player