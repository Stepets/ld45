local function check_cost(item, player)
  for it, val in pairs(item.cost) do
    if not player.inventory or player.inventory[it] < val then
      return false
    end
  end

  for it, val in pairs(item.cost) do
    player.inventory[it] = player.inventory[it] - val
  end
  return true
end

local items = {
  alco = {
    cost = {coins = 3},
    use = function(self, player)
      if not check_cost(self, player) then
        return false
      end

      table.insert(player.status, {name = 'Fire proof', duration = 10})
    end
  },
  donations = {
    cost = {},
    use = function(self, player)
      player.inventory.coins = (player.inventory.coins or 0) + 1
    end
  },
}

return items
