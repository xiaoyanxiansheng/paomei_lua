
-- 实体状态
FIGURE_STATE    = {
    daiji       = "daiji",  
    shengli     = "shengli",
    shoujida    = "shoujida",
    siwang      = "siwang",
    paobu       = "paobu",
    jineng1     = "jineng1",
    jineng2     = "jineng2",
}

-- 事件状态
EVENT_STATE     = {
    daijier     = "daijier",
    shenglier   = "shenglier",
    shoujidaer  = "shoujidaer",
    siwanger    = "siwanger",
    paobuer     = "paobuer",
    jineng1er   = "jineng1er",
    jineng2er   = "jineng2er",
}

-- 实体状态与事件状态的对用关系
FIGURE_EVENT_STATE  = {
    daijier     = "daiji",
    shenglier   = "shengli",
    shoujidaer  = "shoujida",
    siwanger    = "siwang",
    paobuer     = "paobu",
    jineng1er   = "jineng1",
    jineng2er   = "jineng2",
}

local Skill  = require("app.model.Skill")
local UIHurt = require("app.view.figure.UIHurt")
local UIBlood= require("app.view.figure.UIBlood")
local UIBuff = require "app.view.figure.UIBuff"

local Figure = class("Figure",function()
    return display.newSprite()
end)

function Figure:ctor(figureNum)
    -- 
    self.m_figureNum = figureNum
    
    -- 点坐标
    self.m_point_position = {}
    -- 方向
    self.m_direction = 0
    -- 移动速度（目前固定）
    self.m_moveSpeed = 500
    
    self:init()
end

function Figure:init()
    -- 添加状体机
    self:addStatusMachine_()
    -- 初始化实体的信息
    self:initInfo()
end
function Figure:initInfo()

    self:setAnchorPoint(0,0.5)

    -- 初始化实体大小ight = 
    self:setContentSize(display.width/12,display.height/6)
    -- 加入掉血系统
    self:addHurtSyste()
    -- 血量系统
    self:addBloodSystem()
    -- buff系统
    -- self:addBuffSystem()
    -- 实体初始化状态(应该由状态机来控制)
    self:initAnimation_()
end
function Figure:addHurtSyste()
    self.m_hurtSystem = UIHurt.new()
    self.m_hurtSystem:setPosition(self:getContentSize().width/2,self:getContentSize().height)
    self:addChild(self.m_hurtSystem)
    
    -- self:addChild(cc.LayerColor:create(cc.c4b(222,222,222,222),self:getContentSize().width,self:getContentSize().height))
end
function Figure:addBloodSystem()
	-- 目前血量条
	self.m_blood = UIBlood.new("img/xue_back.png","img/xue_fore.png")
	self.m_blood:setScale(1.5,1.2)
	self.m_blood:setPosition(self:getContentSize().width/2,self:getContentSize().height+30)
    self.m_blood:setAnchorPoint(0.8,0)
	self:addChild(self.m_blood)
end
function Figure:addBuffSystem(buffId)
    local buff = UIBuff.new(buffId)
    self:addChild(buff)
    return buff
end
function Figure:addSkillSystem()
    self.m_skillSystem = Skill.new()
end
function Figure:addStatusMachine_()
    --创建状态组件
    self.fsm  = {}
    cc.GameObject.extend(self.fsm):addComponent("components.behavior.StateMachine"):exportMethods()
    --设置状态机
    self.fsm : setupState({
        -- 初始状态
        initial = FIGURE_STATE.daiji,
        -- 事件和状态转换
        events  = {
            {
                name = EVENT_STATE.daijier,   
                from = {FIGURE_STATE.jineng1,FIGURE_STATE.paobu,FIGURE_STATE.shoujida,FIGURE_STATE.jineng2,FIGURE_STATE.daiji,FIGURE_STATE.siwang}, 
                to   = FIGURE_STATE.daiji},
            {
                name = EVENT_STATE.paobuer,   
                from = {FIGURE_STATE.jineng1,FIGURE_STATE.paobu,FIGURE_STATE.shoujida,FIGURE_STATE.jineng2,FIGURE_STATE.daiji,FIGURE_STATE.siwang}, 
                to   = FIGURE_STATE.paobu},
            {
                name = EVENT_STATE.siwanger,
                from = {FIGURE_STATE.shoujida,FIGURE_STATE.daiji,FIGURE_STATE.siwang},
                to   = FIGURE_STATE.siwang},
            {
                name = EVENT_STATE.shoujidaer,   
                from = {FIGURE_STATE.paobu,FIGURE_STATE.jineng1,FIGURE_STATE.jineng2,FIGURE_STATE.daiji,FIGURE_STATE.siwang},                   
                to   = FIGURE_STATE.shoujida},
            {
                name = EVENT_STATE.jineng1er, 
                from = {FIGURE_STATE.paobu,FIGURE_STATE.shoujida,FIGURE_STATE.jineng2,FIGURE_STATE.daiji,FIGURE_STATE.siwang},                                       
                to   = FIGURE_STATE.jineng1},
            {
                name = EVENT_STATE.jineng2er, 
                from = {FIGURE_STATE.paobu,FIGURE_STATE.jineng1,FIGURE_STATE.daiji,FIGURE_STATE.siwang},                                       
                to   = FIGURE_STATE.jineng2},
        },
        -- 回调函数
        callbacks = {
            ondaijier       = function (event) self:daiji   (FIGURE_STATE.daiji)                  end,
            onshenglier     = function (event) self:shengli (FIGURE_STATE.shengli)                   end,
            onshoujidaer    = function (event) self:shoujida(FIGURE_STATE.shoujida   ,event.args[1]) end,
            onsiwanger      = function (event) self:siwang  (FIGURE_STATE.siwang ,event.args[1]) end,
            onpaobuer       = function (event) self:paobu   (FIGURE_STATE.paobu)                end,
            onjineng1er     = function (event) self:jineng1 (FIGURE_STATE.jineng1 ,event.args[1]) end,
            onjineng2er     = function (event) self:jineng2 (FIGURE_STATE.jineng2 ,event.args[1]) end,
        },
    })
end

-- 状态的转变
function Figure:stateChange(event,param)  

    -- 通过事件得到将要转化的状态
    local state = FIGURE_EVENT_STATE[event]


    if self.m_state == state then
        return
    end

    self.m_state = state
    self.fsm:doEvent(event,param)
end

-------------------------- 动画播放  --------------------------
-- 待机
function Figure:daiji(state)
    self:playerAnimationByName_(state,true)
end
-- 胜利
function Figure:shengli(state)
    self:playerAnimationByName_(state,true)
end
-- 受击打
function Figure:shoujida(state,param)
    self:playerAnimationByName_(state,false,param)
end
-- 死亡
function Figure:siwang(state,param)
    self:playerAnimationByName_(state,false,param)
end
-- 跑步
function Figure:paobu(state)
    self:playerAnimationByName_(state,true)
end
-- 技能1
function Figure:jineng1(state,param)
    self:playerAnimationByName_(state,false,param)
end
-- 技能2
function Figure:jineng2(state,param)
    self:playerAnimationByName_(state,false,param)
end
-- 属性配置
function Figure:configAttribute(param)

    -- 朝向设置
    self:setDirection(param.direction)
    -- 血量设置
    self:setHp(param[DATAFLOW.maxHp])
end

function Figure:playerAnimationByName_(name,isXunhuan,param)
    local animationName = self:getAnimationName(name)
    -- 动画
    self:getAni():setAnimation(0, animationName, isXunhuan)
    -- 回调
    self:getAni():registerSpineEventHandler(function(event,e)
        if event.type == "complete" and self:getState() ~= FIGURE_STATE.paobu and self:getState() ~= FIGURE_STATE.siwang then
            self:stateChange(EVENT_STATE.daijier)
            if param and param.func then
                param.func(param.param)
            end
        end
    end,2)
end

function Figure:initAnimation_()
    local path_atlas = "models/1001/pm2_ximulai.atlas"
    local path_skeleton = "models/1001/pm2_ximulai.json"
    -- 设置动画
    self:setAni(sp.SkeletonAnimation:create(path_skeleton,path_atlas,1))
    -- 运行动画
    self:stateChange(EVENT_STATE.daijier)
end

-- 血量的增减
function Figure:changeHp(num)
    
    local nowHp = self:getHp() + num
    local nowHp = nowHp > self:getMaxHp() and self:getMaxHp() or nowHp
    self:setHp(nowHp)
end
------------ set get add ------------

function Figure:getAnimationName(name)
    return "ximulai_"..name
end
function Figure:setFigureNum(index)
    self.m_figureNum = num
end
function Figure:getFigureNum()
    return self.m_figureNum
end
function Figure:setAni(animation)
    self:addChild(animation)
    self.m_animation = animation
end
function Figure:getAni()
    return self.m_animation
end
function Figure:setPointPosition(pointPosition)
    if not self.m_m_point_position then
        self.m_m_point_position = pointPosition
    end
    self.m_point_position = pointPosition
end
function Figure:getPointPosition()
    return self.m_point_position
end
function Figure:getPointPosition_m()
    return self.m_m_point_position
end
function Figure:setDirection(direction)
    self.m_direction = direction
    self:setScaleX(direction)
end
function Figure:getDirection()
    return self.m_direction
end
function Figure:getHurtSystem()
    return self.m_hurtSystem
end
function Figure:getUIBlood()
    return self.m_blood
end
function Figure:getSkillSystem()
    return self.m_skillSystem
end
function Figure:getState()
    return self.m_state
end
function Figure:getMoveSpeed()
    return self.m_moveSpeed
end
function Figure:setHp(hp)
    if not self.m_Hp then
        self.m_maxHp = hp
    end
    -- 数据设置
    self.m_Hp = hp
    -- ui设置
    self:getUIBlood():setBloodAge(self:getHp()/self:getMaxHp()*100)
end
function Figure:getHp()
    return self.m_Hp
end
function Figure:getMaxHp()
    return self.m_maxHp
end
return Figure