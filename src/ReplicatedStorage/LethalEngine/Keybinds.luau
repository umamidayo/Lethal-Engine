local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Cryo = require(ReplicatedStorage.Packages.Cryo)

type InputCallback = {
	began: (() -> ())?,
	ended: (() -> ())?,
}

local Binds: { [Enum.KeyCode]: { [string]: InputCallback } } = {}

local Keybinds = {}

-- Adds callbacks with a name to the keybind
function Keybinds.bind(keystroke: Enum.KeyCode, callbackName: string, callbacks: InputCallback)
	if not Binds[keystroke] then
		Binds[keystroke] = {}
	end

	Binds[keystroke] = Cryo.Dictionary.join(Binds[keystroke], {
		[callbackName] = callbacks,
	})
end

-- Removes callbacks with a name from the keybind
function Keybinds.unbind(keystroke: Enum.KeyCode, callbackName: string)
	if not Binds[keystroke] then
		return
	end

	Binds[keystroke] = Cryo.Dictionary.join({}, Binds[keystroke], { [callbackName] = Cryo.None })
end

function Keybinds.init()
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if Binds[input.KeyCode] then
			for _, callbacks in pairs(Binds[input.KeyCode]) do
				if callbacks.began then
					task.spawn(callbacks.began)
				end
			end
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then
			return
		end

		if Binds[input.KeyCode] then
			for _, callbacks in pairs(Binds[input.KeyCode]) do
				if callbacks.ended then
					task.spawn(callbacks.ended)
				end
			end
		end
	end)
end

return Keybinds
