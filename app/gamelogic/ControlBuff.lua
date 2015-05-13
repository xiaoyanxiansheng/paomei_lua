--[[
持续性,控制性Buff
]]
local ControlBuff = class("ControlBuff",require("src/app/gamelogic/Buff"))

function ControlBuff:ctor(buff)
	ControlBuff.hurtCallBack = function()
		--给目标施加一个控制类型效果
		--添加状态
		self.to:addStatus(self:getType())
		return 0
	end
	self:init(buff)
	--被控制类型 晕眩,睡眠...
	self.controlType = buff.controlType
end

function ControlBuff:getType()
	return self.controlType
end

function ControlBuff:remove()
	if self.endCallBack ~= nil then
		self.endCallBack(self)
	end
	self.to:removeStatus(self:getType())
end

return ControlBuff
