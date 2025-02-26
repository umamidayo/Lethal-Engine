local module = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local progressBar: Frame = playerGui:WaitForChild("Main"):WaitForChild("ProgressBar")
local filler: ImageLabel = progressBar:WaitForChild("Filler")
local textlabel = progressBar:WaitForChild("TextLabel")
local uiGradient: UIGradient = filler:WaitForChild("UIGradient")

local progressColor = Color3.fromRGB(255, 255, 255)
local progressCompleteColor = Color3.fromRGB(90, 148, 69)
local progressStopColor = Color3.fromRGB(131, 70, 70)
local progressTween: Tween

-- Starts the progress bar with a given time.
function module.startProgress(progressTime: number, text: string)
    textlabel.Text = text or ""
    progressBar.Visible = true
    local uiGradientTween = TweenInfo.new(progressTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    uiGradient.Offset = Vector2.new(0, 0)
    filler.ImageColor3 = progressColor
    progressTween = TweenService:Create(uiGradient, uiGradientTween, {
        Offset = Vector2.new(1, 0)
    })
    progressTween:Play()
end

function module.completeProgress(text: string)
    textlabel.Text = text or ""
    local completeTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local completeTween = TweenService:Create(filler, completeTweenInfo, {
        ImageColor3 = progressCompleteColor
    })
    completeTween:Play()
    completeTween.Completed:Wait()
    task.delay(1.5, function()
        progressBar.Visible = false
    end)
end

-- Stops the progress bar.
function module.stopProgress(text: string)
    textlabel.Text = text or ""
    progressTween:Pause()
    local cancelTweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
    local cancelTween = TweenService:Create(filler, cancelTweenInfo, {
        ImageColor3 = progressStopColor
    })
    cancelTween:Play()
    cancelTween.Completed:Wait()
    task.delay(1.5, function()
        progressBar.Visible = false
    end)
end

return module
