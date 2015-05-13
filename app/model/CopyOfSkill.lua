
local Skill = class("Skill",function()
    return display.newSprite()
end)

function Skill:ctor()
    -- 速度
    self.m_speed = 0
    -- id
    self.m_skillId = 0
    -- 方向
    self.m_direction = 1
    
    self:init()
end

function Skill:init()
    
    self:setDirection(self:getDirection())
end

function Skill:playSkill(param)

    local rotation  = param.rotation
    local time      = param.time
    local pos       = param.pos
    
    local sprite = display.newSprite()
    self:addChild(sprite)
    sprite:setRotation(rotation)
    
    local actionList = {}
    
    -- 1.1.子弹动作
    local actionBullet = cc.MoveTo:create(time,param.pos)  
    table.insert(actionList,actionBullet)  
    -- 1.2子弹动画
    local animation = display.getAnimationCache(self:getSkillId().."_skill")
    transition.playAnimationForever(sprite,animation)     
    
    -- 2.子弹释放完成后的特效
    local animationBulletAfter = display.getAnimationCache(self:getSkillId().."_skill_effect")
    local animateBullteAfter = cc.Animate:create(animationBulletAfter)
    local skillInfo = self:getSkillInfo(self:getSkillId())
    for var=1,skillInfo.count do
        local animate = animateBullteAfter:clone()
        table.insert(actionList,animate)
    end

    -- 3.回调
    local callFunc = cc.CallFunc:create(handler(self,self.func)) 
    table.insert(actionList,callFunc)
    
    local sequence = transition.sequence(actionList)
    sprite:runAction(sequence)
end

function Skill:setParam(skillId)
    local data = self:getSkillInfo(sskillId)
    self:setSpeed(data.speed)
    self:setSkillId(skillId)
end
function Skill:getSkillInfo(skillId)
    return {
        [2001]  = {speed = 500,count=1,hurt=100},                          -- 近战攻击
        [2002]  = {speed = 500,count=1,hurt=100,moveTo=cc.p(6,3)},         -- 近战范围
        [2003]  = {speed = 500,count=2,hurt=100,moveTo=cc.p(0,0)},         -- 远程普攻
        [2004]  = {speed = 0,count=2,hurt=1000,moveTo=cc.p(0,0)}
    }
end

function Skill:func(e)
    e:removeFromParent()
end
function Skill:setSpeed(speed)
    self.m_speed = speed
end
function Skill:getSpeed()
    return self.m_speed
end
function Skill:setSkillId(skillId)
    self.m_skillId = skillId
end
function Skill:getSkillId()
    return self.m_skillId
end
function Skill:setDirection(direction)
    self.m_direction = direction
end
function Skill:getDirection()
    return self.m_direction
end
return Skill
