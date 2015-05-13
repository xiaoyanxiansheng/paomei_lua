local SkillController = class("SkillController")

function SkillController:ctor(skill)
    --
    self.m_skill = skill
    
    self:init()
end

function SkillController:init()
    
end

-- 播放技能
function SkillController:playSkill(param)
    
    local skillType = self:getSkillType()
    -- 单体技能
    if skillType == 1 then
        self:playSkillDan(param)
    else
    -- 范围技能
        self:playSkillRange(param)
    end
    
end

-- 单体技能
function SkillController:playSkillDan(param)

    for key, to in pairs(param[DATAFLOW.posTo]) do   
        self:setAnimationParam(param[DATAFLOW.posFrom],to,param[DATAFLOW.continueTime])
        -- 释放技能子弹
        self:getFigure():playSkillDan({time=self:getContinueTime(),pos={param[DATAFLOW.posFrom],to},rotation=self:getSkillRotation()})
    end
end
-- 范围技能
function SkillController:playSkillRange(param)
    -- 要指定位置
    local pos = cc.p(display.cx,display.cy)
    
    -- 1.播放范围容器
    self:getFigure():playContainerRange(pos)
    
    -- 2.播放技能效果
    for key, to in pairs(param[DATAFLOW.posTo]) do 
        -- 释放技能子弹
        self:getFigure():playSkillRange({pos=to})
    end
    
end


-- 播放受伤
function SkillController:playHurt(skillId)
    -- 特效
end
-- 设置技能属性
function SkillController:setSkillParam(skillId,count)
    self:getFigure():setSkillParam(skillId,count)
end
function SkillController:setAnimationParam(posFrom,posTo,continueTime)

    local time = continueTime
    -- 角度
    local rotation = self:fetchRotation(posFrom,posTo)    
    
    -- 时间
    self:setContinueTime(time)
    -- 角度
    self:setSkillRotation(rotation)
    -- 技能节点位置
end
function SkillController:fetchRotation(posFrom,Posto)
    local pos1 = posFrom
    local pos2 = Posto
    local subPos = cc.pSub(pos2,pos1)
    local rotation =  math.deg(math.atan2(subPos.y,subPos.x))
    -- 得到要攻击的目标在攻击者的哪个象限
    
    return -rotation
end
--function SkillController:getXiangxian(controller)
--    local pos1 = self:getPosition()
--    local pos2 = controller:getPosition()
--    if pos2.x-pos1.x>0 and pos2.y-pos1.y>=0 then
--    	return 1
--    elseif pos2.x-pos1.x<0 and pos2.y-pos1.y>=0 then
--        return 2
--    elseif pos2.x-pos1.x<=0 and pos2.y-pos1.y<0 then
--        return 3
--    elseif pos2.x-pos1.x>0 and pos2.y-pos1.y<=0 then
--        return 4
--    end
--end
function SkillController:getContinueTimeBefore(skillId,controller,movePos)
    -- 加载参数
    local pos1 = movePos
    local pos2 = controller:getPosition()
    local subPos = cc.pSub(pos2,pos1)
    local time = 0
    if self:getSkillSpeed() ~= 0 then
    	time = controller:getMainController():getDistanceByNodeSubPos(subPos)/self:getSkillSpeed()
    end
    return time
end
function SkillController:runAction(sequence)
    self:getFigure():runAction(sequence)
end
function SkillController:getFigure()
    return self.m_skill
end

function SkillController:setPosition(pos)
    self:getFigure():setPosition(pos)
end
function SkillController:setSubPos(pos)
    self.m_subPos = pos
end
function SkillController:getSubPos()
    return self.m_subPos
end
function SkillController:setSkillRotation(rotation)
    self.m_skillRotation = rotation
end
function SkillController:getSkillRotation()
    return self.m_skillRotation
end
function SkillController:setContinueTime(time)
    self.m_continueTime = time
end
function SkillController:getContinueTime()
    return self.m_continueTime
end
function SkillController:getPosition()
    return cc.p(self:getFigure():getPosition())
end
function SkillController:moveAttackFinish()
    self:getFigure():moveAttackFinish()
end
function SkillController:getSkillPlayCount()
    return self:getFigure():getSkillPlayCount()
end
function SkillController:getSkillMovePos()
    return self:getFigure():getSkillMovePos()
end
function SkillController:getSkillType()
    return self:getFigure():getSkillType()
end
function SkillController:getSkillSpeed()
    return self:getFigure():getSkillSpeed()
end
function SkillController:getSkillDiscription()
    return self:getFigure():getSkillDiscription()
end

return SkillController