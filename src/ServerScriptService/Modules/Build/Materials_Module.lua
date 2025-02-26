local module = {}

module.Increment = function(player:Player, amount:number)
	local materials = player:GetAttribute("Materials")
	materials += amount
	player:SetAttribute("Materials", materials)
end

return module
