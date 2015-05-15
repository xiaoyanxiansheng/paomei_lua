local Buff = class("Buff");

function Buff:ctor()

end

function Buff:init(buff)
	self.buffId = buff.buffId
	self.fileId = buff.fileId
	self.name = buff.name;
	self.duration = buff.duration;
	--Buff施放者
	self.from = buff.from;
	--Buff目标
	self.to = buff.to;
	--延迟
	self.delay = buff.delay;
	--间隔
	self.interval = buff.interval;
	self.hurtCallBack = buff.hurtCallBack;
	self.endCallBack = buff.endCallBack;
end

--[[
	@return boolean
	true 状态结束
	false 状态继续
]]
function Buff:update()
	local tmp = {}
	tmp.value = 0
	tmp.fileId = self.fileId
	self.delay = self.delay - 1
	if self.delay <= 0 then
		self.delay = self.interval
		if self.hurtCallBack ~= nil then
			tmp.value = self.hurtCallBack()
		end
		self.duration = self.duration - 1
	end
	if self.duration <= 0 then
		return true,tmp
	end
	return false,tmp
end

function Buff:remove()
	if self.endCallBack ~= nil then
		self.endCallBack(self)
	end
end

return Buff