-- This is where both client and server can access the same code (States, shared data, etc.).

local SharedExample = {}

function SharedExample.init()
	print("SharedExample initialized")
end

return SharedExample
