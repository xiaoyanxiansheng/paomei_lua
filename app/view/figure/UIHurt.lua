local UIHurt = class("UIHurt",function()
    return display.newNode()
end)
-- 数字，颜色，字体大小，运行时间，运行结束位置
function UIHurt:ctor()

    self:init()
end
function UIHurt:init()end

function UIHurt:playerWordUp(param,direction)

    -- 方向选择
    if direction == -1 then
    	self:setScaleX(-1)
    end

    -- 属性设置
    self:setAttribute(param)
    
    local label = cc.ui.UILabel.new({
        text  = self.m_xue_word,
        size  = self.m_font_size,
        color = self.m_word_color
    }):addTo(self)
    label:setAnchorPoint(0.5,0.5)
    local action    = cc.MoveBy:create      (self.m_time,self.m_pos)
    local func      = cc.CallFunc:create    (handler(self,self.func))
    local sequence  = transition.sequence   ({action,func})
    label:runAction(sequence)
    -- 运行动画
end

function UIHurt:setAttribute(param)
    self.m_xue_word   = param.word
    self.m_word_color = not param.color    and cc.c3b(240,80,50)  or param.color
    self.m_font_size  = not param.fontSize and 20                 or param.fontSize
    self.m_time       = not param.time     and 0.5                or param.time
    self.m_pos        = not param.pos      and cc.p(0,100)        or param.pos
end
function UIHurt:func(e)
    e:removeFromParent()
end

return UIHurt