local UIBlood = class("UIBlood",function(background,fill)
    local progress = display.newSprite(background)
    local fill = display.newProgressTimer(fill,display.PROGRESS_TIMER_BAR)
    --设置进度条起点
    fill:setMidpoint(cc.p(0,0.5))
    --设置改变状态
    fill:setBarChangeRate(cc.p(1.0, 0))
    --
    fill:setPosition(progress:getContentSize().width/2,progress:getContentSize().height/2)
    progress:addChild(fill)
    fill:setPercentage(100)
    progress.fill = fill
    return progress
end)

function UIBlood:setBloodAge(bloodNum)
    self.fill:setPercentage(bloodNum)
end

function UIBlood:getBloodAge()
    return self.fill:getPercentage()
end

return UIBlood