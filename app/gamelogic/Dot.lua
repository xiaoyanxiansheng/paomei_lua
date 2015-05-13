--[[
持续性,伤害Buff
]]
local Dot = class("Dot",require("src/app/gamelogic/Buff").new())

function Dot:ctor(dot)
	self:init(dot)
end

function Dot:remove()
	if self.endCallBack ~= nil then
		self.endCallBack(self)
	end
end

return Dot