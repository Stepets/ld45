local loveframes = require "LoveFrames.loveframes"
local items = require "items"

local ui = {}

function ui:init(hero)
  self.hero = hero

  local panel = loveframes.Create("panel")
  panel:SetSize(210, 85)
  panel:SetPos(700, 0)

  self.inventory = loveframes.Create("text", panel)
  self.inventory.Update = function(obj)
    local text = ''
    for k,v in pairs(self.hero.inventory) do
      text = text .. k .. ': ' .. v .. '\n'
    end
    obj:SetText(text)
  end

  self.craft_frame = loveframes.Create("frame")
  self.craft_frame:SetName("Recipes")
  self.craft_frame:SetVisible(false)
  self.craft_frame:SetSize(185, 210)
  self.craft_frame:SetPos(500, 500, true)
  self.craft_frame.OnClose = function(obj)
    obj:SetVisible(not obj:GetVisible())
    return false
  end

  local offset_y = 30
  for item, info in pairs(items) do
    local button = loveframes.Create("button", self.craft_frame)
  	button:SetSize(175, 30)

    local recipe = ''
    for it, val in pairs(info.cost) do
      recipe = recipe .. ' ' .. it .. ' x' .. tostring(val)
    end
    recipe = recipe .. ' => ' .. item
  	button:SetText(recipe)

    button.OnClick = function(object, x, y)
  		info:use(self.hero)
  	end

    button:SetPos(5, offset_y)
    offset_y = offset_y + 30
  end

  local panel = loveframes.Create("panel")
  panel:SetSize(125, 125)
  panel:SetPos(0, 0)
  self.status = loveframes.Create("text", panel)
  self.status.Update = function(obj)
    local text = ''
    for _, s in ipairs(self.hero.status) do
      text = text .. s.name .. ': ' .. tostring(math.floor(s.duration * 10) / 10) .. 's\n'
    end
    obj:SetText(text)
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
  if key == 'i' then
    ui.craft_frame:SetVisible(not ui.craft_frame:GetVisible())
  end
	loveframes.keyreleased(key)
end

function ui.textinput(text)
	loveframes.textinput(text)
end

return ui
