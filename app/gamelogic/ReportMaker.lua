local ReportMaker = class("ReportMaker");
--[[

]]
function ReportMaker:ctor()
	self.reportData = {}
end


--[[
	{attaker={
				{
				figureNum=1009,
				state={
				 	{4001,100},
				 	{4002,100},
				 	{}}
				 	},
				},
		 target={
		 	{
		 		{
		 		 hurt=100,
		 		 helper=0,
		 		 isDead=false,
		 		 Revege=100,
		 		 state={
		 		 	{4001,0},
		 		 	{4001,0}
		 		 	}
		 		 }
		 	},
		 	},
		 	skillId=2002},
	gameOver=false
]]

function ReportMaker:makeAttackerData(attacker,buffData)
	local tmp = {}
	tmp.figureNum = attacker.fighterId
	tmp.hp = attacker.currentAttr.hp
	tmp.state = {}
	for i = 1,#buffData do
		local bd = {}
		bd[1] = buffData[i].fileId
		bd[2] = buffData[i].value
		table.insert(tmp.state,bd)
	end
	for i = 1,#attacker.ControlBuffList do
		bd[1] = attacker.ControlBuffList[i].fileId
		bd[2] = 0
	end
	if self.reportData[#self.reportData].attacker == nil then
	   self.reportData[#self.reportData].attacker = {}
	end 
	tmp.isAlive = attacker:isAlive()
	table.insert(self.reportData[#self.reportData].attacker,tmp)
end

--[[
	{
		[1]={["figureNum"] = 1002,--唯一ID
			["maxHP"]=1000,
			["direction"] = 1,--朝向 1 向右 -1 向左
			["skills"] = {10001,10002} --具体技能ID
			}
		[2]={["figureNum"] = 2003,
		["maxHP"]=1000,
			["direction"] = -1,
			["skills"] = {10023,10092}}
	}
]]

function ReportMaker:beginFighter(attackers,defenders)
	local function fillContainerWithList(sourceList,container,dir)
			for fi = 1,#sourceList do
				local tmp = {}
				tmp.figureNum = sourceList[fi].fighterId
				tmp.maxHP = sourceList[fi].constAttr.hp

				tmp.direction = dir
				tmp.skills = {}
				for i = 1,#sourceList[fi].SkillList do
					table.insert(tmp.skills,sourceList[fi].SkillList[i].id)
				end
				table.insert(container,tmp)
			end
		end

	self:makeNewData()
	fillContainerWithList(attackers,self.reportData[#self.reportData],1)
	fillContainerWithList(defenders,self.reportData[#self.reportData],-1)
end

function ReportMaker:makeSkillData(skill,reportData)
	reportData.skillId = skill.id
end

--[[
	{
		["attacker"]={
			["figureNum"] = 1002 --当前行动的人物ID
			["roundCount"] = 1,
			["isAlive"] = false,
			["isManipulate"] = false,
			[skills] = {{["id"]=2001, --技能ID
						["isCoolDown"]=1 --1 表示可用 0 无法使用
						}},
		["info"]={
			[figureNum]={hp=100,mp=100},
			[figureNum]={hp=100,mp=100},
			[figureNum]={hp=100,mp=100}
		}	
	}
]]
function ReportMaker:makeCurrentFighter(fighter,isManipulate,count,attackers,defenders)
	if fighter == nil then
		return nil
	end
	self:makeNewData()
	--人物信息
	local tmp = {}
	tmp.figureNum = fighter.fighterId
	--技能信息
	tmp.skills = {}
	for i = 1,#fighter.SkillList do
		local skillInfo = {}
		skillInfo.id = fighter.SkillList[i].id
		skillInfo.isCoolDown = fighter.SkillList[i]:isCoolDown()
		table.insert(tmp.skills,skillInfo)
	end
	--回合数
	tmp.roundCount = count
	--是否可以操作
	tmp.isManipulate = isManipulate
	--是否死亡
	tmp.isAlive = fighter:isAlive()

	self.reportData[#self.reportData].attacker = tmp
	--将所有人信息放入
	self.reportData[#self.reportData].info = {}
	local function makeFighterInfo(fighterList,container)
		for fi = 1,#fighterList do
			local tmp = {["hp"]=fighterList[fi].currentAttr.hp}
			container[fighterList[fi].fighterId]=tmp
		end
	end
	makeFighterInfo(attackers,self.reportData[#self.reportData].info)
	makeFighterInfo(defenders,self.reportData[#self.reportData].info)
end


function ReportMaker:makeNewData()
	self.reportData[#self.reportData+1] = {}
	return self.reportData[#self.reportData]
end


function ReportMaker:getCurrentReport()
	return self.reportData[#self.reportData]
end

function ReportMaker:makeReport(attacker,defender,effect,value,currentReport)
--[[
target={
		 	{
		 		{
		 		figureNum=1001,
		 		 hurt=100,
		 		 helper=0,
		 		 state={{4001,0},{4001,0}}
		 		},
		 		{
		 		figureNum=1003
		 		 hurt=100,
		 		 helper=0,
		 		 state={{4001,0},{4001,0}}
		 		}
		 	},
		 	{
		 		{
		 		figureNum=1002
		 		hurt=100,
		 		helper=0,
		 		state={{4001,0},{4001,0}}
		 		}
		 	}
		 },
]]
	local currentFightId = defender.fighterId
	if currentReport.target == nil then
		currentReport.target = {}
	end
	if currentReport.target[currentFightId] == nil then
		currentReport.target[currentFightId] = {}
		currentReport.target[currentFightId].figureNum = currentFightId
		currentReport.target[currentFightId].state = {}
	end
	local fighterReport = currentReport.target[currentFightId]
	if effect.effectType == constData.DIRECTLYHURT then
		fighterReport.hurt = 0 - math.abs(value)
	elseif effect.effectType == constData.DIRECTLYHEAL then
		fighterReport.hurt = math.abs(value)
	elseif effect.effectType == constData.ADDBUFF then
		local tmp = {}
		tmp[1] = effect.parameters[#effect.parameters]
		tmp[2] = 0
		table.insert(fighterReport.state,tmp)
	elseif effect.effectType == constData.BLESS then
		local tmp = {}
		tmp[1] = effect.parameters[#effect.parameters]
		tmp[2] = 0
		table.insert(fighterReport.state,tmp)
	elseif effect.effectType == constData.CURSE then
		local tmp = {}
		tmp[1] = effect.parameters[#effect.parameters]
		tmp[2] = 0
		table.insert(fighterReport.state,tmp)
	end
	fighterReport.isAlive = defender:isAlive()
	fighterReport.hp = defender.currentAttr.hp
end

return ReportMaker