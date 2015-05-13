local SkillDefManager = class("SkillDefManager")
local json = require("framework.json")
function SkillDefManager:ctor(fileName)
	self.fileName = fileName
	self.data = {}
	local tmp = cc.HelperFunc:getFileData(fileName)
    local data = json.decode(tmp)
    for i = 1,#data do
    	self.data[data[i].id] = data[i]
    end
end

function SkillDefManager:getSkillById(id)
	return self.data[id]
end

return SkillDefManager