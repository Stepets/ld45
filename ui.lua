local loveframes = require "LoveFrames.loveframes"
local items = require "items"
local recipes = require "recipes"

local ui = {}

function ui:init(hero)
  self.hero = hero

  self.inventory_frame = loveframes.Create("frame")
  self.inventory_frame:SetName("Inventory")
  self.inventory_frame:SetVisible(false)
  self.inventory_frame:SetSize(85, 210)
  self.inventory_frame:SetPos(700, 0)
  self.inventory_frame.OnClose = function(obj)
      obj:SetVisible(not obj:GetVisible())
      return false
  end

  self:update_inventory()

  self.craft_frame = loveframes.Create("frame")
  self.craft_frame:SetName("Recipes")
  self.craft_frame:SetVisible(false)
  self.craft_frame:SetSize(285, 210)
  self.craft_frame:SetPos(500, 500, true)
  self.craft_frame.OnClose = function(obj)
    obj:SetVisible(not obj:GetVisible())
    return false
  end

  self:update_recipes()

  local panel = loveframes.Create("panel")
  panel:SetSize(125, 125)
  panel:SetPos(0, 0)
  self.status = loveframes.Create("text", panel)
  self.status.Update = function(obj)
    local text = ''
    for name, duration in pairs(self.hero.status) do
      text = text .. name .. ': ' .. tostring(math.floor(duration * 10) / 10) .. 's\n'
    end
    obj:SetText(text)
  end

end

function ui:update_recipes()
    local children = self.craft_frame:GetChildren()
    for _, c in ipairs(children) do c:Remove() end

    local offset_y = 30
    for item, info in pairs(recipes.list) do
        local button = loveframes.Create("button", self.craft_frame)
        button:SetSize(self.craft_frame:GetWidth()-10, 30)

        local recipe = ''
        for it, val in pairs(info.cost) do
        recipe = recipe .. ' ' .. it .. ' x' .. tostring(val)
        end
        recipe = recipe .. ' => ' .. item
        button:SetText(recipe)

        button.OnClick = function(object, x, y)
        	info:use(self.hero)
            self:update_inventory()
        end

        button:SetPos(5, offset_y)
        offset_y = offset_y + 32
    end
end

function ui:update_inventory()
    local children = self.inventory_frame:GetChildren()
    for _, c in ipairs(children) do c:Remove() end

    local offset_y = 30
    for item, count in pairs(self.hero.inventory) do
        if count > 0 then
            local button = loveframes.Create("button", self.inventory_frame)
            button:SetSize(self.inventory_frame:GetWidth()-10, 30)

            button:SetText(item .. ' x' .. tostring(count))

            button.OnClick = function(object, x, y)
                items[item](self.hero)
                self.hero.inventory[item] = self.hero.inventory[item] - 1
                self:update_inventory()
            end

            button:SetPos(5, offset_y)
            offset_y = offset_y + 32
        end
    end
end

function ui.update(dt)
  loveframes.update(dt)
end

function ui.draw()
  loveframes.draw()
end

function ui.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end

function ui.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end

function ui.wheelmoved(x, y)
	loveframes.wheelmoved(x, y)
end

function ui.keypressed(key, isrepeat)
	loveframes.keypressed(key, isrepeat)
end

function ui.keyreleased(key)
    if key == 'r' then
        ui.craft_frame:SetVisible(not ui.craft_frame:GetVisible())
    elseif key == 'i' then
        ui.inventory_frame:SetVisible(not ui.inventory_frame:GetVisible())
    end
    loveframes.keyreleased(key)
end

function ui.textinput(text)
	loveframes.textinput(text)
end

return ui
