local BuffController = class("BuffController")

function BuffController:ctor()
    --
    self.m_buff_list = {}
    
    self:init()
end
function BuffController:init()
end

function BuffController:addBuff(nodeController,buffId)
    -- 这里有点问题
    local buff = nodeController:getFigure():addBuffSystem(buffId)
    self.m_buff_list[buffId] = buff
end
-- 清空buff列表
function BuffController:removeAllBuff()
    local test = display.newSprite()
    -- test:remove
    -- test:setColor(color)
    for key, var in pairs(self:getFigureList()) do
        -- 删除会有问题(要加true)
    	var:removeFromParent(true)
    	
    	-- print(var)
    end
    self.m_buff_list = {}
end
-- 通过指定id删除buff
function BuffController:removeBuffById(buffId)
    table.remove(self:getFigureList(),buffId)
end
function BuffController:getFigureList()
    return self.m_buff_list
end
return BuffController