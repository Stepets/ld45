local MapTileset = {}

function tile(x, y, w, h, img)
    return { img, love.graphics.newQuad(x * w, y * h, w, h, img:getDimensions()) }
end

function MapTileset:new()
    local tilesSpriteSheet = love.graphics.newImage('assets/map/sheet.png')
    local itemsSpriteSheet = love.graphics.newImage('assets/items.png')
    local grassSpriteSheet = love.graphics.newImage('assets/map/grass.png')
    local iceSpriteSheet = love.graphics.newImage('assets/map/ice.png')

    local newObj = {
        tiles = {
            wall = tile(9, 0, 70, 70, tilesSpriteSheet),
            wallBack = tile(1, 0, 70, 70, tilesSpriteSheet),
            roof = tile(7, 3, 70, 70, tilesSpriteSheet),
            tube = tile(2, 9, 70, 70, tilesSpriteSheet),
            window = tile(11, 2, 70, 70, tilesSpriteSheet),
            cloud = tile(4, 2, 70, 70, iceSpriteSheet),
            fire = tile(11, 2, 70, 70, tilesSpriteSheet),
            grass = tile(4, 3, 70, 70, grassSpriteSheet),
            bottle = { itemsSpriteSheet, love.graphics.newQuad(685, 700, 55, 145, itemsSpriteSheet:getDimensions()) },
            coin = { itemsSpriteSheet, love.graphics.newQuad(290, 650, 70, 70, itemsSpriteSheet:getDimensions()) },
        },
    }

    self.__index = self

    return setmetatable(newObj, self)
end

function MapTileset:drawTile(type, name, x, y)
    local tile = self.tiles[name]
    if type == 'tile' then
        love.graphics.draw(tile[1], tile[2],
            x * 32, y * 32, 0,
            0.5, 0.5)
    elseif type == 'item' then
        love.graphics.draw(tile[1], tile[2],
            x * 32, y * 32, 0,
            0.3, 0.3)
    elseif type == 'grass' then
        love.graphics.draw(tile[1], tile[2],
            x * 32, y * 32, 0,
            0.5, 0.5)
    end
end

return MapTileset
