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
        gravity = 80, -- we will accelerate towards the bottom

        -- These are values applying specifically to jumping
        isJumping = false, -- are we in the process of jumping?
        isGrounded = false, -- are we on the ground?
        hasReachedMax = false, -- is this as high as we can go?
        jumpAcc = 500, -- how fast do we accelerate towards the top
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

    -- The Jump code gets a lttle bit crazy.  Bare with me.
    if love.keyboard.isDown("up", "w") then
        if -self.yVelocity < self.jumpMaxSpeed and not self.hasReachedMax then
            self.yVelocity = self.yVelocity - self.jumpAcc * dt
        elseif math.abs(self.yVelocity) > self.jumpMaxSpeed then
            --            self.hasReachedMax = true
        end

        self.isGrounded = false -- we are no longer in contact with the ground
    end

    self.x, self.y, collisions = world:move(self, goalX, goalY, filter)
end

function Player:draw()
    love.graphics.draw(self.img, self.x, self.y)
end

return Player
