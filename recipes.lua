local function check_cost(item, player)
  for it, val in pairs(item.cost) do
    if not player.inventory[it] or player.inventory[it] < val then
      return false
    end
  end

  for it, val in pairs(item.cost) do
    player.inventory[it] = player.inventory[it] - val
  end
  return true
end

local list = {
  alco = {
    cost = {coins = 3},
    use = function(self, player)
      if not check_cost(self, player) then
        return false
      end

      player.inventory.alco = (player.inventory.alco or 0) + 1
    end
  },
  donations = {
    cost = {},
    use = function(self, player)
      player.inventory.coins = (player.inventory.coins or 0) + 1
    end
  },
}

return {
    check_cost = check_cost,
    list = list,
}
