local status = {}

function status.new(walkable)
  local obj = {walkable = {}}
  for _, v in ipairs(walkable) do
    obj.walkable[v] = true
  end
  return setmetatable(obj, {__index = status})
end

function status:walkable(tile_code)
  return self.walkable[tile_code]
end

return status
