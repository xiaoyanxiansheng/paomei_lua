--[[
    缓存文件
--]]

local TextureController = class("TextureController")

local skillList = {"_skill","_skill_effect"}
local buff      = {"_buff"}

-- 加载技能
function TextureController:preSkill(skillNum)

    for key, var in pairs(skillList) do
        -- 加载缓存
        local plistname = "models/skill".."/"..skillNum..var..".plist"
        local pngtname = "models/skill".."/"..skillNum..var..".png"
        display.addSpriteFrames(plistname,pngtname)
        -- 缓存动画
        self:pre(skillNum,var)
    end
end
-- 加载buff
function TextureController:preBuff(buffId)
    for key, var in pairs(buff) do
        -- 加载缓存
        local plistname = "models/buff".."/"..buffId..var..".plist"
        local pngtname = "models/buff".."/"..buffId..var..".png"
        display.addSpriteFrames(plistname,pngtname)
        
        -- 缓存动画
        self:pre(buffId,var)
    end
end
-- 
function TextureController:pre(num,var)
    -- 加载动画
    local index = 1
    local frames = {}
    while true do
        local ooo = "_000"
        if index>=10 then
            ooo = "_00"
        end
        local png_name = num..var..ooo..index..".png"
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(png_name)
        if not frame then
            break
        end
        table.insert(frames,frame) 
        index = index + 1
        print(index)
    end
    -- 
    local time = 0.1  
    local animation = display.newAnimation(frames,time)        
    display.setAnimationCache(num..var,animation)
end
-- 加载测试缓存
function TextureController:preText()
    -- display.addSpriteFrames("Plist.plist","Plist.png")
    display.addSpriteFrames("pm2_ximulai_zhipai1.plist","pm2_ximulai_zhipai1.png")
end
return TextureController