local FighterAttr = require("src/app/gamelogic/FighterAttr");
local Skill = require("src/app/gamelogic/Skill")
local SkillDefManager = DataManager.getManager("SkillDefManager")
local Fighter = class("Fighter");
--状态

function Fighter:ctor(fighter)
	self.name = fighter.name
	self.fighterId = fighter.fighterId
	--站位id
	self.post_id = fighter.post
	--各属性常值
	self.constAttr = FighterAttr.new(fighter.attribute[1]);
	--当前属性值
	self.currentAttr = FighterAttr.new(fighter.attribute[1]);
	--控制性Buff
	self.ControlBuffList = {};
	--持续性Buff
	self.BuffList = {};
	--技能 1普通技能 2特殊技能
	self.SkillList = {[1] = Skill.new(SkillDefManager:getSkillById(fighter.skills[1].id),self),
					[2] = Skill.new(SkillDefManager:getSkillById(fighter.skills[2].id),self)};
	self.currentSkillId = 1	
	--人物状态
	self.statusList = {};
	self.statusList.__index = function()
		return false
	end
	--人物目标
	self.target = nil;
	--1 player 2 enemy
	self.sideType = fighter.sideType;
end

function Fighter:clear()
	self.ControlBuffList = {};
	self.BuffList = {};
	self.statusList = {};
	self.statusList.__index = function()
		return false
	end
end

--[[
	每一回合,人物行动
]]
function Fighter:checkStatus()
	--1 更新人物技能cd
	local buffData = {}
	if not self:isAlive() then
		return false,buffData
	end
	local isSurvive = self:visitBuff(buffData)
	if not isSurvive then
		--死亡
		return false,buffData 
	end

	if not self:visitControlBuff(buffData)  then
		--被控制
		return false,buffData
	end
	return true,buffData
end

function Fighter:endAction()
	self:updateSkillCD()
end

function Fighter:visitBuff(data)
	local bi = 1
	while bi <= (#self.BuffList) do
		local tmp = {}
		local isend,value 
		if bi == 1 and #self.BuffList == 0 then
            isend,value = self.BuffList[bi]:update()
    		print("bi = "..bi)
    		print("#self.BuffList="..#self.BuffList)
    	else
            isend,value = self.BuffList[bi]:update()
		end
		tmp.fileId = self.BuffList[bi].fileId
		tmp.value = value
		table.insert(data,tmp)
		 if isend then
		 	self.BuffList[bi]:remove()
		 	table.remove(self.BuffList,bi)
		 	bi = bi - 1
		 end
		 if not self:isAlive() then
		 	return false
		 end
		 bi = bi + 1
	end

	return true
end

function Fighter:addBuff(buff)
	table.insert(self.BuffList,buff)
end

function Fighter:addControllBuff(buff)
	table.insert(self.ControlBuffList,buff)
end

function Fighter:isAlive()
	if self.currentAttr.hp > 0 then
		self:addStatus(constData.NORMAL)
	elseif self.currentAttr.hp <= 0 then
		self:removeStatus(constData.NORMAL)
		self:addStatus(constData.DEAD) 
	end
	return self.statusList[constData.statusType[constData.NORMAL]] or false
end

function Fighter:isEnemy(side)
	return self.sideType ~= side
end

function Fighter:visitControlBuff(data)
	--能否行动
	local act = true
	local cbi = 1
	while cbi <= #self.ControlBuffList do
		local tmp = {}
		local isend,value = self.ControlBuffList[cbi]:update()
		tmp.fileId = self.ControlBuffList[cbi].fileId
		tmp.value = value
		table.insert(data,tmp)

		 if isend then
		 	self.ControlBuffList[cbi]:remove()
		 	table.remove(self.ControlBuffList,cbi)
		 	cbi = cbi - 1
		 end
		 cbi = cbi + 1
		 act = false
	end
	return act
end

function Fighter:updateSkillCD()
	for i =1,#self.SkillList do
		self.SkillList[i]:update()
	end
end

function Fighter:setTarget(target)
	self.target = target
end

function Fighter:getTarget()
	return self.target
end

function Fighter:heal(num)
	self.currentAttr.hp = self.currentAttr.hp + num
	if self.currentAttr.hp > self.constAttr.hp then
		self.currentAttr.hp = self.constAttr.hp
	end
end

function Fighter:hurt(num)
	self.currentAttr.hp = self.currentAttr.hp - num
	if self.currentAttr.hp < 0 then
		self.currentAttr.hp = 0
		-- self:removeStatus(constData.NORMAL)
		self:clear()
		self:addStatus(constData.DEAD) 
	end
end

function Fighter:getSkill()
	return self.SkillList[self.currentSkillId]
end

function Fighter:chooseSkill(skillid)
	for i = 1,#self.SkillList do
		if self.SkillList[i].id == skillid then
			self.currentSkillId = i
			return self.SkillList[i]
		end
	end
end

function Fighter:addStatus(num)
	local sType = constData.statusType[num]
	self.statusList[sType] = true
end

function Fighter:removeStatus(num)
	local sType = constData.statusType[num]
	self.statusList[sType] = nil
end

function Fighter:findBuffById(id)
	for i = 1,#self.BuffList do
		if self.BuffList[i].BuffId == id then
			return self.BuffList[i]
		end
	end
	return nil
end

function Fighter:reduceProperty(propertyType,value)
	self.currentAttr[constData.attributeType[propertyType]] = self.currentAttr[constData.attributeType[propertyType]] - value
end

function Fighter:increProperty(propertyType,value)
	self.currentAttr[constData.attributeType[propertyType]] = self.currentAttr[constData.attributeType[propertyType]] + value
end

return Fighter