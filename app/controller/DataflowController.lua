--数据控制实体行动
local scheduler          = require("src.framework.scheduler")

local DataflowController = class("DataflowController")

function DataflowController:ctor(dataflow)
    -- 数据流对象
    self.m_dataflow = dataflow
    -- 主控制器
    self.m_mainSceneController = nil
    -- 执行函数索引
    self.m_function_index = 1
    
    self:init()
end

function DataflowController:init()
    
    -- 连续执行函数初始化
    self:initFunctionList()
    
    -- 主要逻辑
    scheduler.scheduleGlobal(handler(self,self.luoji),1/60)
end

function DataflowController:luoji()

    if self:stopLuoji() then
        -- 等待线程
    	return
    end
    
    -- 一步步执行正常数据流
    self:exeNormalStep()
    
end

-- 是否线程等待
function DataflowController:stopLuoji()
    -- 停止线程（游戏结束）  or 玩家输入时的等待  or count运行时的等待
    if self:isStopThread() or 
        self:getMainSceneController():isPlayerWait() or
        self:getCountWait() then
    	return true
    end
    return false
end
-- 特殊指令流
function DataflowController:ExeSpecailStep()

end
-- 一步步执行正常数据流
function DataflowController:exeNormalStep()
    -- 阻塞
    self:setCountWait(true)

    if self:getFunctionIndex() > table.maxn(self:getFunctionList()) then
    	return 
    end
    -- 执行
    self:getFunctionList()[self:getFunctionIndex()]()
    
    -- 下一步
    if self:getStateIndex() == 1 then                                       
        self:setFunctionIndex(self:getFunctionIndex()+1)
    end
end

-----------------------------1 函数注册(直接添加) ---------------------------------
function DataflowController:initFunctionList()
    self.m_function_list = {
        handler(self,self.statJudgment),
        handler(self,self.move_attack),
        handler(self,self.back)} 
end

----------------------------- 2 数据流流程(直接添加) ---------------------------------

-- 1.状态判断
function DataflowController:statJudgment()

    -- 得到状态数据
    local state_list = self:getDataflow():getDataflow_state()
    local isAlive = state_list[DATAFLOW.isAlive]
    -- 得到实体控制器
    local figureController = self:getMainSceneController():getFigureByFigureNum(state_list[DATAFLOW.attaker])
      
    -- 状态全部完成
--    if table.maxn(state_list.state) == 0 then
--        local isAliveInfo = {[DATAFLOW.attackerController]=figureController,[DATAFLOW.isAlive]=isAlive}
--
--        self:statJudgmentFunc(isAliveInfo)
--    	return 
--    end
    
    -- 状态执行之前清空状态列表
    figureController:getBuffController():removeAllBuff()
    -- 一个状态后的回调函数
    local isAliveInfo = {[DATAFLOW.attackerController]=figureController,[DATAFLOW.isAlive]=isAlive}
    local finishFunc = handler(self,self.statJudgmentFunc)
    figureController:stateJudgment({data = state_list.state,finishFunc = finishFunc,isAliveInfo = isAliveInfo})
end

-- 2.结合move和attack函数（结合函数模板）
function DataflowController:move_attack()

    -- 得到数据
    local move_attack = self:getDataflow():getDataflow_move_attack()

    -- 先检查是否有被攻击者
    if not move_attack[DATAFLOW.target] then
    	self:setCountWait(false)
    	return 
    end

    -- 转化
    local move_attack_list = {}
    move_attack_list[DATAFLOW.attaker] = move_attack[DATAFLOW.attaker]
    move_attack_list[DATAFLOW.target]= {}
    for key, var in pairs(move_attack[DATAFLOW.target]) do
        -- 结合函数
        local func = {handler(self,self.move),handler(self,self.attack)}
        table.insert(move_attack_list[DATAFLOW.target],{target=var,func = func})
    end
    
    -- 返回
    local date = self:moveAttackActionStep(move_attack_list)

    if not date then
        return
    end
    
    -- 只取一个攻击者（目前）
    local attackController = self:getMainSceneController():getFigureByFigureNum(date[DATAFLOW.attaker][1])
    local attackerInfo = {[DATAFLOW.attackerController]=attackController,[DATAFLOW.skillid]=move_attack[DATAFLOW.skillid]}
    local targetInfo  = date.target.target
    local func_list = date.target.func
    
    self:ExtContinue(attackerInfo,targetInfo,func_list)
end
-- 3.回来
function DataflowController:back()
    -- 得到数据
    local move_back = self:getDataflow():getDataflow_move_back()
    -- 得到实体
    local attackController = self:getMainSceneController():getFigureByFigureNum(move_back)
    
    -- 回来前
    local backFunc = cc.CallFunc:create(function()self:backFunc(attackController)end)
    
    -- 回来时
    local subPos = attackController:getDistanceFromOrigin().subPos
    -- 人物反向
    attackController:setFigureRevese(subPos)
    local distance = attackController:getDistanceFromOrigin().distance
    local time = distance/attackController:getMoveSpeed()
    local action = cc.MoveBy:create(time,subPos)
    -- 人物反向
    local func1 = cc.CallFunc:create(function()self:backAfter(attackController,subPos)end)
    
    -- 回来后
    local func2 = cc.CallFunc:create(function()self:executionOverFunc(attackController)end)

    local sequence = cc.Sequence:create(backFunc,action,func1,func2)
    
    self:ExeBack(attackController,sequence)
end

-- 一步步执行
function DataflowController:moveAttackActionStep(date_list)

    local attacker = date_list[DATAFLOW.attaker]
    local target = date_list[DATAFLOW.target][self:getStateIndex()] 

    if not date_list[DATAFLOW.target][self:getStateIndex()] then                    -- 执行下一步
        -- 判断攻击者是否死亡
        self:dieJudgment(date_list[DATAFLOW.target][self:getStateIndex()-1][DATAFLOW.target])
        -- 解除阻塞
        self:setCountWait(false)
        -- 同状态计数器默认
        self:setStateIndex(1)
        -- 攻击全部完成
        local controller = self:getMainSceneController():getFigureByFigureNum(attacker[1])
        controller:moveAttackFinish()       
        return false
    end    

    -- 状态计数加一(下一状态)
    self:setStateIndex(self:getStateIndex()+1)   

    return {[DATAFLOW.attaker]=attacker,[DATAFLOW.target] = target}
end

---------------------------- 结合函数  ----------------------------------
-- 移动到指定位置
function DataflowController:move(attackInfo,targetInfo)
    -- 移动只会取一个
    local targController = self:getMainSceneController():getFigureByFigureNum(targetInfo[1][DATAFLOW.figureNum])
    local movePos_moveTime = self:getMoveAndTime(attackInfo,targController)
    -- 移动动作
    local action = cc.MoveTo:create(movePos_moveTime.moveTime,movePos_moveTime.movePos)
    -- 移动状态设置
    local moveStateFunc = cc.CallFunc:create(function()self:moveStateFunc(attackInfo[DATAFLOW.attackerController])end)
    -- 移动的时间设置
    self:setMoveTime(action:getDuration())
    
    return {moveStateFunc,action}
end
-- 攻击
function DataflowController:attack(attackInfo,target)
    
    -- 针对攻击方(根据技能id返回不同的call)
    local targetController = {}
    for key, var in pairs(target) do
        local varController = self:getMainSceneController():getFigureByFigureNum(var[DATAFLOW.figureNum])
        table.insert(targetController,varController)
    end
    local call1 = self:fetchAttackCall(attackInfo,targetController)
    -- 攻击停留时间
    local delaytime = cc.DelayTime:create(1.8)
    
    -- 针对防御方
    -- 前面的移动延时
    local moveDelayTime = self:getMoveTime()
    -- 技能准备延时(可能没有)
    -- local attackPreDelayTime = 
    -- 技能持续时间
    local attackTime = call1.callSkillDelayTime:getDuration()
    -- 受伤延时
    local targetDelayTime = 0.5
    
    local call2 = {}
    for key, var in pairs(target) do
        local tarController = self:getMainSceneController():getFigureByFigureNum(var[DATAFLOW.figureNum])
        local param = {[DATAFLOW.target]=tarController,[DATAFLOW.skillid]=attackInfo[DATAFLOW.skillid],continueTime=attackTime-targetDelayTime,state = var.state,hurt=var.hurt}
        local call = cc.CallFunc:create(function() self:attackHurtFunc(param) end)
        local delayTime = cc.DelayTime:create(moveDelayTime+targetDelayTime+attackTime)
        local sequence = cc.Sequence:create(delayTime,call)
        table.insert(call2,{target = tarController,action = sequence})
    end
    
    
    -- 攻击，攻击停留时间，受伤
    return {call1.func,delaytime,call2}
    
end

---------------------- 执行  ------------------------
-- 执行完成之后
function DataflowController:ExeEnd()
    self:setCountWait(false)
end
-- 执行连续动作
function DataflowController:ExtContinue(attackInfo,targetInfo,func_list)
    
    local attackController = attackInfo[DATAFLOW.attackerController]
    
    -- 得到action列表
    local action_list = {}
    for key, func in pairs(func_list) do
        for k, action in pairs(func(attackInfo,targetInfo)) do
            table.insert(action_list,action)
        end
    end
    
    -- 取出两种不同的action
    local action1 = {}
    local action2 = {}

    action2 = action_list[#action_list]
    table.remove(action_list,#action_list)
    action1 = action_list
    -- 回调
    local func = cc.CallFunc:create(handler(self,self.ExeEnd))
    table.insert(action1,func)
    
    -- attcker播放
    local sequence = transition.sequence(action1)
    attackController:controllerRunAction(sequence)
    
    -- target播放
    for key, action in pairs(action2) do
        action[DATAFLOW.target]:controllerRunAction(action['action'])
    end
end
-- 执行返回
function DataflowController:ExeBack(attackController,sequence)
    attackController:controllerRunAction(sequence)
end
--------------------------- 回调  --------------------------------
-- 状态判断全部完成的回调函数
function DataflowController:statJudgmentFunc(isAliveInfo)
    self:setCountWait(false)
    -- 攻击者是否死亡死亡
    if isAliveInfo[DATAFLOW.isAlive] then
    	return
    end
    -- 跳过直接执行返回函数
    local figureController = isAliveInfo[DATAFLOW.attackerController]
    print(figureController:getFigureNum().."===========================状态死亡========================")
    figureController:die()
    self:executionOverFunc(figureController)
    -- self:setFunctionIndex(#self:getFunctionList())
--    local figurenuminfolist = {{[DATAFLOW.figureNum]=isAlive[DATAFLOW.attackerController]:getFigureNum(),[DATAFLOW.isAlive]=isAlive.isAlive}}
    -- self:dieJudgment(figurenuminfolist)
end

-- 死亡判断
function DataflowController:dieJudgment(figurenuminfolist)
    -- local figureControllerLIst = self:getMainSceneController():getFigureControllerList()
    for key, figurenuminfo in pairs(figurenuminfolist) do
        if not figurenuminfo[DATAFLOW.isAlive] then
            local figureController = self:getMainSceneController():getFigureByFigureNum(figurenuminfo[DATAFLOW.figureNum])
            figureController:die()
        end
    end
end
-- 目前使用时间控制
function DataflowController:fetchAttackCall(attackInfo,targetController)
    -- 将要移动到的位置和消耗的时间
    local movePos_moveTime = self:getMoveAndTime(attackInfo,targetController[1])

    -- 回调与回调事件数组
    local call = {}
    
    -- 平均的延时时间(当一个人物同时给三个人释放技能时，求一个平均延时时间)
    local skillContinueTime=0
    local posToList = {}
    for key, var in pairs(targetController) do
        skillContinueTime = skillContinueTime + attackInfo[DATAFLOW.attackerController]:getSkillController():getContinueTimeBefore(attackInfo[DATAFLOW.skillid],var,movePos_moveTime.movePos)
        table.insert(posToList,var:getPosition())
    end
    skillContinueTime = skillContinueTime/#targetController
    
    -- 回调延时
    call.callSkillDelayTime = cc.DelayTime:create(skillContinueTime)
    -- 回调
    local param = {[DATAFLOW.posFrom]=movePos_moveTime.movePos,[DATAFLOW.skillid]=attackInfo[DATAFLOW.skillid],continueTime=skillContinueTime,[DATAFLOW.posTo] = posToList}
    local attackController = attackInfo[DATAFLOW.attackerController]
    local func = cc.CallFunc:create(function() self:attackFunc(attackController,param) end)

    call.func = func  
    return call
end
-- 攻击回调
function DataflowController:attackFunc(attackController,param)   
    
    -- 实体动画
    attackController:skill(param)
    
end
-- 移动前
function DataflowController:moveStateFunc(attackerController)
    attackerController:move()
end
-- 返回前
function DataflowController:backFunc(attackerController)
    attackerController:back()
end
-- 返回后
function DataflowController:backAfter(attackController,subPos)
    -- 人物反向
    attackController:setFigureRevese(subPos)
end
-- 受伤回调
function DataflowController:attackHurtFunc(param)
    
    -- 实体动画
    if true then
        local targetController = param[DATAFLOW.target]
    	-- 实体动画播放(有问题)
        local count = 1 --targetController:getSkillController():getSkillPlayCount()
        local hurt  = param.hurt
    	local hurtList = {}
    	-- 伤害封装
    	for var=1,count do
    	   -- test(根据技能伤害)                                                 
           local hurt = hurt/count
            table.insert(hurtList,hurt)
    	end
        targetController:hurtJudgment({hurtList=hurtList,state = param[DATAFLOW.state]})
    end
    
end

-- 一次完整的count
function DataflowController:executionOverFunc(attackController)
    -- 重置所有
    self:backDefault(attackController)
    -- 再次请求一次count
    self:getMainSceneController():exeCount()
end

function DataflowController:backDefault(attackController)
    -- 状态待机
    attackController:daiji()
    -- 等待
    self:setCountWait(false)
    -- 流程函数计数器
    self:setFunctionIndex(1)
    -- 流程状态计数器
    self:setStateIndex(1)
end
function DataflowController:getMoveAndTime(attackInfo,targController)
    local movePos_moveTime = self:getMainSceneController():getMoveAndTime(attackInfo[DATAFLOW.attackerController],targController)
    return movePos_moveTime
end
function DataflowController:setMainSceneController(MainsecenController)
    self.m_mainSceneController = MainsecenController
end
function DataflowController:getMainSceneController()
    return self.m_mainSceneController
end
function DataflowController:getDataflow()
    return self.m_dataflow
end
function DataflowController:getFunctionList()
    return self.m_function_list
end
function DataflowController:setFunctionIndex(index)
    self.m_function_index = index
end
function DataflowController:getFunctionIndex()
    return self.m_function_index
end
-- 同一状态下的多次
function DataflowController:getStateIndex()
    if not self.m_state_index then
    	self.m_state_index = 1
    end
    return self.m_state_index
end
function DataflowController:setStateIndex(index)
    self.m_state_index = index
end
function DataflowController:getCountWait()
    if not self.m_is_CountWait then
    	self.m_is_CountWait = false
    end
    return self.m_is_CountWait
end
function DataflowController:setCountWait(flag)
    self.m_is_CountWait = flag
end
function DataflowController:setMoveTime(time)
    self.m_movetime = time
end
function DataflowController:getMoveTime()
    return self.m_movetime
end
function DataflowController:isStopThread()
    if not self.m_is_stopThread then
        self.m_is_stopThread = false
    end
    return self.m_is_stopThread
end
function DataflowController:setStopThread(flag)
    self.m_is_stopThread = flag
end

return DataflowController