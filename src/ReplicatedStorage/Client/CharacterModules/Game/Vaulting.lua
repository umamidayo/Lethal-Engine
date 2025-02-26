local module = {}

--services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")

--varibles
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera
local humanoid: Humanoid = character:WaitForChild("Humanoid")
local animator: Animator = humanoid:WaitForChild("Animator")
local rootPart: BasePart = character:WaitForChild("HumanoidRootPart")
local head: BasePart = character:WaitForChild("Head")

--modules
local cameraShaker = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("CameraShaker"))

-- Create CameraShaker instance:
local renderPriority = Enum.RenderPriority.Camera.Value + 1
local camShake

--vaulting
local model = nil

local raycastParams = RaycastParams.new()
raycastParams.FilterDescendantsInstances = {
	character,
	model,
	workspace.TrussParts,
	workspace.Map_NoBuild,
	workspace.Characters,
	workspace.DeadZombies,
	workspace.Zombies,
	workspace.Landscape,
	workspace.TreeTrunks,
}
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local vaultMoveNumber = 10
local canVault = true
local canMove = true
local vaultConnection = nil
local ledgePart = nil

local animations: Folder = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Vaulting")

local grabAnim = animator:LoadAnimation(animations:WaitForChild("Grab"))
local grabRightAnim = animator:LoadAnimation(animations:WaitForChild("GrabRight"))
local grabLeftAnim = animator:LoadAnimation(animations:WaitForChild("GrabLeft"))
local grabSound = SoundService:WaitForChild("CharacterSounds"):WaitForChild("VaultGrab")

local function ShakeCamera(shakeCf)
	camera.CFrame = camera.CFrame * shakeCf
end

--play vault sounds
local function playSound()
	local sound: Sound = grabSound:Clone()
	sound.PlaybackSpeed = Random.new():NextNumber(0.9, 1.1)
	sound.Parent = rootPart
	sound:Play()
	game.Debris:AddItem(sound, sound.TimeLength)
end

--check if part is above when tryin to vault or move
local function partCheck(ledge: CFrame)
	local vaultPartCheck = workspace:Raycast(
		ledge.Position + Vector3.new(0, 5, 0) + ledge.LookVector * 1,
		ledge.UpVector * -2,
		raycastParams
	)
	if vaultPartCheck == nil then
		return true
	else
		return false
	end
end

local function vaultMoveCheck(ray, anim)
	local localPos = ray.Instance.CFrame:PointToObjectSpace(ray.Position)
	local localLedgePos = Vector3.new(localPos.X, ray.Instance.Size.Y / 2, localPos.Z)
	local ledgePos = ray.Instance.CFrame:PointToWorldSpace(localLedgePos)
	local ledgeOffset = CFrame.lookAt(ledgePos, ledgePos - ray.Normal)
	model = ray.Instance:FindFirstAncestorWhichIsA("Model")

	if partCheck(ledgeOffset) then
		local magnitude = (ledgePos - head.Position).Magnitude
		if magnitude < 3 then
			local info = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, false, 0)
			local goal = { CFrame = ledgeOffset + Vector3.new(0, -2, 0) + ledgeOffset.LookVector * -1.5 }
			local tween = TweenService:Create(ledgePart, info, goal)
			tween:Play()
			canMove = false
			playSound()

			--screen shake
			camShake:Start()
			local dashShake = camShake:ShakeOnce(0.2, 13, 0, 0.5)
			dashShake:StartFadeOut(0.5)

			--play anim
			if anim == "Right" then
				grabRightAnim:Play()
			elseif anim == "Left" then
				grabLeftAnim:Play()
			end

			--vault move delay
			task.delay(0.5, function()
				canMove = true
			end)
		end
	end
end

--moving from left to right function(so my code isn't messy)
local function vaultMove(direction, anim)
	local moveRay =
		workspace:Raycast(rootPart.CFrame.Position, rootPart.CFrame.RightVector * direction * 5, raycastParams)
	if moveRay then
		if moveRay.Instance then
			vaultMoveCheck(moveRay, anim)
		end
	else
		local turnRay = workspace:Raycast(
			rootPart.CFrame.Position + Vector3.new(0, -1, 0) + rootPart.CFrame.RightVector * direction,
			rootPart.CFrame.RightVector * -direction + rootPart.CFrame.LookVector * 2,
			raycastParams
		)
		if turnRay then
			if turnRay.Instance then
				vaultMoveCheck(turnRay, anim)
			end
		end
	end
end

local function detectLedge()
	if character:FindFirstChildWhichIsA("Tool") then
		return
	end

	if
		canVault
		and (
			humanoid:GetState() == Enum.HumanoidStateType.Freefall
			or humanoid:GetState() == Enum.HumanoidStateType.Jumping
		)
	then
		local vaultCheck = workspace:Raycast(
			rootPart.CFrame.Position + Vector3.new(0, 1, 0),
			rootPart.CFrame.LookVector * 5,
			raycastParams
		)
		if vaultCheck then
			if vaultCheck.Instance then
				local localPos = vaultCheck.Instance.CFrame:PointToObjectSpace(vaultCheck.Position)
				local localLedgePos = Vector3.new(localPos.X, vaultCheck.Instance.Size.Y / 2, localPos.Z)
				local ledgePos = vaultCheck.Instance.CFrame:PointToWorldSpace(localLedgePos)
				local ledgeOffset = CFrame.lookAt(ledgePos, ledgePos - vaultCheck.Normal)
				model = vaultCheck.Instance:FindFirstAncestorWhichIsA("Model")

				local magnitude = (ledgePos - head.Position).Magnitude
				if magnitude < 4 then
					if partCheck(ledgeOffset) then
						canVault = false

						--screen shake
						camShake:Start()
						local dashShake = camShake:ShakeOnce(0.36, 12, 0, 0.5)
						dashShake:StartFadeOut(0.5)

						--player follows this part(you dont exactly need it but it makes tweening the player when they move easier unless there is a better way to do this but idk)
						ledgePart = Instance.new("Part")
						ledgePart.Parent = workspace
						ledgePart.Anchored = true
						ledgePart.Size = Vector3.one
						ledgePart.CFrame = ledgeOffset + Vector3.new(0, -2, 0) + ledgeOffset.LookVector * -1.5
						ledgePart.CanQuery = false
						ledgePart.CanCollide = false
						ledgePart.CanTouch = false
						ledgePart.Transparency = 1

						--play anim and sound
						grabAnim:Play()
						playSound()

						--connection while player is on a ledge
						vaultConnection = RunService.RenderStepped:Connect(function()
							if character:FindFirstChildWhichIsA("Tool") then
								humanoid:UnequipTools()
							end

							rootPart.Anchored = true
							humanoid.AutoRotate = false -- so shift lock doesnt't rotate character
							rootPart.CFrame = rootPart.CFrame:Lerp(
								CFrame.lookAt(ledgePart.Position, (ledgePart.CFrame * CFrame.new(0, 0, -1)).Position),
								0.25
							)
							humanoid:ChangeState(Enum.HumanoidStateType.Seated)
						end)
					end
				end
			end
		end
	elseif not canVault then
		canVault = true
		humanoid.AutoRotate = true
		rootPart.Anchored = false
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		grabAnim:Stop()

		--check if it exists and then disconnect
		if vaultConnection then
			vaultConnection:Disconnect()
		end

		if ledgePart then
			ledgePart:Destroy()
		end
	end
end

function module.init()
	camShake = cameraShaker.new(renderPriority, ShakeCamera)

	--detect if moving left or right
	humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		if (humanoid.MoveDirection:Dot(camera.CFrame.RightVector) > 0.7) and not canVault and canMove then
			vaultMove(vaultMoveNumber, "Right")
		end

		if (humanoid.MoveDirection:Dot(-camera.CFrame.RightVector) > 0.7) and not canVault and canMove then
			vaultMove(-vaultMoveNumber, "Left")
		end
	end)

	--pc and console support
	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then
			return
		end
		if input.KeyCode == Enum.KeyCode.ButtonA or input.KeyCode == Enum.KeyCode.Space then
			detectLedge()
		end
	end)

	--mobile support
	if
		UserInputService.TouchEnabled
		and not UserInputService.KeyboardEnabled
		and not UserInputService.MouseEnabled
		and not UserInputService.GamepadEnabled
		and not GuiService:IsTenFootInterface()
	then
		local jumpButton =
			player.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
		jumpButton.Activated:Connect(function()
			detectLedge()
		end)
	end
end

return module
