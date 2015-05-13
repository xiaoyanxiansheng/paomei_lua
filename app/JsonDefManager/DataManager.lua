-- local DataManager = class("DataManager")
local json = require("framework.json")
-- local instance
-- function DataManager:ctor()
-- 	local tmp = cc.HelperFunc:getFileData(fileName)
--     local data = json.decode(tmp)
--     for i = 1,#data do
--     	self[data[i].moduleName] = require("src/app/DataManager/"..moduleName).new(data[i].fileName)
--     end
-- end

-- function DataManager:getManager(moduleName)
-- 	return self[moduleName]
-- end

-- function DataManager:getInstance()
-- 	if instance == nil then
-- 		instance = ctor()
-- 	end
-- 	return instance
-- end

-- return DataManager
local moduleName = "DataManager"
module(moduleName,package.seeall)
local instance = nil
local fileName = "json/DataList.json"
function getInstance()
	if instance == nil then
		instance = init()
	end
	return instance
end

function init()
	local tab = {}
	local tmp = cc.HelperFunc:getFileData(fileName)
    local data = json.decode(tmp)
    for i = 1,#data do
        tab[data[i].moduleName] = require("src/app/JsonDefManager/"..data[i].moduleName).new(data[i].fileName)
    end
    return tab
end

function getManager( moduleName )
	if instance == nil then
		instance = getInstance()
	end
	return instance[moduleName]
end