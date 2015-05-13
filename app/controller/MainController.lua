local Model_dataflow        = require("app.model.Dataflow")
local Figure                = require("app.model.Figure")
local Dataflow              = require("app.model.Dataflow")

local FigureController      = require("app.controller.FigureController")
local DataflowController    = require("app.controller.DataflowController")
local TextureController     = require("src.app.controller.TextureController")
local scheduler          = require("src.framework.scheduler")

local MainController = class("MainController")

function MainController:ctor(mainScene)
    -- 主界面
    self.m_mainScene = mainScene
    -- 实体控制器列表
    self.m_figure_controler_list = {}
    
    self:init()
end
function MainController:init()

    -- test加载缓存
    self:pre()
    
    -- 设置游戏的超时时间
    self:setOprateDelayTime(3)
    
    -- 主界面得到主控制器
    self:getMainScene():setMainSceneController(self)

    -- 初始化实体信息
    self:initFigureInfo()
    
    -- 执行一次count
    self:exeCount()
    
    -- 初始化点击层
    -- 可以addNodeEventListener简单解决
    self:initChuMoLayer()
    
    -- 开启一个计算线程
    scheduler.scheduleGlobal(handler(self,self.luoji),1)
end

-- 游戏等待
function MainController:luoji(ft)
    
    -- 是否进入玩家等待
    if not self:isPlayerWait() then
    	return
    end
    
    if self:getOprateDelayTime() == 0 then
    	-- 正常指令流
        self:ExeDataflow(1)
    	
        -- 玩家解除等待
        self:setPlayerWait(false)
        
        -- 延时重置
        self:setDelayTimeUIDefault()

        return
    end
    
    self:setOprateDelayTime(self:getOprateDelayTime() - 1)
    
    -- 设置延时UI
    self:getMainScene():setDelayTimeLabel(self:getOprateDelayTime())
   
end

function MainController:exeCount()
    
    -- 所有count是否全部完成
    if self:isGameOver() then
        -- 游戏结束
        -- self:gameOver()
    	return
    end
    
    -- 获取当前能行动对象
    local figureInfo = self:getMainScene():getDataInterface():fetchPlayerInfo()
    
    -- 执行count之前的准备工作
    self:preZhunbei(figureInfo)

    if not figureInfo[DATAFLOW.attaker][DATAFLOW.isManipulate] or self:isTuoguan() then
    
        -- 执行数据流(1代表请求自动数据)
        self:ExeDataflow(1)
    elseif figureInfo.figureNum==-1 then
        -- 特殊指令
        self:ExeSpecail()
    else
        -- 改变游戏界面（目前未完成）
        self:changeGameUI(figureInfo[DATAFLOW.attaker].skills)
        
        -- 等待玩家输入
        self:setPlayerWait(true)
    end
end
function MainController:preZhunbei(figureInfo)
    
    
    local info = figureInfo[DATAFLOW.info]
    local roundCount = figureInfo[DATAFLOW.attaker].roundCount
    local figureNum = figureInfo[DATAFLOW.attaker][DATAFLOW.figureNum]
    -- count开始前的当前信息设置
    self:initFigureInfoNow(info)
    -- 回合设置
    self:setRoundInfo(roundCount)
    -- 当前攻击者id
    self:setFigureNumUI({[DATAFLOW.figureNum]=figureNum})
    -- 默认普通攻击(这个地方有问题)
    self:setSkillId(10001)
    -- 选择的攻击目标为空
    self.m_tong_index = 0
    
end
-- 执行正常流(包括数据请求和运行流程)
function MainController:ExeDataflow(type,param)
    
    -- 获取的战报
    local dataReport = self:getMainScene():getDataInterface():fetchReport(type,param)
    -- 技能攻击次数
    local skillcount = 1
    self:getFigureByFigureNum(dataReport[DATAFLOW.attaker][1][DATAFLOW.figureNum]):setSkillParam(dataReport[DATAFLOW.skillid],skillcount)

    if not self:getDataflowController() then
        -- 初始化数据报解析控制器
        self:initDataController(dataReport)
    else
        -- 设置数据报数据
        self:getDataflowController():getDataflow():setDataFlow(dataReport)
    end
    
end
-- 执行特殊指令流
function MainController:ExeSpecail()
    -- 1.请求，特殊指令数据流(目前测试)
    local dataReport = self:getMainScene():getDataInterface():fetchReport(-1)
    -- 2.设置，数据报数据
    self:getDataflowController():getDataflow():setDataFlow(dataReport)
    -- 3.执行，
    self:getDataflowController():ExeSpecail()
end
function MainController:initFigureInfo()
    -- 对象初始位置信息
    local figure_position = self:getMainScene():getDataInterface():fetchInitPosition()
    -- 初始化玩家和玩家控制器
    self:initPlayerAndController(figure_position)
end

function MainController:changeGameUI(skills)
    -- 添加延时等待
    self:getMainScene():setDelayTimeLabel(self:getOprateDelayTime())
    
    local buutonList = self:getSkillButtonList()
    local skilllabelinfolist = {}
    for key, var in pairs(skills) do
        -- button
        local button = buutonList[key]        
        button:setVisible(true)
        button:setTag(var.id)
        button:setEnabled(true)
        -- label
        local labelskillid = var[DATAFLOW.id]
        local labelisCoolDown = "可用"
        
        
        if not var[DATAFLOW.isCoolDown] then
            labelisCoolDown = "冷却中"
        	-- 不可以点击
            self:isSkillCollDwon(button)
        end
        
        table.insert(skilllabelinfolist,labelskillid.."\r\n"..labelisCoolDown)
    end
    -- label
    self:getMainScene():setSkillLabelList(skilllabelinfolist)
end
function MainController:isSkillCollDwon(node)
    node:setEnabled(false)
end
function MainController:sendButtonIndex(node,index)
    -- 设置技能id
    if index == 1 then
    	-- 托管切换 	
        self:setTuoguan(not self:isTuoguan())
    	return
    end
    -- print
    self:setSkillId(index)
end

function MainController:initDataController(dataReport)

    -- 数据流对象
    local dataflow = Dataflow.new()
    dataflow:setDataFlow(dataReport)
    
    -- 数据流控制器
    local dataflowController = DataflowController.new(dataflow)
    self:setDataflowController(dataflowController)

    -- 得到主控制器
    dataflowController:setMainSceneController(self)
end


function MainController:initPlayerAndController(figurePositionList)

    for key, var in pairs(figurePositionList) do
        local k = key
        if var[DATAFLOW.direction] == -1 then
        	k = k + 4
        end
    	if var.figureNum then
            -- 初始化控制器
            local figureController = FigureController.new(Figure.new(var.figureNum))
            -- 得到主控制器
            figureController:setMainController(self)
            -- 在场景中添加实体
            -- test
            local pos = cc.p(self:getPointPosition()[k].x,self:getPointPosition()[k].y-0.5)
            figureController:addFigureToNode(self:getMainScene(),pos)
            -- 实体属性设置
            figureController:configAttribute(var)
            self:addFigureController(figureController)
            -- 技能系统
            figureController:addSkillSystem(self:getMainScene())
            -- 添加buff
            figureController:addBuffSystem()

    	end
    end
    
end
function MainController:initFigureInfoNow(info)
    local figureControllerList = self:getFigureControllerList()
    for key, var in pairs(figureControllerList) do
    	var:setHp(info[var:getFigureNum()][DATAFLOW.hp])
    end
end
function MainController:initChuMoLayer()
    local layer = display.newLayer()
    self:getMainScene():addChild(layer)
    layer:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name     == "began"  then
            return  self:onTouchBegan(event) 
        elseif event.name == "moved"  then
            self:onTouchMoved(event)
        elseif event.name == "ended"  then
            self:onTouchEnded(event)
        elseif event.name == "cancel" then
            self:onTouchCancelled(event)
        end
    end)
end
function MainController:onTouchBegan(event)
    -- 玩家是否在等待中
    if not self:isPlayerWait() then
    	return
    end
    for key, controller in pairs(self:getFigureControllerList()) do

        if controller:isOnclicked() then
            if cc.rectContainsPoint(controller:getFigureBoundingBox(),cc.p(event.x,event.y)) then
        		-- 取消玩家等待
        		self:setPlayerWait(false)
        		-- 执行count数据流
                self:ExeDataflow(2,{skillId = self:getSkillId(),figureNum = controller:getFigureNum()})
        		-- 重置延时
        		self:setDelayTimeUIDefault()
        	end
        end
    end
    return true
end
function MainController:pre()
    
    self.m_texture = TextureController.new()

    -- 加载技能缓存
    local skillids = {2002,2003,2004}
    for key, var in pairs(skillids) do
        self.m_texture:preSkill(var)
    end
    
    -- 加载buff
    local buffList = {4001,4002}

    for key, var in pairs(buffList) do
        self.m_texture:preBuff(var)
    end
    
    -- test
    self.m_texture:preText()
--    --
--    local test = cc.CSLoader:createNode("ccs/skill_0002.csb")
--    test:setPosition(display.cx,display.cy)
--    self:getMainScene():addChild(test,100)
--    -- 加载动画
--    local animation = cc.CSLoader:createTimeline("ccs/skill_0002.csb")
--    test:runAction(animation)
--    -- 播放动画
--    animation:gotoFrameAndPlay(0)
--
--    local sprite = cc.ui.UIPushButton.new({normal="images/pm2_qiangpaotx1_fc1.png",pressed="images/pm2_qiangpaotx1_fc1.png"})
--    sprite:setPosition(display.cx,200)
--    self:getMainScene():addChild(sprite,100)
end
function MainController:onTouchMoved(event)
    print("nihao2")
end
function MainController:onTouchEnded(event)
    print("nihao3")
end
function MainController:isGameOver()
    local num = self:getMainScene():getDataInterface():isGameOver()

    if num == DATAFLOW.ATTACKER_WIN then
        -- 玩家赢
        self:gameOver("你胜利了！！")
    	return true
    elseif num == DATAFLOW.DEFENDER_WIN then
        -- 敌人赢
        self:gameOver("你输了！！")
        return true
    elseif num == DATAFLOW.CONTINUE then
        -- 继续
        return false
    elseif num == DATAFLOW.ROUND_OUT then
        -- 超过最大回合
        self:gameOver("超过最大回合！！")
        return true
    end
end
function MainController:gameOver(word)
    -- 停止数据流的线程
    self:getDataflowController():setStopThread(true)
    local gameOverLabel = cc.ui.UILabel.new({
        text = "game over--"..word,
        fontSize = 50
    }):pos(display.cx,display.cy):addTo(self:getMainScene())
    gameOverLabel:setAnchorPoint(0.5,0.5)
end

-- 某个实体运动的位置和时间
function MainController:getMoveAndTime(attackerController,targetController)
    -- skill
    local skill_report = self:getDataflowController():getDataflow():getDataflow_move_attack()
    local skill_config_moveTo = attackerController:getSkillController():getSkillMovePos()
    
    local move_point    = nil  
    local move_time     = nil                                     
    -- 是否有move点
    if not skill_config_moveTo then
        move_point = self:getMovePosition(attackerController,targetController)
    elseif skill_config_moveTo.x == 0 and skill_config_moveTo.y == 0 then
        move_point = attackerController:getPointPosition()
    else
        move_point = skill_config_moveTo
    end
    -- 移动时间
    move_time  = self:getMoveTime(attackerController,targetController,move_point)
    -- 移动位置
    local move_pos = self:pointToPos(move_point)           
    
    return {movePos = move_pos,moveTime=move_time}
end
function MainController:setDelayTimeUIDefault()
    -- 这里设置后面的延时是否还需要，不需要不设置
    self:setOprateDelayTime(self:getOprateDelayTimeDefault())
    -- 隐藏延时
    self:getMainScene():hideDelayTimeLabel()
end
-- 通过target返回attacker将要移动到的位置
function MainController:getMovePosition(attackerController,targetController)
    local pos_point = targetController:getPointPosition()
    local point = {}
    -- 方向判断
    if targetController:getDirection()==1 then
        point.x = pos_point.x+1
    else
        point.x = pos_point.x-1
    end
    point.y = pos_point.y

    return point
end
-- 返回将要移动到的位置的时间
function MainController:getMoveTime(attackerController,targetController,moveTo)
    
    -- 移动速度
    local speed = 10
    -- 两点距离
    local distance = self:getDistanceByNode(attackerController:getPointPosition(),moveTo)
    --时间
    local time = distance/(speed*60)
    
    if self.m_tong_index == 0 then
        self.m_tong_index = attackerController:getFigureNum()
    else
        if self.m_tong_index == targetController:getFigureNum() then
            time = 0.1
        else        
            self.m_tong_index = targetController:getFigureNum()
        end
    end
    return time
end
-- 返回技能的移动时间
--function MainController:getMoveTimeSkill(attackerController,targetController)
--    -- 技能激动速度
--    local speed = 20
--    local distance = self:getDistanceByNode(attackerController:getPointPosition(),targetController:getPointPosition())
--    return distance/(speed*60)
--end
-- 设置技能描述
function MainController:setSkillDiscription(discreption)   
    self:getMainScene():getDiscriptionUI():playerWordUp({word = discreption,time=2,color=cc.c3b(222,222,222)},1)
end
----------- 算法1 返回位置(根据点坐标算出具体坐标)  --------
function MainController:pointToPos(point)
    local width = display.width/12
    local height = display.height/6

    local x = (point.x - 1/2)*width
    local y = (point.y - 1/2)*height
    
    return cc.p(x,y)
end
------------------- 算法2 ：通过num求得实体  ---------------
function MainController:getFigureByFigureNum(figureNum)
    -- local figureNum = tonumber(figureNum,10)
    for key, controler in pairs(self:getFigureControllerList()) do
        if controler:getFigureNum() - figureNum == 0 then
            return controler
        end
    end
    return false
end
---------------------- 算法3：得到两个node之间的距离  ----------
function MainController:getDistanceByNode(point1,point2)
    
    local pos1 = self:pointToPos(point1)
    local pos2 = self:pointToPos(point2)
    
    return math.sqrt((pos1.x-pos2.x)*(pos1.x-pos2.x)+(pos1.y-pos2.y)*(pos1.y-pos2.y))
end
function MainController:getDistanceByNodeSubPos(pos)
    return math.sqrt(pos.x*pos.x+pos.y*pos.y)
end
--------------- get set add -------------------
function MainController:addFigure()
    -- 得到数据
    for key, varController in pairs(self:getFigureControllerList()) do       
        varController:addFigureToNode(self:getMainScene(),self:getPointPosition()[key])
    end
end

-- 索引和点坐标的转化关系
function MainController:getPointPosition()
    local point_position = {cc.p(2,1),cc.p(2,3),cc.p(2,5),cc.p(4,2),cc.p(4,4),cc.p(4,6),cc.p(9,2),cc.p(9,4),cc.p(9,6),cc.p(11,1),cc.p(11,3),cc.p(11,5),}
    return point_position
end
-- 得到主界面
function MainController:getMainScene()
    return self.m_mainScene
end
function MainController:addFigureController(figureController)
    table.insert(self.m_figure_controler_list,figureController)
end
function MainController:getFigureControllerList()
    return self.m_figure_controler_list
end
function MainController:setDataflowController(dataflowController)
    self.m_dataflow_controller = dataflowController
end
function MainController:getDataflowController()
    return self.m_dataflow_controller
end
function MainController:isPlayerWait()
    if not self.m_isPlayerWait then
        self.m_isPlayerWait = false
    end
    return self.m_isPlayerWait
end
function MainController:setPlayerWait(flag)
    self.m_isPlayerWait = flag
end

function MainController:setOprateDelayTime(time)
    if not self.m_m_delayTime then
    	self.m_m_delayTime = time
    end
    self.m_delayTime = time
end
function MainController:getOprateDelayTime()
    return self.m_delayTime
end
function MainController:getOprateDelayTimeDefault()
    return self.m_m_delayTime
end
function MainController:getSkillId()
    return self.m_skillId
end
function MainController:setSkillId(skillId)

    self.m_skillId = skillId
end
function MainController:isTuoguan()
    if not self.m_isTuoguan then
    	self.m_isTuoguan = false
    end
    return self.m_isTuoguan
end
function MainController:setTuoguan(flag)
    self.m_isTuoguan = flag
    
    self:getMainScene():hideDelayTimeLabel()
    
    if not self:isTuoguan() then
        self:setOprateDelayTime(self:getOprateDelayTimeDefault())
    else
        self:setOprateDelayTime(0)
    end

    -- ui 设置
    self:getMainScene():setTuoguanUI(self:isTuoguan())
end
function MainController:setRoundInfo(num)
    self:getMainScene():setRoundInfo(num)
end
function MainController:getRoundInfo()
    return self:getMainScene():getRoundInfo()
end
function MainController:getSkillButtonList()
    return self:getMainScene():getSkillButtonList()
end
function MainController:setFigureNumUI(param)
    self:getMainScene():setFigureNumUI(param)
end
return MainController