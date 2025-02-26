local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local url = "http://ip-api.com/json"

local serverinfoFolder = ReplicatedStorage.ServerInfo
local region = serverinfoFolder.Region
local country = serverinfoFolder.Country

local module = {}

function module.init()
	local getasyncinfo

	local success, errormsg = pcall(function()
		getasyncinfo = HttpService:GetAsync(url)
	end)

	if not success then
		warn(errormsg)
		repeat
			task.wait(30)
			getasyncinfo = HttpService:GetAsync(url)
		until getasyncinfo
	end

	local decodedinfo = HttpService:JSONDecode(getasyncinfo)
	region.Value = decodedinfo["region"]
	country.Value = decodedinfo["country"]

	--The decoded table have all these:

	--	local table = {
	--	["as"] = "Internet Name",
	--	["city"] = "###",
	--	["country"] = "####",
	--	["countryCode"] = "#",
	--	["isp"] = "###",
	--	["lat"] = ###, -- number
	--	["lon"] = 78.50749999999999,
	--	["org"] = "###",
	--	["query"] = "###",
	--	["region"] = "###",
	--	["regionName"] = "###",
	--	["status"] = "success",
	--	["timezone"] = "###",
	--	["zip"] = ### - number
	--}
end

return module
