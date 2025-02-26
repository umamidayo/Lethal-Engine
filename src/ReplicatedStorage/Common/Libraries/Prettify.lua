local module = {}

function module.FormatThousands(n): number?
	n = tostring(n)
	return (n:reverse():gsub("...", "%0,", math.floor((#n - 1) / 3)):reverse()) :: number
end

return module
