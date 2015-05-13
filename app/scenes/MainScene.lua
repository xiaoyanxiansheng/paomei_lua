local MainController = require("app.controller.MainController")
local UIHurt         = require("src.app.view.figure.UIHurt")

local DataInterface  = require("app.model.DataInterface")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- 
    self.m_mainController = nil
    -- 技能按钮列表
    self.m_skillButtonLIst = {}
    self:init()
end

function MainScene:init()
    -- 初始化数据接口
    self:initDataInterface()
    -- 加入ui界面
    self:addUi()
    -- 初始化主控制器
    self:initMainCotroller()
end

function MainScene:addUi()
    -- 加入背景和操作
    self:addOprateUI()
    -- 加入延时等待
    self:addDelayUI()
    -- 加入回合信息
    self:addRoundInfoUI()
    -- 加入技能描述
    self:addSkillDiscription()
end
function MainScene:addSkillDiscription()
    self.m_discription = UIHurt.new()
    self.m_discription:setAnchorPoint(0.5,0.5)
    self.m_discription:setPosition(display.cx,display.cy)
    self:addChild(self.m_discription)
    
    -- 
    self.m_figureNumUI = cc.ui.UILabel.new({
            size = 24,
            color = cc.c3b(255,255,250)
        }):pos(250,50):addTo(self,10)
end
function MainScene:addOprateUI()
    cc.uiloader:load("ccs/Layer_bg.csb"):addTo(self)

    -- button
    local layer_oprate = cc.uiloader:load("ccs/Layer_optate.csb"):addTo(self,2)
    local indexList = {10,11,12,13,14}

    -- label
    local labelDiscreption = {"未托管","","","",""}
    local labelList = {}

    for key, var in pairs(indexList) do
        
            -- button
            local node = cc.uiloader:seekNodeByTag(layer_oprate,var)
            -- 可以更换背景图片
            -- node:loadTextures("img/xue_back.png","img/xue_back.png","img/xue_back.png")
            node:setTag(key)
            node:addTouchEventListener(function(e,target) self:onClickedCall(e,target) end)
            node:setVisible(false)
            
            -- label
            local label = cc.ui.UILabel.new({
                text = labelDiscreption[key],
                size = 24,
                color = cc.c3b(200,80,50)
            }):pos(node:getPositionX(),node:getPositionY()):addTo(self,10)
            label:setAnchorPoint(0.5,0.5)
            self:addSkillLabelList(label)
            
        if key>1 then
            self:addSkillButton(node)
        else
            node:setVisible(true)
        end
    end
end
function MainScene:addDelayUI()
    self.m_delayTime_label = cc.ui.UILabel.new({
        fontSize = 32
    }):pos(display.cx,display.cy):addTo(self,2)
    self.m_delayTime_label:setAnchorPoint(0.5,0.5)
    self:hideDelayTimeLabel()
end
function MainScene:addRoundInfoUI()
    self.m_roundInfo_label = cc.ui.UILabel.new({
        fontSize = 32
    }):pos(display.cx,display.height-100):addTo(self,2)
    self.m_roundInfo_label:setAnchorPoint(0.5,0.5)
end
function MainScene:onClickedCall(e,target)
    if target~=2 then
    	return 
    end
    local index = e:getTag()
    self:getMainController():sendButtonIndex(e,index)
end

function MainScene:initMainCotroller()
    self:setMainController(MainController.new(self))
end

--------- get set --------
function MainScene:setMainController(controller)
    self.m_mainControllerr = controller
end
function MainScene:getMainController()
    return self.m_mainControllerr
end
function MainScene:setMainSceneController(mainSceneController)
    self.m_mainController = mainSceneController
end
function MainScene:getMainSceneController()
    return self.m_mainController
end
function MainScene:initDataInterface()
    self.dataInterface = DataInterface.new()
end
function MainScene:getDataInterface()
    return self.dataInterface
end
function MainScene:setDelayTimeLabel(time)
    local label = "等待时间:"..time
    self.m_delayTime_label:setString(label)
    self.m_delayTime_label:setVisible(true)
end
function MainScene:hideDelayTimeLabel()
    self.m_delayTime_label:setVisible(false)
end
function MainScene:getRoundInfo()
    return self.m_roundInfo_label:getString()
end
function MainScene:setRoundInfo(num)
    self.m_roundInfo_label:setString("当前回合数: "..num)
end
function MainScene:setTuoguanUI(flag)
    if flag then
        self:getSkillLabelList()[1]:setString("托管中")
    else
        self:getSkillLabelList()[1]:setString("未托管")
    end
end
function MainScene:setSkillLabelList(list)
    for key, var in pairs(list) do
    	self:getSkillLabelList()[key+1]:setString(var)
    end
end
function MainScene:addSkillLabelList(label)
    if not self.m_skillLabelList then
    	self.m_skillLabelList = {}
    end
    table.insert(self.m_skillLabelList,label)
end
function MainScene:getSkillLabelList()
    return self.m_skillLabelList
end
function MainScene:addSkillButton(node)
    table.insert(self.m_skillButtonLIst,node)
end
function MainScene:getSkillButtonList()
    return self.m_skillButtonLIst
end
function MainScene:getDiscriptionUI()
    return self.m_discription
end
function MainScene:setFigureNumUI(param)
    self.m_figureNumUI:setString("figureId= "..param[DATAFLOW.figureNum])
end
function MainScene:onEnter()
end

function MainScene:onExit()
end


return MainScene
