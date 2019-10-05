local w, h = 32, 32

local wall = love.image.newImageData(w, h)

for x = 1, w do
  for y = 1, h do
    wall:setPixel(x - 1, y - 1, 0.3, 0.3, 0.5, 1)
  end
end

local fire = love.image.newImageData(w, h)

for x = 1, w do
  for y = 1, h do
    fire:setPixel(x - 1, y - 1, 0.8, 0.7, 0.1, 1)
  end
end


return {
  w = w,
  h = h,
  wall = love.graphics.newImage(wall),
  fire = love.graphics.newImage(fire),
}
