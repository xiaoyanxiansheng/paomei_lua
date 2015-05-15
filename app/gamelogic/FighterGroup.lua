local FighterGroup = class("FighterGroup");

function FighterGroup:ctor(isManipulate)
	self.groupFighters = {}
	--战场技能
	self.groupSkill = {}
	self.isManipulate = isManipulate
end

function FighterGroup:addFighter(fighter)
	table.insert(self.groupFighters,fighter)
end

function FighterGroup:canManipulate()
	return self.isManipulate
end

--[[
	获取战斗组所有成员
]]
function FighterGroup:getFighters()
	return self.groupFighters
end

return FighterGroup
