local module = {}

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local actionservice = game:GetService("ContextActionService")
local tweenservice = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local plr = Players.LocalPlayer
local nvgevent = ReplicatedStorage:WaitForChild("nvg")
local Highlights = ReplicatedStorage:WaitForChild("Entities"):WaitForChild("Highlights")
local colorcorrection: ColorCorrectionEffect

local defexposure = Lighting.ExposureCompensation
local nvg, onanim, offanim, config, setting, on_overlayanim, off_overlayanim
local nvgactive, animating = false, false

local function playtween(tweentbl)
	task.spawn(function()
		for _, step in pairs(tweentbl) do
			if typeof(step) == "number" then
				task.wait(step)
			else
				step:Play()
			end
		end
	end)
end

local function cycle(grain)
	local source = grain.src
	local newframe
	repeat
		newframe = source[math.random(1, #source)]
	until newframe ~= grain.last
	grain.last = newframe
end

local function togglenvg(bool)
	if not animating and nvg then
		nvgevent:FireServer()
		animating = true
		nvgactive = bool
		if config.lens then
			config.lens.Material = bool and "Neon" or "Glass"
		end

		if bool then
			playtween(onanim)
			task.delay(0.75, function()
				playtween(on_overlayanim)
				task.spawn(function()
					if nvg:GetAttribute("ShowStalkers") then
						Highlights.NVGHighlight.Adornee = workspace.Zombies
						Highlights.NVGHighlight.Enabled = true
					end

					while nvgactive do
						cycle(config.dark)
						cycle(config.light)
						task.wait(0.05)
					end
				end)
				animating = false
			end)
		else
			playtween(offanim)
			task.delay(0.5, function()
				playtween(off_overlayanim)
				animating = false
				Highlights.NVGHighlight.Adornee = nil
				Highlights.NVGHighlight.Enabled = false
			end)
		end
	end
end

local function removehelmet()
	if plr.Character then
		animating = false
		togglenvg(false)
		actionservice:UnbindAction("nvgtoggle")
	end
end

local function toggleFix(actionName: string, inputState: Enum.UserInputState, inputObj: InputObject)
	if inputState == Enum.UserInputState.Begin then
		togglenvg(not nvgactive)
		task.delay(0.8, function()
			plr.Character:SetAttribute("NVG", nvgactive)
			ReplicatedStorage.ACS_Engine.Events.NVG:Fire(nvgactive)
		end)
	end
end

local function oncharadded(newchar: Model)
	local humanoid: Humanoid = newchar:WaitForChild("Humanoid")

	humanoid.Died:Connect(function()
		removehelmet()
	end)

	newchar.ChildRemoved:Connect(function(child)
		if child:FindFirstChild("Up") then
			removehelmet()
		end
	end)

	newchar.ChildAdded:Connect(function(child)
		local newnvg = child:WaitForChild("Up", 1)

		if newnvg then
			nvg = newnvg
			config = require(nvg:WaitForChild("AUTO_CONFIG"))
			setting = nvg:WaitForChild("NVG_Settings")

			local noise = Instance.new("ImageLabel")
			noise.BackgroundTransparency = 1
			noise.ImageTransparency = 1

			local overlay = noise:Clone()
			overlay.Image = "rbxassetid://" .. setting.OverlayImage.Value
			overlay.Size = UDim2.new(1, 0, 1, 0)
			overlay.Name = "Overlay"

			noise.Name = "Noise"
			noise.AnchorPoint = Vector2.new(0.5, 0.5)
			noise.Position = UDim2.new(0.5, 0, 0.5, 0)
			noise.Size = UDim2.new(2, 0, 2, 0)

			local info = config.tweeninfo

			onanim = config.onanim
			offanim = config.offanim

			on_overlayanim = {
				tweenservice:Create(game.Lighting, info, {
					ExposureCompensation = setting.Exposure.Value,
				}),

				tweenservice:Create(colorcorrection, info, {
					Brightness = setting.OverlayBrightness.Value,
					Contrast = 0.8,
					Saturation = -1,
					TintColor = setting.OverlayColor.Value,
				}),
			}

			off_overlayanim = {
				tweenservice:Create(game.Lighting, info, {
					ExposureCompensation = defexposure,
				}),

				tweenservice:Create(colorcorrection, info, {
					Brightness = 0,
					Contrast = 0,
					Saturation = 0,
					TintColor = Color3.fromRGB(255, 255, 255),
				}),
			}

			actionservice:BindAction("nvgtoggle", toggleFix, true, Enum.KeyCode.N, Enum.KeyCode.DPadDown)
			actionservice:SetTitle("nvgtoggle", "NVG On")
			actionservice:SetPosition("nvgtoggle", UDim2.new(0.15, 0, -1, 0))
		end
	end)
end

function module.init()
	colorcorrection = Instance.new("ColorCorrectionEffect")
	colorcorrection.Parent = Lighting

	plr.CharacterAdded:Connect(oncharadded)

	local oldchar = workspace:FindFirstChild(plr.Name)

	if oldchar then
		oncharadded(oldchar)
	end

	nvgevent.OnClientEvent:Connect(function(nvg, activate)
		if not nvg then
			return
		end

		local twistjoint = nvg:WaitForChild("twistjoint", 3)
		if not twistjoint then
			return
		end
		local config = require(nvg.AUTO_CONFIG)
		local lens = config.lens

		if lens then
			lens.Material = activate and "Neon" or "Glass"
		end

		playtween(config[activate and "onanim" or "offanim"])
	end)
end

return module
