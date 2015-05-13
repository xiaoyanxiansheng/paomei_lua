local BuffController  = require("app.controller.BuffController")
local SkillController = require("app.controller.SkillController")

local FigureController = class("FigureController")

function FigureController:ctor(figure)
    -- 
    self.m_figure = figure
    -- 
    self.m_skillController = nil
    
    self:init()
end

function FigureController:init()
    
end

-- 能否被鼠标点击
function FigureController:isOnclicked()
    if self:getDirection() == -1 then
    	return true
    end
    return false
end
-- 运行动画
function FigureController:controllerRunAction(sequence)
    -- local sequnceClone = sequence:clone()
    -- 人物动画
    self:getFigure():runAction(sequence)
    -- 技能移动（buff）
    -- self:getSkillController():runAction(sequnceClone)
end
-- 攻击/技能
function FigureController:skill(param)

    local skillController = self:getSkillController()
    -- 播放技能
    skillController:playSkill(param)
    -- 技能描述
    self:getMainController():setSkillDiscription(skillController:getSkillDiscription())
    
    -- 实体动画
    local skillType = self:getSkillController():getSkillType()    
    if skillType == 1 then
        self:getFigure():stateChange(EVENT_STATE.jineng1er)
    else
        self:getFigure():stateChange(EVENT_STATE.jineng2er)
    end
    
end
-- 受伤
function FigureController:hurt(dataFisrt)

    -- 受伤数据处理
    self:getFigure():changeHp(dataFisrt[DATAFLOW.hurt])

    -- 受伤ui处理    
    self:hurtUi(dataFisrt)
    self:getFigure():stateChange(EVENT_STATE.shoujidaer,dataFisrt)

end
-- 死亡
function FigureController:die()
    self:getFigure():stateChange(EVENT_STATE.siwanger)
end
-- 行走
function FigureController:move()
    self:getFigure():stateChange(EVENT_STATE.paobuer)
end
function FigureController:daiji()
    self:getFigure():stateChange(EVENT_STATE.daijier)
end
-- 返回
function FigureController:back()
    self:getFigure():stateChange(EVENT_STATE.paobuer)
end
-- 状态执行
function FigureController:stateJudgment(param)
    
    if #param.data == 0 then
    	param.finishFunc()
    	return
    end
    
    -- 数据的处理(这里处理与伤害有关的数据)
    local dataFisrt = param.data[1] 
    dataFisrt.param = param
    table.remove(param.data,1)

    -- 回调
    local func = handler(self,self.stateFunc)    
    dataFisrt.func = func

    -- 伤害处理
    self:hurt(dataFisrt)
    -- buff表现
    self:addBuff(dataFisrt.state)
end
-- 受伤状态执行
function FigureController:hurtJudgment(param)
    -- 伤害处理
    self:hurtHurtJudgment({hurtList=param.hurtList})
    -- buff处理
    self:hurtBuffJudgment(param.state)
end
function FigureController:hurtHurtJudgment(param)
        
    -- 伤害处理
    if #param.hurtList == 0 then
        return
    end

    local hurtFisrt = param.hurtList[1]
    table.remove(param.hurtList,1)
    -- 回调
    local func = handler(self,self.hurtFunc)    

    -- 回调数据
    local param_ = {func=func,hurt=hurtFisrt,hurtList=param.hurtList,param=param}

    -- 伤害处理
    self:hurt(param_)
end
function FigureController:hurtBuffJudgment(param)   
    for key, var in pairs(param) do
        self:getBuffController():addBuff(self,var[1])
    end
end
-- 状态检查
function FigureController:checkState()
    print("nihao")
end
----------------- 回调  --------------
function FigureController:stateFunc(param)
    self:stateJudgment(param)
end
function FigureController:hurtFunc(param)
    self:hurtHurtJudgment(param)
end
------------------- ui处理  ----------
--ui处理
function FigureController:hurtUi(data)
    self:getFigure():getHurtSystem():playerWordUp({word=data.hurt},self:getDirection())
end
-- 添加技能系统(node是技能添加的节点)
function FigureController:addSkillSystem(node)
    -- 技能表现
    self:getFigure():addSkillSystem()
    local skillSystem = self:getFigure():getSkillSystem()
    skillSystem:setDirection(self:getDirection())
    node:addChild(skillSystem,100)
    -- 技能控制
    self.m_skillController = SkillController.new(skillSystem)
end
-- 添加buff控制系统
function FigureController:addBuffSystem()
    self.m_buffController = BuffController.new()
end
-- 添加buff
function FigureController:addBuff(buffId)
    self:getBuffController():addBuff(self,buffId)
end
function FigureController:addFigureToNode(node,point)

    node:addChild(self:getFigure())
    
    local pos = self:getMainController():pointToPos(point)
    -- 具体位置
    self:getFigure():setPosition(pos.x,pos.y)
    -- 点坐标
    self:getFigure():setPointPosition(point)
end
function FigureController:getFigure()
    return self.m_figure
end
-- 返回boundingBox
function FigureController:getFigureBoundingBox()
    return self:getFigure():getBoundingBox()
end
-- 设置点坐标
function FigureController:setPointPosition(point)
    self:getFigure():setPointPosition(point)
end
-- 得到点坐标
function FigureController:getPointPosition()
    return self:getFigure():getPointPosition()
end
-- 得到默认位置
function FigureController:getPointPosition_m()
    return self:getFigure():getPointPosition_m()
end
-- 当前到原点的距离
function FigureController:getDistanceFromOrigin()
    
    local from = self:getPosition()
    local to = self:getMainController():pointToPos(self:getPointPosition_m())    
    local subPos = cc.pSub(to,from)
    local distance = math.sqrt(subPos.x*subPos.x+subPos.y*subPos.y)
    return {subPos=subPos,distance=distance}
end
function FigureController:getPosition()
    local pos = cc.p(self:getFigure():getPosition())
    return pos
end
-- 人物反向
function FigureController:setFigureRevese(subPos)
    if subPos.x == 0 then
    	return
    end
    self:setDirection(-self:getDirection())
end
-- 得到实体编号
function FigureController:getFigureNum()
    return self:getFigure():getFigureNum()
end
function FigureController:getDirection()
    return self:getFigure():getDirection()
end
function FigureController:setMainController(mainController)
    self.m_mainController = mainController
end
function FigureController:getMainController()
    return self.m_mainController
end
-- 属性设置
function FigureController:configAttribute(param)
    self:getFigure():configAttribute(param)
end
-- 技能设置
function FigureController:setSkillParam(skillId,count)
    self:getSkillController():setSkillParam(skillId,count)
end
function FigureController:getSkillController()
    return self.m_skillController
end
function FigureController:getBuffController()
    return self.m_buffController
end
function FigureController:moveAttackFinish()
    self:getSkillController():moveAttackFinish()
end
function FigureController:getMoveSpeed()
    return self:getFigure():getMoveSpeed()
end
function FigureController:setDirection(direction)
    self:getFigure():setDirection(direction)
end
function FigureController:setHp(hp)
    self:getFigure():setHp(hp)
end

return FigureController