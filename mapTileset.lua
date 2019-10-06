local MapTileset = {}
function MapTileset:new()
    local newObj = {
        tilesQuads = {},
        tilesSpriteSheet = nil,
        tilesWidth = 70,
        tilesHeight = 70,
        tiles = {
            wall = 10,
            fire = 40,
        },

        grassQuads = {},
        grassSpriteSheet = nil,
        grassWidth = 70,
        grassHeight = 70,
        grass = {
            grass = 26,
        },


        itemsQuads = {},
        itemsSpriteSheet = nil,
        items = {
            bottle = 1,
            coin = 2,
        },
    }

    self.__index = self

    return setmetatable(newObj, self)
end

function MapTileset:loadTileSet()
    local image = love.graphics.newImage('assets/map/sheet.png')

    self.tilesSpriteSheet = image

    for y = 0, image:getHeight() - self.tilesHeight, self.tilesHeight do
        for x = 0, image:getWidth() - self.tilesWidth, self.tilesWidth do
            table.insert(self.tilesQuads, love.graphics.newQuad(x, y, self.tilesWidth, self.tilesHeight, image:getDimensions()))
        end
    end

    image = love.graphics.newImage('assets/items.png')

    self.itemsSpriteSheet = image

    table.insert(self.itemsQuads, love.graphics.newQuad(685, 700, 55, 145, image:getDimensions()))
    table.insert(self.itemsQuads, love.graphics.newQuad(290, 650, 70, 70, image:getDimensions()))

    image = love.graphics.newImage('assets/map/grass.png')

    self.grassSpriteSheet = image

    for y = 0, image:getHeight() - self.grassHeight, self.grassHeight do
        for x = 0, image:getWidth() - self.grassWidth, self.grassWidth do
            table.insert(self.grassQuads, love.graphics.newQuad(x, y, self.grassWidth, self.grassHeight, image:getDimensions()))
        end
    end

end

function MapTileset:drawTile(type, name, x, y)
    local tileNumber
    if type == 'tile' then
        tileNumber = self.tiles[name]
        love.graphics.draw(self.tilesSpriteSheet, self.tilesQuads[tileNumber],
            x * 32, y * 32, 0,
            0.5, 0.5)
    elseif type == 'item' then
        tileNumber = self.items[name]
        love.graphics.draw(self.itemsSpriteSheet, self.itemsQuads[tileNumber],
            x * 32, y * 32, 0,
            0.3, 0.3)
    elseif type == 'grass' then
        tileNumber = self.grass[name]
        love.graphics.draw(self.grassSpriteSheet, self.grassQuads[tileNumber],
            x * 32, y * 32, 0,
            0.5, 0.5)
    end
end

return MapTileset