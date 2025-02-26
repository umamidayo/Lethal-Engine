local module = {}

function module.init()
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Players = game:GetService("Players")
	local UserInputService = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local Network = require(ReplicatedStorage.Common.Network)
	local store = require(ReplicatedStorage.Common.Store)
	local perksFolder = ReplicatedStorage.Common.PlayerClass.Perks
	local classesFolder = ReplicatedStorage.Common.PlayerClass.Classes
	local Scheduler = require(ReplicatedStorage.Common.Libraries.Scheduler)
	local Maid = require(ReplicatedStorage.Common.Libraries.Maid)
	local maid = Maid.new()
	local maid2 = Maid.new()
	local LocalPlayer = Players.LocalPlayer
	local mouse = LocalPlayer:GetMouse()
	local PlayerGui = LocalPlayer.PlayerGui or LocalPlayer:WaitForChild("PlayerGui")

	local elements = {
		-- Prefab Elements
		perkFrameSample = ReplicatedStorage:WaitForChild("UI"):WaitForChild("PlayerClass"):WaitForChild("Perk"),
		classFrameSample = ReplicatedStorage:WaitForChild("UI"):WaitForChild("PlayerClass"):WaitForChild("Class"),
		-- Elements
		playerClassGui = PlayerGui:WaitForChild("PlayerClassGui"),
		perksList = PlayerGui:WaitForChild("PlayerClassGui"):WaitForChild("PerksFrame"):WaitForChild("PerksList"),
		close = PlayerGui:WaitForChild("PlayerClassGui"):WaitForChild("PerksFrame"):WaitForChild("CloseButton"),
		hoverbox = PlayerGui:WaitForChild("PlayerClassGui"):WaitForChild("HoverBox"),
		classLabel = PlayerGui:WaitForChild("PlayerClassGui"):WaitForChild("PerksFrame"):WaitForChild("ClassLabel"),
		perkPointsLabel = PlayerGui:WaitForChild("PlayerClassGui")
			:WaitForChild("PerksFrame")
			:WaitForChild("PerkPoints"),
		resetButton = PlayerGui:WaitForChild("PlayerClassGui"):WaitForChild("PerksFrame"):WaitForChild("ResetButton"),
		resetLabel = PlayerGui:WaitForChild("PlayerClassGui"):WaitForChild("PerksFrame"):WaitForChild("ResetLabel"),
		changeClassButton = PlayerGui:WaitForChild("PlayerClassGui")
			:WaitForChild("PerksFrame")
			:WaitForChild("ChangeClassButton"),
		changeClassLabel = PlayerGui:WaitForChild("PlayerClassGui")
			:WaitForChild("PerksFrame")
			:WaitForChild("ChangeClassLabel"),
		classList = PlayerGui:WaitForChild("PlayerClassGui"):WaitForChild("PerksFrame"):WaitForChild("ClassList"),
	}

	local style = {
		colors = {
			perkActiveColor = Color3.fromRGB(71, 138, 71),
			perkInactiveColor = Color3.fromRGB(56, 56, 56),
			perkFrameMouseEnter = Color3.fromRGB(255, 232, 148),
			perkFrameMouseLeave = Color3.fromRGB(255, 255, 255),
		},
	}

	local tweenInfos = {
		perkFrameTextMouseHover = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		perkChangeColor = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	}

	local perks = {}
	local classes = {}

	local function getPerks()
		for _, perk in pairs(perksFolder:GetChildren()) do
			local perkData = require(perk)
			perks[perk.Name] = perkData
		end
	end

	local function getClasses()
		for _, class in pairs(classesFolder:GetChildren()) do
			local classData = require(class)
			classes[class.Name] = classData
		end
	end

	getPerks()
	getClasses()

	local function createPrompt(parent)
		local newPrompt = ReplicatedStorage.UI.Prompt:Clone()
		newPrompt.Parent = parent
		return newPrompt
	end

	local function updatePerkTree()
		elements.changeClassLabel.Text = "Change Class"
		local playerclassState = store:getState().playerClass
		local profile = playerclassState[LocalPlayer.UserId]
		local className = profile.className
		local classPerks = perks[className]
		local playerperks = profile.perks

		elements.classLabel.Text = `Class: <font color="rgb(150, 150, 210)">{className}</font>`
		elements.perkPointsLabel.Text = `Perk Points: <font color="rgb(150, 150, 210)">{profile.perkpoints}</font>`

		for _, perk in classPerks do
			local perkFrame = elements.perkFrameSample:Clone()
			maid:GiveTask(perkFrame)

			if table.find(playerperks, perk.Name) then
				perkFrame.ImageButton.ImageColor3 = style.colors.perkActiveColor
			end
			perkFrame.TextLabel.Text = perk.Name
			perkFrame.Parent = elements.perksList["Tier" .. perk.Tier]

			maid:GiveTask(perkFrame.ImageButton.MouseButton1Click:Connect(function()
				Network.fireServer(Network.RemoteEvents.PlayerClassEvent, "SpendPerkPoint", {
					perkName = perk.Name,
				})
			end))

			maid:GiveTask(perkFrame.MouseEnter:Connect(function()
				elements.hoverbox.Visible = true
				elements.hoverbox.Description.Text = perk.Description
				elements.hoverbox.PerkName.Text = perk.Name
				elements.hoverbox.Requirements.RichText = true
				elements.hoverbox.Tier.Text = `Tier {perk.Tier}`
				if perk.Requirements then
					elements.hoverbox.Description.Size = UDim2.fromScale(0.85, 0.297)
					elements.hoverbox.Requirements.Visible = true
					elements.hoverbox.Requirements.Text =
						`Requires: <font color="rgb(150, 210, 150)">{perk.Requirements and table.concat(
							perk.Requirements,
							`<font color="rgb(255, 255, 255)"> | </font>`
						)}</font>`
				else
					elements.hoverbox.Description.Size = UDim2.fromScale(0.85, 0.5)
					elements.hoverbox.Requirements.Visible = false
				end
				TweenService:Create(perkFrame.TextLabel, tweenInfos.perkFrameTextMouseHover, {
					Size = UDim2.fromScale(1.5, 0.3),
					TextColor3 = style.colors.perkFrameMouseEnter,
				}):Play()
			end))

			maid:GiveTask(perkFrame.MouseLeave:Connect(function()
				elements.hoverbox.Visible = false
				TweenService:Create(perkFrame.TextLabel, tweenInfos.perkFrameTextMouseHover, {
					Size = UDim2.fromScale(1, 0.25),
					TextColor3 = style.colors.perkFrameMouseLeave,
				}):Play()
			end))
		end

		elements.classList.Visible = false
		elements.perksList.Visible = true
	end

	local function getClassList()
		elements.changeClassLabel.Text = "View Perks Tree"
		maid2:DoCleaning()

		local playerclassState = store:getState().playerClass
		local profile = playerclassState[LocalPlayer.UserId]
		local currentClassName = profile.className

		for className, class in classes do
			if not table.find(profile.classes, className) then
				continue
			end
			local classFrame = elements.classFrameSample:Clone()
			maid2:GiveTask(classFrame)
			classFrame.Contents.ClassInfo.ClassTitle.Text = className
			classFrame.Contents.ClassInfo.ClassDescription.Text = class.Description
			classFrame.Background.ImageColor3 = class.uiBackgroundColor
			classFrame.LayoutOrder = class.layoutOrder or 0
			classFrame.Parent = elements.classList

			if currentClassName ~= className then
				maid2:GiveTask(classFrame.Contents.ChangeButton.MouseButton1Click:Connect(function()
					local prompt = createPrompt(elements.playerClassGui)
					prompt.TextLabel.Text =
						`Are you sure you want to change your class to {className}? Your character will reset.`
					maid2:GiveTask(prompt)
					maid2:GiveTask(prompt.Yes.MouseButton1Click:Connect(function()
						Network.fireServer(Network.RemoteEvents.PlayerClassEvent, "ChangeClass", {
							className = className,
						})
						prompt:Destroy()
					end))
					maid2:GiveTask(prompt.No.MouseButton1Click:Connect(function()
						prompt:Destroy()
					end))
				end))
			else
				classFrame.Contents.ChangeButton.Visible = false
			end
		end
	end

	elements.close.MouseButton1Click:Connect(function()
		elements.playerClassGui.Enabled = false
		maid:DoCleaning()
	end)

	elements.resetButton.MouseButton1Click:Connect(function()
		local prompt = createPrompt(elements.playerClassGui)
		prompt.TextLabel.Text =
			"Are you sure you want to restart your perk tree? You will keep your points and your character will reset."
		maid:GiveTask(prompt)
		maid:GiveTask(prompt.Yes.MouseButton1Click:Connect(function()
			Network.fireServer(Network.RemoteEvents.PlayerClassEvent, "ResetPerks")
			prompt:Destroy()
		end))
		maid:GiveTask(prompt.No.MouseButton1Click:Connect(function()
			prompt:Destroy()
		end))
	end)

	elements.resetButton.MouseEnter:Connect(function()
		TweenService:Create(elements.resetButton, tweenInfos.perkFrameTextMouseHover, {
			Rotation = 15,
		}):Play()
		TweenService:Create(elements.resetLabel, tweenInfos.perkFrameTextMouseHover, {
			Position = UDim2.fromScale(0.247, 0.12),
			TextTransparency = 0,
		}):Play()
	end)

	elements.resetButton.MouseLeave:Connect(function()
		TweenService:Create(elements.resetLabel, tweenInfos.perkFrameTextMouseHover, {
			Position = UDim2.fromScale(0.2, 0.12),
			TextTransparency = 1,
		}):Play()
	end)

	elements.changeClassButton.MouseButton1Click:Connect(function()
		if elements.classList.Visible then
			elements.changeClassLabel.Text = "Change Class"
			elements.classList.Visible = false
			elements.perksList.Visible = true
			maid2:DoCleaning()
		else
			elements.changeClassLabel.Text = "View Perk Tree"
			elements.classList.Visible = true
			elements.perksList.Visible = false
			getClassList()
		end
	end)

	elements.changeClassButton.MouseEnter:Connect(function()
		TweenService:Create(elements.changeClassLabel, tweenInfos.perkFrameTextMouseHover, {
			Position = UDim2.fromScale(0.4, 0.165),
			TextTransparency = 0,
		}):Play()
	end)

	elements.changeClassButton.MouseLeave:Connect(function()
		TweenService:Create(elements.classLabel, tweenInfos.perkFrameTextMouseHover, {
			TextStrokeTransparency = 1,
		}):Play()
		TweenService:Create(elements.changeClassLabel, tweenInfos.perkFrameTextMouseHover, {
			Position = UDim2.fromScale(0.35, 0.165),
			TextTransparency = 1,
		}):Play()
	end)

	elements.close.MouseEnter:Connect(function()
		elements.close.ImageTransparency = 0.5
	end)

	elements.close.MouseLeave:Connect(function()
		elements.close.ImageTransparency = 0
	end)

	Scheduler.AddToRenderer("Render", "PlayerClassHoverBox", function()
		elements.hoverbox.Position = UDim2.fromOffset(mouse.X + 20, mouse.Y + 60)
	end)

	Network.connectEvent(Network.RemoteEvents.PlayerClassEvent, function(eventType: string)
		if eventType == "SpendPerkPoint" then
			task.delay(0.1, function()
				maid:DoCleaning()
				updatePerkTree()
			end)
		elseif eventType == "ResetPerks" then
			task.delay(0.1, function()
				maid:DoCleaning()
				updatePerkTree()
			end)
		elseif eventType == "ChangeClass" then
			task.delay(0.1, function()
				maid:DoCleaning()
				updatePerkTree()
			end)
		end
	end, Network.t.string)

	elements.playerClassGui:GetPropertyChangedSignal("Enabled"):Connect(function()
		if elements.playerClassGui.Enabled then
			elements.close.ImageTransparency = 0
			maid:DoCleaning()
			maid2:DoCleaning()
			updatePerkTree()
		else
			maid:DoCleaning()
			maid2:DoCleaning()
		end
	end)

	-- UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
	-- 	if processed then
	-- 		return
	-- 	end
	-- 	if input.KeyCode == Enum.KeyCode.M then
	-- 		elements.playerClassGui.Enabled = not elements.playerClassGui.Enabled
	-- 	end
	-- end)
end

return module
