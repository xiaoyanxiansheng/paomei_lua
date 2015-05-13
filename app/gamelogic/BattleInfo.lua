local json = require("framework.json")
local Fighter = require("src/app/gamelogic/Fighter")
local ReportMaker = require("src/app/gamelogic/ReportMaker")
local DOT = require("src/app/gamelogic/Dot")
local AttrBuff = require("src/app/gamelogic/AttrBuff")
local SkillDefManager = DataManager.getManager("SkillDefManager")
local BattleInfo = class("BattleInfo")
local MAX_ROUND = 20
local propertyType = {
	[0]=function(fighter) return 0 end,
	[1]=function(fighter) return fighter.currentAttr.hp end,
	[2]=function(fighter) return fighter.constAttr.hp end,
	[3]="",--怒气
	[4]="",--怒气值上限
	[5]=function(fighter) return fighter.currentAttr.atk end,
	[6]=function(fighter) return fighter.currentAttr.def end,
	[7]=function(fighter) return fighter.currentAttr.agi end
}
--[[
1 DOT_HOT --[1 DOT,2 HOT]
2 CONTROL --[1 DIZZY,2 SLEEP]
3 SPECIAL --[1 DEAD,2 ALIVE,3 EFFECT]
]]
local BuffMaker = {
--[[
		"params": [
		2,--5.基于X
		1,--6.某属性
		0.07,--7.百分比
		0,--8.附加绝对值
		0,--9.上限
		11,--1.buffId
		0,--2.延迟回合数
		3,--3.持续回合数
		0,--4.间隔回合数
		]
	]]
--[[DOT]]	
[11] = function(attacker,defender,params)
	local tmp = {}
	tmp.buffId = params[constData.BUFFID]
	tmp.delay = params[constData.DELAY]
	tmp.duration = params[constData.DURATION]
	tmp.interval = params[constData.INTERVAL]
	tmp.fileId = params[#params]
	tmp.from = attacker
	tmp.to = defender
	tmp.hurtCallBack = function()
		local boolean,value = BattleInfo.calcDamage(attacker,defender,params)
		defender:hurt(value)
		return (0-value)
	end
	tmp.endCallBack = function() end
	return DOT.new(tmp)
end,
--[[HOT]]	
[12] = function(attacker,defender,params) 
	
end,
--[[控制]]
[21] = function(attacker,defender,params)
    local tmp = {}
	tmp.buffId = params[constData.BUFFID]
	tmp.delay = params[constData.DELAY]
	tmp.duration = params[constData.DURATION]
	tmp.interval = params[constData.INTERVAL]
	tmp.fileId = params[#params]
	tmp.from = attacker
	tmp.to = defender
	tmp.hurtCallBack = function() defender:addStatus(params[#params]) return 0 end
	tmp.endCallBack = function() defender:removeStatus(params[#params])end
	return DOT.new(tmp)
end,
--[[]]
[33] = function(attacker,defender,params)
	
end,

--持续祝福
[41] = function(attacker,defender,params)
	local tmp = {}
	tmp.buffId = params[constData.BUFFID]
	tmp.delay = params[constData.DELAY]
	tmp.duration = params[constData.DURATION]
	tmp.interval = params[constData.INTERVAL]
	tmp.fileId = params[#params]
	tmp.from = attacker
	tmp.to = defender
	tmp.hurtCallBack = function()
	
		local exportRole
		local exportProperty
		--属性来源
		if params[constData.EXPORT] == constData.ATTACKER then
			exportRole = attacker
		elseif params[constData.EXPORT] == constData.DEFENDER then
			exportRole = defender
		end
		exportProperty = propertyType[params[constData.EXPORT_PROPERTY]](exportRole)

		local increValue = exportProperty*params[constData.PERCENT] + params[constData.ABSOULTE]
		increValue = math.ceil(increValue)
		--是否超过上限
		if params[constData.MAXLIMIT] ~= -1 and increValue > params[constData.MAXLIMIT] then increValue = params[constData.MAXLIMIT] end
		
		defender:increProperty(params[constData.EXPORT_PROPERTY],increValue)
		
		return increValue
	end
	tmp.endCallBack = function() end
	return DOT.new(tmp)
end,
--持续诅咒
[42] = function(attacker,defender,params)
	local tmp = {}
	tmp.buffId = params[constData.BUFFID]
	tmp.delay = params[constData.DELAY]
	tmp.duration = params[constData.DURATION]
	tmp.interval = params[constData.INTERVAL]
	tmp.fileId = params[#params]
	tmp.from = attacker
	tmp.to = defender
	tmp.hurtCallBack = function()
	
		local exportRole
		local exportProperty
		--属性来源
		if params[constData.EXPORT] == constData.ATTACKER then
			exportRole = attacker
		elseif params[constData.EXPORT] == constData.DEFENDER then
			exportRole = defender
		end
		exportProperty = propertyType[params[constData.EXPORT_PROPERTY]](exportRole)

		local reduceValue = exportProperty*params[constData.PERCENT] + params[constData.ABSOULTE]
		reduceValue = math.ceil(reduceValue)
		--是否超过上限
		if params[constData.MAXLIMIT] ~= -1 and reduceValue > params[constData.MAXLIMIT] then reduceValue = params[constData.MAXLIMIT] end
		
		defender:reduceProperty(params[constData.EXPORT_PROPERTY],reduceValue)
		
		return reduceValue
	end
	tmp.endCallBack = function() end
	return DOT.new(tmp)
end
}
function BattleInfo:ctor()
	self.attackList = {}
	self.defendList = {}
	--行动序列
	self.actionList = {}
	self.round_count = 0
	self.isAuto = false

	self.report = ReportMaker.new()

	self.effectFunc = {
	[1] = function(...) return self:directlyDamage(...) end,
	[2] = function(...) return self:directlyHeal(...) end,
	[3] = function(...) return self:addBuff(...) end,
	[4] = function( ... ) return self:removeBuff(...) end,
	[5] = function( ... ) return self:bless(...) end,
	[6] = function( ... ) return self:curse(...) end,
	[7] = function( ... ) return self:rebirth(...) end,
	[8] = function( ... ) return self:directlyDead(...) end,
	}

end

function BattleInfo:initInfo(attacker,defender)
    local tmp = cc.HelperFunc:getFileData("json/playerCharacter.json")
    local data = json.decode(tmp)
	for i = 1,#data do
		if data[i].sideType == 1 then
			--初始化攻击者
			table.insert(self.attackList,Fighter.new(data[i]))
		else
			--初始化防御者
			table.insert(self.defendList,Fighter.new(data[i]))
		end
	end
	--生成战报信息
	self.report:beginFighter(self.attackList,self.defendList)
end

function BattleInfo:startBattle()
	self:nextRound()
    return self.report:getCurrentReport()
end

--[[
	下一个count开始
]]
function BattleInfo:nextStep(data)
	if self.round_count == MAX_ROUND then
		return
	end

	self.currentReport = self.report:makeNewData()--开始新一轮数据报

	local attackFighter = self.actionList[#self.actionList]

	--人物开始行动
	local b,result = attackFighter:checkStatus()
	--攻击者数据报
	self.report:makeAttackerData(attackFighter,result)	
	
	if b then
		local fighterSkill
		local targetFighter = attackFighter:getTarget()
		
		if self.isAuto then
			--自动战斗
			--自动选择技能
			fighterSkill = self:autoChooseSkill(attackFighter)

			--自动选择目标
			targetFighter = targetFighter or self:randomFighterInList(self:getTargetList(fighterSkill.targetChoseType,attackFighter),1)[1]
		else
			--选择技能
			fighterSkill = attackFighter:chooseSkill(data.skillId)
			--先获取目标列表
			local list = self:getTargetList(fighterSkill.targetChoseType,attackFighter)
			targetFighter = self:selectFighterByID(data.figureNum,list)
		end
		--技能数据报
		self.report:makeSkillData(attackFighter:getSkill(),self.currentReport)
		--@params 攻击者 防御者 技能
		self:doFight(attackFighter,targetFighter,attackFighter:getSkill())

		--技能冷却
		attackFighter:getSkill():restart()
	end	
	
	self:fighterActionEnd()
	--人物行动完成后,再次排序
	self:sortActionListBySped()
end

--[[
	下一回合开始
]]
function BattleInfo:nextRound()
	self:insertToActionList(self.attackList)
	self:insertToActionList(self.defendList)
	self.round_count = self.round_count + 1
	self:sortActionListBySped()
end

function BattleInfo:isGameOver()
	local function hasSurvivor(fighters)
		local survivor = 0
		for i = 1,#fighters do
			if fighters[i]:isAlive() then
				survivor = survivor + 1
			end
		end
		return survivor
	end
	local result = hasSurvivor(self.attackList)
	if result == 0 then
		return constData.DEFENDER_WIN
	end
	result = hasSurvivor(self.defendList)
	if result == 0 then
		return constData.ATTACKER_WIN
	end
	return constData.CONTINUE
end

function BattleInfo:selectFighterByID(fighterId,list)
	for i = 1,#list do
		if fighterId == list[i].fighterId then
			return list[i]
		end
	end
end

function BattleInfo:insertToActionList(fighters)
	for i = 1,#fighters do
		if fighters[i]:isAlive() then
			table.insert(self.actionList,fighters[i])
		end
	end
end

function BattleInfo:sortActionListBySped()
	table.sort(self.actionList,function(t1,t2)
		if t1.currentAttr.agi < t2.currentAttr.agi then
			return true
		end
		return false
	end)
end

function BattleInfo:getTargetList(targetType,attackFighter)
	local ENEMYSIDE = 1
	local FRIENDSIDE = 2
	local list 
	if targetType == ENEMYSIDE then
		list = self:getEnemyListByAttacker(attackFighter)
	elseif targetType == FRIENDSIDE then
		list = self:getFriendListByAttacker(attackFighter)
	end
	return list
end


--[[
	战场左边是玩家
	战场右边是敌人
]]
function BattleInfo:getEnemyListByAttacker(attacker) 
	if attacker.sideType == constData.LEFTSIDE then
		return self:getAliveFighterInList(self.defendList)
	elseif attacker.sideType == constData.RIGHTSIDE then
		return self:getAliveFighterInList(self.attackList)
	end
end

function BattleInfo:getFriendListByAttacker(attacker)
	if attacker.sideType == constData.LEFTSIDE then
		return self:getAliveFighterInList(self.attackList)
	elseif attacker.sideType == constData.RIGHTSIDE then
		return self:getAliveFighterInList(self.defendList)
	end
end

function BattleInfo:getAliveFighterInList(list)
	local result = {}
	for i = 1,#list do
		if list[i]:isAlive() then
			table.insert(result,list[i])
		end
	end
	return result
end

function BattleInfo:randomFighterInList(list,num)
	local index 
	local result = {}
	--随机人数大于列表中人数
	if num > #list then
		num = #list
	end

	for i = 1,num do
		index = math.random(#list)
		--将随机到人放入列表保存
		table.insert(result,list[index])
		--不能重复选择,将选到人从列表中删除
		table.remove(list,index)
	end
	return result
end

function BattleInfo:randomFighterInListExcept(list,num,excepter)
	--先从列表中把特定人物移除
	for i = 1,#list do
		if list[i].fighterId == excepter.fighterId then
			table.remove(list,i)
			break
		end
	end
	return self:randomFighterInList(list,num)
end

--[[
	@return Skill
]]
function BattleInfo:autoChooseSkill(autoFighter)
	local list
	--选择技能
	if autoFighter.SkillList[2]:isCoolDown() then
		autoFighter:chooseSkill(autoFighter.SkillList[2].id)
	else
		autoFighter:chooseSkill(autoFighter.SkillList[1].id)
	end
	return autoFighter:getSkill()
end

--当前行动者行动完成
function BattleInfo:fighterActionEnd()
	self.actionList[#self.actionList]:endAction()
	table.remove(self.actionList,#self.actionList)
end

--[[
	@param flag = 1 当前这步自动战斗
	@param flag = 2 当前这步玩家选择目标,data 参数有意义
	@return {} 战报信息
	data = {
		figureNum=10004,
		skillId = 2001
	}
]]
function BattleInfo:fetchReport(flag,data)
	if flag == 1 then
		self.isAuto = true
	else
		self.isAuto = false
	end
	--当前是手动战斗
	if self.isAuto == false 
		--操作方是玩家
		and self.actionList[#self.actionList].sideType == PLAYER 
		--并且当前没有目标
		and self.actionList[#self.actionList]:getTarget() == nil then
		--则没有战报产生
		return nil
	end
	self:nextStep(data)
	self:reOrganizeData(self.report:getCurrentReport())
	return self.report:getCurrentReport()
end

function BattleInfo:reOrganizeData(data)
--[[
data.target={
 		[1001]=
 		{
 		 hurt=100,
 		 helper=0,
 		 state={{4001,0},{4001,0}}
 		},
 		[1003]=
 		{
 		 hurt=100,
 		 helper=0,
 		 state={{4001,0},{4001,0}}
 		}
	}	
]]
	if data.skillId == nil then
		--人物被晕眩,不能使用技能
		return
	end
	local skillData = SkillDefManager:getSkillById(data.skillId)
	local tmp = {}
	if skillData.skillRange%2 == 0 then
		--群体
		for k,v in pairs(data.target) do
			table.insert(tmp,v)
		end
		data.target = {tmp}
	else
		--单体
		for k,v in pairs(data.target) do
			tmp[#tmp+1] = {}
			table.insert(tmp[#tmp],v)
		end
		data.target = tmp
	end
end

function BattleInfo:getCurrentFighter()
	if #self.actionList == 0 then
		self:nextRound()
	end
	--判断当前人物是否可以操作
	local actFighter = self.actionList[#self.actionList]
	local isManipulate = false
	if actFighter.sideType == constData.LEFTSIDE then
		isManipulate = true
	end
	--生成战报
	self.report:currentFighter(actFighter,self.round_count,isManipulate,self.attackList,
	self.defendList)
	return self.report:getCurrentReport()
end

function BattleInfo:doFight(attacker,defender,skill)
	--战报数据
	local fightData = {}
	--用于保存各个effect目标
	local effectTargets = {}
	--用于保存每个effect造成影响目标
	--[[
		hitTargets[effectNum]={
			{fighter,value},
			{fighter,value}
		}
	]]
	local hitTargets = {}

	local triggerList = {}
	triggerList.__index = function() return false end
	for si = 1,#skill.effect do
		effectTargets[si] = {}
		hitTargets[si] = {}
		local currentEffect = skill.effect[si]
		if currentEffect.effectType ~= 0 then
			-- 根据effect选择目标
			if currentEffect.targetType == 1 then--自己
				--保存目标
				table.insert(effectTargets[si],attacker)

			elseif currentEffect.targetType == 2 then--己方
				--保存目标
				self:saveCurrentEffectTargets(effectTargets[si],currentEffect,attacker)
			elseif currentEffect.targetType == 3 then--敌方
				--保存目标
				self:saveCurrentEffectTargets(effectTargets[si],currentEffect,defender)
			elseif currentEffect.targetType == 4 then--同effect 1 一致
				for i = 1,#hitTargets[1] do
					table.insert(effectTargets[si],hitTargets[1][i][1])
				end
				-- effectTargets[si] = hitTargets[1]
			elseif currentEffect.targetType == 5 then
				for i = 1,#hitTargets[2] do
					table.insert(effectTargets[si],hitTargets[2][i][1])
				end
				-- effectTargets[si] = hitTargets[2]
			elseif currentEffect.targetType == 6 then
				for i = 1,#hitTargets[3] do
					table.insert(effectTargets[si],hitTargets[3][i][1])
				end
				-- effectTargets[si] = hitTargets[3]
			elseif currentEffect.targetType == 7 then
				for i = 1,#hitTargets[4] do
					table.insert(effectTargets[si],hitTargets[4][i][1])
				end
				-- effectTargets[si] = hitTargets[4]
			end

			local result = false
			
			--对每个目标做特定操作
			for i = 1,#effectTargets[si] do
				print("dofight skillId = "..skill.id)
				local boolean,value = self.effectFunc[currentEffect.effectType](attacker, --攻击者 
													effectTargets[si][i],--防御者
													currentEffect,--使用effect
													triggerList)
				if boolean then 
					result = boolean 
					table.insert(hitTargets[si],{effectTargets[si][i],value})
					self.report:makeReport(attacker,effectTargets[si][i],currentEffect,value,self.currentReport)
				end
				
			end
			triggerList[si] = result
		end
	end
end


function BattleInfo:saveCurrentEffectTargets(targetList,currentEffect,target)
	table.insert(targetList,target)
	local filterList
	
	filterList = self:randomFighterInListExcept(self:getFriendListByAttacker(target),currentEffect.extraTarget,target)

	for i = 1,#filterList do
		table.insert(targetList,filterList[i])
	end
	return filterList
end


--[[
	@return boolean 表示效果是否触发
]]
function BattleInfo:isTrigger(prob)
	if prob == 1 then
		return true
	end
	prob = prob*100
	math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
	local result = math.random(100)
	if result <= prob then
		return true
	end
	return false
end


function BattleInfo:directlyDamage(attacker,defender,effect,triggerList)
	--"conditions": [0,1] --[前置X效果触发 0无意义,触发几率]
	--"parameters": [1,5,1,0,-1,2,6],--[1攻击/防御者,2某属性,3百分比,4固定值,5上限值 -1没有上限,6攻击/防御者,7某属性]
	local condition = effect.conditions
	local param = effect.parameters
	--判断前置是否触发
	if condition[constData.PREEFFECT] == constData.DEFAULT or triggerList[condition[constData.POSSIBILITY]] then
		--判断是否触发
		if self:isTrigger(condition[constData.POSSIBILITY]) then
			local boolean,value = BattleInfo.calcDamage(attacker,defender,param)
			defender:hurt(value)
			return boolean,value
		end
	end
	return false,0
end

function BattleInfo.calcDamage(attacker,defender,param)
	local exportRole
	local exportProperty
	local importRole
	local importProperty
	--属性来源
	if param[constData.EXPORT] == constData.ATTACKER then
		exportRole = attacker
	elseif param[constData.EXPORT] == constData.DEFENDER then
		exportRole = defender
	end
	if param[constData.IMPORT] == constData.ATTACKER then
		importRole = attacker
	elseif param[constData.IMPORT] == constData.DEFENDER then
		importRole = defender
	end
	--具体角色的某个属性
	exportProperty = propertyType[param[constData.EXPORT_PROPERTY]](exportRole)
	importProperty = propertyType[param[constData.IMPORT_PROPERTY]](importRole)
	--计算伤害
	local damageValue = math.ceil(exportProperty*param[constData.PERCENT] - importProperty + param[constData.ABSOULTE])
	local minValue = math.ceil(exportProperty*constData.MINDAMAGE)
	if damageValue < minValue then
		damageValue = minValue
	end

	--是否超过上限
	if param[constData.MAXLIMIT] ~= -1 and damageValue > param[constData.MAXLIMIT] then damageValue = param[constData.MAXLIMIT] end

	return true,damageValue
end

function BattleInfo:directlyHeal(attacker,defender,effect,triggerList)
	--"conditions": [0,1] --[前置X效果触发 0无意义,触发几率]
	--"parameters": [1,1,0.45,1,100],--[1攻击/防御者,2某属性,3百分比,4固定值,5上限值]
	local condition = effect.conditions
	local param = effect.parameters
	--判断前置是否触发
	if condition[constData.PREEFFECT] == constData.DEFAULT or triggerList[condition[constData.POSSIBILITY]] then
		--判断是否触发
		if self:isTrigger(condition[constData.POSSIBILITY]) then
			local exportRole
			local exportProperty

			--属性来源
			if param[constData.EXPORT] == constData.ATTACKER then
				exportRole = attacker
			elseif param[constData.EXPORT] == constData.DEFENDER then
				exportRole = defender
			end
			--具体角色的某个属性
			exportProperty = propertyType[param[constData.EXPORT_PROPERTY]](exportRole) 
			--计算治疗
			local healValue = math.ceil(exportProperty*param[constData.PERCENT] + param[constData.ABSOULTE])
			--是否超过上限
			if param[constData.MAXLIMIT] ~= -1 and healValue > param[constData.MAXLIMIT] then healValue = param[constData.MAXLIMIT] end

			defender:heal(healValue)
			return true,healValue
		end
	end

	return false,0
end



function BattleInfo:addBuff(attacker,defender,effect,triggerList)
	--"conditions": [0,1] --[前置X效果触发 0无意义,触发几率]
	
	local condition = effect.conditions
	local params = effect.parameters
	--判断前置是否触发
	if condition[constData.PREEFFECT] == constData.DEFAULT or triggerList[condition[constData.PREEFFECT]] then
		--判断是否触发
		if self:isTrigger(condition[constData.POSSIBILITY]) then
			local maskCode = math.floor(params[constData.BUFFID]/10)
			local buff = BuffMaker[params[constData.BUFFID]](attacker,defender,params)
			if maskCode == 2 then
				defender:addControllBuff(buff)
			else
				defender:addBuff(buff)
			end
			return true,0
		end
	end
	return false,0
end

function BattleInfo:removeBuff(attacker,defender,effect,triggerList)
	-- body
end

function BattleInfo:rebirth(attacker,defender,effect,triggerList)
	-- body
end

function BattleInfo:directlyDead(attacker,defender,effect,triggerList)
	
end

function BattleInfo:bless(attacker,defender,effect,triggerList)
	--[[
		"parameters[]": [2,6,0.2,100,-1,0,0],
		"conditions[]": [0,1]
	]]
	local condition = effect.conditions
	--判断前置是否触发
	if condition[constData.PREEFFECT] == constData.DEFAULT or triggerList[condition[constData.POSSIBILITY]] then
		--判断是否触发
		if self:isTrigger(condition[constData.POSSIBILITY]) then
			local param = effect.parameters
			local exportRole
			local exportProperty

			--属性来源
			if param[constData.EXPORT] == constData.ATTACKER then
				exportRole = attacker
			elseif param[constData.EXPORT] == constData.DEFENDER then
				exportRole = defender
			end
			exportProperty = propertyType[param[constData.EXPORT_PROPERTY]](exportRole)

			local increValue = exportProperty*param[constData.PERCENT] + param[constData.ABSOULTE]

			--是否超过上限
			if param[constData.MAXLIMIT] ~= -1 and increValue > param[constData.MAXLIMIT] then increValue = param[constData.MAXLIMIT] end

			defender:increProperty(constData.EXPORT_PROPERTY,increValue)
			
			return true,increValue
		end
	end
	return false,0
end

function BattleInfo:curse(attacker,defender,effect,triggerList)
	--[[
	"conditions[]": [1,0.72]
	"parameters[]": [2,5,0.15,0,-1,0,0] [1:基于X,2:X属性,3:百分比,4:附加绝对值,5:上限,6:不用,7:不用]
	]]
	local condition = effect.conditions
	--判断前置是否触发
	if condition[constData.PREEFFECT] == constData.DEFAULT or triggerList[condition[constData.PREEFFECT]] then
		--判断是否触发
		if self:isTrigger(condition[constData.POSSIBILITY]) then
			local param = effect.parameters
			local exportRole
			local exportProperty

			--属性来源
			if param[constData.EXPORT] == constData.ATTACKER then
				exportRole = attacker
			elseif param[constData.EXPORT] == constData.DEFENDER then
				exportRole = defender
			end
			exportProperty = propertyType[param[constData.EXPORT_PROPERTY]](exportRole)

			local reduceValue = exportProperty*param[constData.PERCENT] + param[constData.ABSOULTE]
			reduceValue = math.ceil(reduceValue)
			--是否超过上限
			if param[constData.MAXLIMIT] ~= -1 and reduceValue > param[constData.MAXLIMIT] then reduceValue = param[constData.MAXLIMIT] end
			
			print("BattleInfo:curse before curse:"..tostring(defender.currentAttr[constData.attributeType[param[constData.EXPORT_PROPERTY]]]))
			
			defender:reduceProperty(param[constData.EXPORT_PROPERTY],reduceValue)
			
			print("BattleInfo:curse after curse:"..tostring(defender.currentAttr[constData.attributeType[param[constData.EXPORT_PROPERTY]]]))
			return true,reduceValue
		end
	end
	return false,0
end


return BattleInfo