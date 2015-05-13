local BattleInfo = require("src/app/gamelogic/BattleInfo")
local DataInterface = class("DataInterface")

function DataInterface:ctor()
    self.Bi = BattleInfo.new()
    self.Bi:initInfo()
end

-- 获取当前运动玩家对象
function DataInterface:fetchPlayerInfo()
    return  self.Bi:getCurrentFighter()
    --self:testPlayerInfo()
end
-- 获取数据报信息
function DataInterface:fetchReport(type,param)
    local fetch = self.Bi:fetchReport(type,param)
    
    print("======================== attaker ======================")
    dump(fetch[DATAFLOW.attaker])
    print("======================== target ======================")
    for key, var in pairs(fetch[DATAFLOW.target]) do
        dump(var)
    end
    return fetch
        --self:testFetchReport(type,param)
end
-- 获取初始位置信息
function DataInterface:fetchInitPosition()
    return self.Bi:startBattle()
    --self:testFetchInitPosition()
end
function DataInterface:isGameOver()
    return self.Bi:isGameOver()
end
-- count是否结束
function DataInterface:countOver()
    return self:testCountOver()
end
----------------------- 测试函数  ----------------------------
-- 玩家先后手数据
function DataInterface:testPlayerInfo()
    return self.m_testPlayerInfoList[self.m_testPlayerNumIndex]
end
-- 数据报数据
function DataInterface:testFetchReport(type,param)
    local dataReport = {
        -- 近战单体
        -- 远程单体
        -- 远程技能
        {attaker={{figureNum=1001,state={}},},target={{{figureNum=1011,hurt=100,helper=0,state={}},},},skillId=2001},  
        {attaker={{figureNum=1002,state={{4002,100}}},},target={{{figureNum=1010,hurt=100,helper=0,state={{4002,100}}},},{{figureNum=1009,hurt=100,helper=0,state={{4002,100}}},},{{figureNum=1008,hurt=100,helper=0,state={{4002,100}}},},},skillId=2001},                                
        {attaker={{figureNum=1007,state={{4001,100},}},},target={{{figureNum=1002,hurt=100,helper=0,state={[1009]={4001,0},}}},},skillId=2002},                                                 
        {attaker={{figureNum=1009,state={{4002,100}}},},target={{{figureNum=1001,hurt=100,helper=0,state={[1009]={4002,0}}},{figureNum=1002,hurt=100,helper=0,state={[1009]={4002,0}}},{figureNum=1003,hurt=100,helper=0,state={[1009]={4002,0}}}},},skillId=2003},                                           
        {attaker={{figureNum=1003,state={{4001,100}}},},target={{{figureNum=1007,hurt=100,helper=0,state={[1009]={4001,0}}},{figureNum=1008,hurt=100,helper=0,state={[1009]={4001,0}}},{figureNum=1009,hurt=100,helper=0,state={[1009]={4001,0}}},{figureNum=1010,hurt=100,helper=0,state={[1009]={4001,0}}},{figureNum=1011,hurt=100,helper=0,state={[1009]={4001,0}}},{figureNum=1012,hurt=100,helper=0,state={[1009]={4001,0}}}},},skillId=2002},                                                
        {attaker={{figureNum=1008,state={{4001,100}}},},target={{{figureNum=1001,hurt=100,helper=0,state={}},{figureNum=1002,hurt=100,helper=0,state={}}},},skillId=2002},                                           
        --{attaker={{figureNum=1009,state={}},},target={{{figureNum=1001,hurt=100,helper=0,state={[1009]={4002,0},[1001]={4001,0}}},{figureNum=1002,hurt=100,helper=0,state={[1009]={4002,0},[1001]={4001,0}}}},},skillId=2003},                                              
    }
    local report = dataReport[self.m_testPlayerNumIndex]
    if type == 1 then
        report.skillId = param.skillId
        report[DATAFLOW.target][1][1][DATAFLOW.figureNum] = param.figureNum
    end
    self.m_testPlayerNumIndex = self.m_testPlayerNumIndex + 1
    return report
end
-- 初始位置信息数据
function DataInterface:testFetchInitPosition()
    local test_figure_position = {
        {figureNum = 1001,direction = 1,skills={2001}},
        {figureNum = 1002,direction = 1,skills={2001,2002}},
        {figureNum = 1003,direction = 1,skills={2001,2002}},
        {figureNum = 1004,direction = 1,skills={2001,2002}},
        {figureNum = 1005,direction = 1,skills={2001,2002}},
        {figureNum = 1006,direction = 1,skills={2001,2002}},
        {figureNum = 1007,direction = -1,skills={2001,2002}},
        {figureNum = 1008,direction = -1,skills={2001,2002}},
        {figureNum = 1009,direction = -1,skills={2001,2002}},
        {figureNum = 1010,direction = -1,skills={2001,2002}},
        {figureNum = 1011,direction = -1,skills={2001,2002}},
        {figureNum = 1012,direction = -1,skills={2001,2002}}}
        
    return test_figure_position
end
-- count是否已经结束
function DataInterface:testCountOver()    
    if not self.m_testPlayerNumIndex then
        self.m_testPlayerNumIndex = 1
        self.m_testPlayerInfoList = {
            {figureNum=1001,skills={{id=1001,isCoolDown=1},{id=1002,isCoolDown=1},{id=1003,isCoolDown=1},}},
            {figureNum=1002,skills={{id=1001,isCoolDown=1},{id=1002,isCoolDown=1},}},
            {figureNum=1003,skills={{id=1001,isCoolDown=1},{id=1002,isCoolDown=1},}},
            {figureNum=1004,skills={{id=1001,isCoolDown=1},{id=1002,isCoolDown=1},}},
            {figureNum=0,skills={{id=1001,isCoolDown=1},{id=1002,isCoolDown=1},}},
            {figureNum=0,skills={{id=1001,isCoolDown=1},{id=1002,isCoolDown=1},}},
            }
    end
    if not self.m_testPlayerInfoList[self.m_testPlayerNumIndex] then
    	return true
    end
    return false
end
return DataInterface