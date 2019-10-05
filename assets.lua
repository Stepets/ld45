local wall = love.image.newImageData(16, 16)

for x = 1, 16 do
  for y = 1, 16 do
    wall:setPixel(x - 1, y - 1, 0.3, 0.3, 0.5, 1)
  end
end

local fire = love.image.newImageData(16, 16)

for x = 1, 16 do
  for y = 1, 16 do
    fire:setPixel(x - 1, y - 1, 0.8, 0.7, 0.1, 1)
  end
end


return {
  w = 16,
  h = 16,
  wall = love.graphics.newImage(wall),
  fire = love.graphics.newImage(fire),
}
