local Bottle = {}
function Bottle:new()
    local newObj = {
        x = 60,
        y = 50,
        live = true,

        -- The first set of values are for our rudimentary physics system
        xVelocity = 0, -- current velocity on x, y axes
        yVelocity = 0,
        yVelocityMax = 0,
        acc = 200, -- the acceleration of our player
        maxSpeed = 200, -- the top speed
        friction = 20, -- slow our player down - we could toggle this situationally to create icy or slick platforms


        hasReachedMax = false,
        img = nil,
        animation = {},
        baseWidth = 55,
        baseHeight = 145,
        flip = 1,
    }

    self.__index = self

    return setmetatable(newObj, self)
end

function Bottle:init()
    self.img = love.graphics.newImage('assets/items.png')

    self.animation.spriteSheet = self.img;
    self.animation.fly = {};

    table.insert(self.animation.fly, love.graphics.newQuad(685, 700, self.baseWidth, self.baseHeight, self.img:getDimensions()))

    self.animation.duration = 0.5
    self.animation.currentTime = 0
    self.animation.flip = 0
end

function Bottle:move(dt, world)
    if self.yVelocityMax == 0 then
        self.yVelocityMax = self.y - 15
    end

    if self.live == false then
        return
    end


    local goalX = self.x + self.xVelocity
    local goalY = self.y + self.yVelocity
    local collisions, collisionsLength

    -- Apply Friction
    self.xVelocity = self.xVelocity * (1 - math.min(dt * self.friction, 1))
    --    self.yVelocity = self.yVelocity * (1 - math.min(dt * self.friction, 1))

    if self.flip then
        self.xVelocity = self.xVelocity + self.acc * dt
    else
        self.xVelocity = self.xVelocity - self.acc * dt
    end

    if self.y > self.yVelocityMax and self.yVelocityMax ~=-1 then
        self.yVelocity = self.yVelocity - 30 * dt
    else
         self.yVelocityMax = -1

        self.yVelocity = self.yVelocity + 30 * dt
    end


    self.x, self.y, collisions, collisionsLength = world:move(self, goalX, goalY)


    for i = 1, collisionsLength do
        self.live = false
        if collisions[i].other.health then
            collisions[i].other.health = collisions[i].other.health - 1
            collisions[i].other.isAttacked = true
            if collisions[i].other.health < 1 then
                world:remove(collisions[i].other)
            end
        end
        world:remove(self)
        return
    end


    self.animation.currentTime = self.animation.currentTime + dt
    self.animation.flip = self.animation.flip + dt * 30
    if self.animation.currentTime >= self.animation.duration then
        self.animation.currentTime = self.animation.currentTime - self.animation.duration
    end
end

function Bottle:draw()
    if self.live == false then
        return
    end

    local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.fly) + 1
    local activeFrame = self.animation.fly[spriteNum]

    if self.flip then
        love.graphics.draw(self.animation.spriteSheet, activeFrame,
            self.x, self.y,
            self.animation.flip,
            0.1, 0.1)
    else
        love.graphics.draw(self.animation.spriteSheet, activeFrame,
            self.x, self.y,
            self.animation.flip,
            -0.1, 0.1, self.baseWidth, 0)
    end
end

return Bottle
