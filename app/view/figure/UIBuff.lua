local UIBuff = class("UIBuff",function()
    return display.newNode()
end)

function UIBuff:ctor(buffId)
    -- 
    self.m_buffId = buffId
    
    self:init()
end
function UIBuff:init()
    self:playBuffById()
end
function UIBuff:playBuffById()
    local sprite = display.newSprite()
    self:addChild(sprite)
    -- 由于目前没有文件，临时解决方法
    local animation = display.getAnimationCache(self:getEffectSourceName())
    if not animation then
    	return 
    end
    transition.playAnimationForever(sprite,animation)
end

function UIBuff:getBuffId()
    return self.m_buffId
end

-- 由于现在没有策划表，临时特效对应表
function UIBuff:getEffectSourceName()
local effectConfig = {
        [0]   = "0",
        [101] = "4001_buff",
        [105] = "4002_buff",
        [103] = "4001_buff",
        [108] = "4002_buff",}
    return effectConfig[self:getBuffId()]
end

return UIBuff