local assets = require 'assets'

local status = {}

function status.new(walkable)
  local obj = {walks = {}}
  for _, v in ipairs(walkable) do
    obj.walks[v] = true
  end
  return setmetatable(obj, {__index = status})
end

function status:walkable(tile_code)
  return self.walks[tile_code]
end

return {
    ["Fire proof"] = status.new { "fire" },
    ["Icarus"] = status.new {},
}
