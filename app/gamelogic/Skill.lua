local Skill = class("Skill");
--[[
	[
		{
			"id": 10001,
			"level": 1,
			"description": "对敌单体造成100%攻击力的近战物理伤害。",
			"sound": "",
			"imname": "",
			"skillbar": 0,
			"targetChoseType": 1,--目标选择类型,用于表现层,提示玩家技能可使用的目标[1 = 敌人,2 = 己方 ] 
			"skillRange": 1,--技能施放站位
			"preCooldown": 0,--预备回合数  开战后，技能过x回合后才可使用
			"skillCooldown": 0,--冷却回合数  使用技能后，经过x回合后可再次使用
			"effect":
			[
				{
					"effectType": 1,--0 缺省;1 直接伤害;2 直接治疗;3 添加buff;
									4 移除buff;5 祝福(增加属性);6诅咒(降低属性);7复活;8即死 
					"targetType": 3,--[1 自己 2 己方 3敌方]
					"extraTarget": 0,--额外随机人数
					"parameters": [1,0.45,1,100],--[攻击者某属性,百分比,防御者某属性,固定值]
					"conditions": [0,1] 
				}
			]
		}
	]
]]

--[[
	"effectType":1
	"parameters": [1,5,1,0,-1,2,6,-1],--[1攻击/防御者,2某属性,3百分比,4固定值,5上限值 -1没有上限,6攻击/防御者,7某属性]
]]
--[[
	"effectType":2
	"parameters":[0,0,0,500,-1,0,0,-1],--[1攻击/防御者,2某属性,3百分比,4固定值,5上限值]
]]
--[[
	"effectType":3
	"parameters":[1,5,0.15,0,-1,0,0,33,2,1,0,-1]--[1基于x,2某属性,3百分比,4附加绝对值,5上限值,6基于x,7某属性,8buffId,9延迟回合数,10持续回合数,11间隔回合数]
]]
--[[
	"effectType":5
	"parameters":[2,6,0.2,100,-1,0,0,8]--[1:基于X,2:X属性,3:百分比,4:附加绝对值,5:上限,6:不用,7:不用]
]]
--[[
	"effectType":6
	"parameters":[2,5,0.15,0,-1,0,0,3]--[1:基于X,2:X属性,3:百分比,4:附加绝对值,5:上限,6:不用,7:不用]
]]
local SKILL_INTERVAL = 1

function Skill:ctor(sk,host)
	--持有技能的角色
	self.host = host;
	self.id = sk.id;
	self.level = sk.level;
	self.targetChoseType = sk.targetChoseType;
	self.skillRange = sk.skillRange;
	self.skillCooldown = sk.preCooldown;
	self.maxCooldown = sk.skillCooldown;
	self.interval = 0
	self.effect = sk.effect;
end

function Skill:update()
	if self.interval <= 0 then
		self.skillCooldown = self.skillCooldown - self.host.currentAttr.cd
		if self.skillCooldown <= constData.READY then
			self.skillCooldown = constData.READY
		end
	else
		self.interval = self.interval - SKILL_INTERVAL
	end
end

--[[
	@return true 表示可以用
	false 还在冷却
]]
function Skill:isCoolDown()
	return self.skillCooldown == constData.READY
end

--[[
	重新开始计时
]]
function Skill:restart()
	self.interval = SKILL_INTERVAL
	self.skillCooldown = self.maxCooldown
end

--[[
	立刻进入可用状态
]]
function Skill:coolDown()
	self.skillCooldown = constData.READY
end

return Skill