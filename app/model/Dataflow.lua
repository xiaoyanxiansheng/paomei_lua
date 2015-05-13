--[[
    数据常量
--]]
DATAFLOW = {
    attaker     = "attacker",
    target    = "target",
    helper      = "helper",
    skillid     = "skillId",
    hurt        = "hurt",
    state       = "state",  
    
    figureNum   = "figureNum" ,
    attackerController = "attackerController",
    targetController  = "targetController",
    posFrom = "posFrom",
    posTo   = "posTo",
    continueTime = "continueTime",
    direction   = "direction",
    skillType   = "skillType",
    count       = "count",
    skillRange  = "skillRange",
    skillSpeed  = "skillSpeed",
    id = "id",
    isManipulate = "isManipulate",
    maxHp       = "maxHP",
    hp          = "hp",
    isAlive     = "isAlive",
    info        = "info",
    discription = "discription",
     --输赢
    ATTACKER_WIN = 1,
    DEFENDER_WIN = 2,
    CONTINUE = 3,
    ROUND_OUT = 4,
    isCoolDown = "isCoolDown",
}

-- 数据流基类 --
local Dataflow = class("Dataflow")

function Dataflow:ctor()
    
    -- 数据流
    self.m_dataflow = nil
    -- 实体的位置信息
    self.m_figure_position = {}
    
    self:init()
end

function Dataflow:init()

end

----------------------------------- 解析(添加解析)  ---------------------------------
-- 得到状态_or伤害信息
function Dataflow:getDataflow_state()

    -- 得到数据流
    local dataflow = self:getDataFlow()
    -- 不存在状态
    if not dataflow[DATAFLOW.attaker][1][DATAFLOW.state] then
        return false
    end
    
    local state_list  = {}
    -- 目前只使用一个攻击者
    -- 实体
    state_list[DATAFLOW.attaker] = dataflow[DATAFLOW.attaker][1][DATAFLOW.figureNum]
    state_list[DATAFLOW.hp]         = dataflow[DATAFLOW.attaker][1][DATAFLOW.hp]
    state_list[DATAFLOW.isAlive]         = dataflow[DATAFLOW.attaker][1][DATAFLOW.isAlive]
    -- 状态
    state_list[DATAFLOW.state]   = {}
    for key, var in pairs(dataflow[DATAFLOW.attaker][1][DATAFLOW.state]) do
        local state = {}
        state[DATAFLOW.state] = var[1]
        state[DATAFLOW.hurt]  = var[2]
        table.insert(state_list[DATAFLOW.state],state)
    end
    
    -- test
    -- state_list = {attaker={1001},state={{state = 1,hurt=100},{state=2,hurt=200},{state=3}}}
    
    return state_list
end
-- 得到攻击移动的数据
function Dataflow:getDataflow_move_attack()
    local dataflow = self:getDataFlow()
    
    local skill_list = {}
    skill_list[DATAFLOW.attaker] = {}
    for key, var in pairs(dataflow[DATAFLOW.attaker]) do
        table.insert(skill_list[DATAFLOW.attaker],var[DATAFLOW.figureNum])
    end
    skill_list[DATAFLOW.target] = dataflow[DATAFLOW.target]
    skill_list[DATAFLOW.skillid]=dataflow[DATAFLOW.skillid]
    
    -- test
    -- skill_list = {attaker={1001},target={{1008,1002},{1009},{1009},{1009}},skillId=1003}
    
    return skill_list
end
-- 得到返回时的数据信息
function Dataflow:getDataflow_move_back()
    return self:getDataFlow()[DATAFLOW.attaker][1][DATAFLOW.figureNum]
end
---------- get set add ------------
function Dataflow:getFigurePosition()
    return self.m_figure_position
end
function Dataflow:setFigurePosition(figurePosition)
    self.m_figure_position = figurePosition
end
-- 得到数据流
function Dataflow:getDataFlow()
    return self.m_dataflow
end
-- 设置数据流
function Dataflow:setDataFlow(flow)
    self.m_dataflow = flow
end

return Dataflow