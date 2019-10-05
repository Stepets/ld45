local MapTileset = {}
function MapTileset:new()
    local newObj = {
        quads = {},
        spriteSheet = nil,
        image = nil,
        width = 70,
        height = 70,
        tiles = {
            wall = 10,
            fire = 40,
            coin = 75,
        }
    }

    self.__index = self

    return setmetatable(newObj, self)
end

function MapTileset:loadTileSet()
    self.image = love.graphics.newImage('assets/map/sheet.png')

    self.spriteSheet = self.image

    for y = 0, self.image:getHeight() - self.height, self.height do
        for x = 0, self.image:getWidth() - self.width, self.width do
            table.insert(self.quads, love.graphics.newQuad(x, y, self.width, self.height, self.image:getDimensions()))
        end
    end
end

function MapTileset:drawTile(name, x,y)
    local tileNumber = self.tiles[name]

    love.graphics.draw(self.spriteSheet, self.quads[tileNumber],
        x * 32, y * 32, 0,
        0.5, 0.5)
end

return MapTileset