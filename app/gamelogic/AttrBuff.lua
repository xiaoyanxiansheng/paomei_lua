--用来恢复某减益/增益Buff属性
local AttrBuff = class("AttrBuff",require("src/app/gamelogic/Buff").new())

function AttrBuff:ctor(buff)
	self:init(buff)
	--增/减益某属性
	self.attrType = buff.attrType
end

function AttrBuff:remove()
	if self.endCallBack ~= nil then
		self.endCallBack(self)
	end
end