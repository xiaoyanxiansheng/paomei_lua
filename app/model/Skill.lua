local SkillDefManager = DataManager.getManager("SkillDefManager")
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
    -- 技能属性数组
    self.m_skillParam_list = nil

    self:init()
end

function Skill:init()
    self:setDirection(self:getDirection())
end
-- 单体攻击
function Skill:playSkillDan(param)

    local sprite = display.newSprite()
    self:addChild(sprite)
    
    -- 行动列表
    local actionlist = {}
    -- 1.子弹释放action
    self:playBullet(actionlist,sprite,param)   

    -- 2.子弹释放完成后的特效action
    self:playBulletEffect(actionlist)

    -- 3.回调action
    local callFunc = cc.CallFunc:create(handler(self,self.func)) 
    table.insert(actionlist,callFunc)

    -- 执行action
    local sequence = transition.sequence(actionlist)
    sprite:runAction(sequence)
end
-- 范围攻击
function Skill:playSkillRange(param)

    -- 延时
    

    local sprite = display.newSprite()
    sprite:setPosition(param.pos)
    self:addChild(sprite)

    -- 行动列表
    local actionlist = {}

    -- 延时播放
--    local delayTime = 0.1
--    local delayTimeCall = cc.DelayTime:create(delayTime)
--    table.insert(actionlist,delayTimeCall)

    -- 1.特效action
    self:playBulletEffect(actionlist)

    -- 2.回调action
    local callFunc = cc.CallFunc:create(handler(self,self.func)) 
    table.insert(actionlist,callFunc)

    -- 执行action
    local sequence = transition.sequence(actionlist)
    sprite:runAction(sequence)
end
-- 子弹效果
function Skill:playBullet(actionlist,sprite,param)
    local rotation  = param.rotation
    local time      = param.time
    local posfrom   = param.pos[1]
    local posto   = param.pos[2]
    -- 角度
    sprite:setRotation(rotation)
    sprite:setPosition(posfrom)
    -- 子弹动作
    local actionBullet = cc.MoveTo:create(time,posto)
    table.insert(actionlist,actionBullet)
    
    -- 子弹动画
    local animation = display.getAnimationCache(self:getSkillResourceName())
    if not animation then
    	return
    end
    transition.playAnimationForever(sprite,animation)
    
end
-- 范围容器
function Skill:playContainerRange(pos)
    if self:isCsbPlay() == 1 then
        self:playerSkillByCcs()
        else
        -- 范围容器表现
        local containerRange = self:getContainerRange()
        containerRange:setPosition(pos)

        local animation = display.getAnimationCache(self:getSkillResourceName())
        transition.playAnimationForever(containerRange,animation)
    end   
end
function Skill:playBulletEffect(actionlist)
    
    local animationBulletAfter = display.getAnimationCache(self:getEffectResourceName())
    if not animationBulletAfter then
    	return
    end
    local animateBullteAfter = cc.Animate:create(animationBulletAfter)
    for var=1,self:getSkillPlayCount() do
        local animate = animateBullteAfter:clone()
        table.insert(actionlist,animate)
    end
end

-- 设置技能属性数组
function Skill:setSkillParam(skillId,count)
--    {
--        [2001]  = {type=1,speed = 500,count=1,hurt=100},                          -- 近战攻击
--        [2002]  = {type=1,speed = 500,count=1,hurt=100 ,moveTo=cc.p(0,0)},        -- 近战范围
--        [2003]  = {type=2,speed = 0  ,count=2,hurt=100 ,moveTo=cc.p(0,0),delay=0},-- 远程普攻
--        [2004]  = {type=2,speed = 0  ,count=2,hurt=1000,moveTo=cc.p(0,0)}
--    }
    self:setSkillPlayCount(count)
    local skillInfo = SkillDefManager:getSkillById(skillId)
    self:setSkillInfoParamList(skillInfo)
end

-- 得到技能资源信息(目前测试)
function Skill:getSkillResourceInfo()
    local skillConfig = {
        -- start --
        --[[
            isplay：用于区别播放csb还是序列帧，目前没有统一,
        --]]
        -- end --
        [10001] = {isCSb = 0,skillName = "0",skillEffect="0",skillType = 1,discription = "单体攻击"},
        [10002] = {isCSb = 0,skillName = "2001_skill",skillEffect="2001_skill_effect",skillType = 1,discription = "单体攻击,中毒"},
        [10003] = {isCSb = 1,skillName = "2003_skill",skillEffect="2003_skill_effect",skillType = 2,discription = "全体，降功"},
        [10004] = {isCSb = 0,skillName = "2004_skill",skillEffect="0",skillType = 2,discription = "全体回血"},
        [10005] = {isCSb = 0,skillName = "2002_skill",skillEffect="2002_skill_effect",skillType = 1,discription = "单体眩晕"},
    }
    return skillConfig
end
-- 得到技能资源名
function Skill:getSkillResourceName()
    return self:getSkillResourceInfo()[self:getSkillId()].skillName
end
-- 得到技能特效名
function Skill:getEffectResourceName()
    return self:getSkillResourceInfo()[self:getSkillId()].skillEffect
end
-- 得到技能type
function Skill:getSkillType()
    return self:getSkillResourceInfo()[self:getSkillId()].skillType
end
-- 是否播放csb动画
function Skill:isCsbPlay()
    return self:getSkillResourceInfo()[self:getSkillId()].isCSb
end
-- 技能播放次数
function Skill:getSkillPlayCount()
    return self.m_skillPlayCount
end
-- 得到技能的移动速度
function Skill:getSkillSpeed()   
    return self:getSkillInfoParamList()[DATAFLOW.skillSpeed] or 1000 
end
-- 得到技能描述
function Skill:getSkillDiscription()
    return self:getSkillResourceInfo()[self:getSkillId()][DATAFLOW.discription]
end
-- 得到技能id
function Skill:getSkillId()
    return self:getSkillInfoParamList()[DATAFLOW.id]
end
-- 得到技能icon
function Skill.getSkillResourceIconName(skillId)
    -- return Skill.getSkillResourceInfo():getSkillResourceIConName(skillId)..".icon.png"
end
function Skill:getSkillMovePos()
    local skillRange = self:getSkillInfoParamList()[DATAFLOW.skillRange]
    local moveTo = {}
    if skillRange == 1 then
        return false
    elseif skillRange == 2 then
    	moveTo = cc.p(display.cx,display.cy)
    elseif skillRange == 3 then
    	moveTo = cc.p(0,0)
    elseif skillRange == 4 then
    	moveTo = cc.p(0,0)
    end
    return moveTo
end
function Skill:func(e)  
    e:removeFromParent()
end
function Skill:moveAttackFinish()
    self:getContainerRange():setVisible(false)
   -- self.m_skillContainerRange:setVisible(false)
--    self:getPlayContainer():removeFromParent()
--    self.m_skillContainerRange = nil
end
-- test得到技能动画
function Skill:playerSkillByCcs(pos)
    local pos = cc.p(display.cx-30,display.cy-60)
    -- 节点
    local node = cc.CSLoader:createNode("ccs/skill_0002.csb")
    self:addChild(node)
    node:setPosition(pos)
    -- 动画
    local action = cc.CSLoader:createTimeline("ccs/skill_0002.csb")
    node:runAction(action)
    -- 用帧数来控制
    action:gotoFrameAndPlay(1,100,false)
    if self:getDirection() ==1 then
   	    node:setScaleX(1)
    else
        node:setScaleX(-1)
    end 
end
function Skill:setDirection(direction)
    self.m_direction = direction
end
function Skill:getDirection()
    return self.m_direction
end
function Skill:getPlayContainer()
    return self.m_skillContainerRange
end
function Skill:getContainerRange()
    if not self.m_skillContainerRange then
    	self.m_skillContainerRange = display.newSprite()
        self:addChild(self.m_skillContainerRange)
    end
    return self.m_skillContainerRange
end
function Skill:setSkillInfo(skillInfo)
    self.m_skillInfo = skillInfo
end
function Skill:getSkillInfo_()
    return self.m_skillInfo
end
function Skill:setSkillInfoParamList(paramList)
    self.m_skillParam_list = paramList
end
function Skill:getSkillInfoParamList()
    return self.m_skillParam_list
end
function Skill:setSkillPlayCount(count)
    self.m_skillPlayCount = count
end
return Skill
