local SoundService = game:GetService("SoundService")
local module = {}

function module.init()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local Network = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Network"))
    local UIMount = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("UIModules"):WaitForChild("UIMount"))
    local Products = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Products"):WaitForChild("Products"))
    local Prettify = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Libraries"):WaitForChild("Prettify"))
    local Notifier = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Libraries"):WaitForChild("Notifier"))
    local Maid = require(ReplicatedStorage:WaitForChild("Common"):WaitForChild("Libraries"):WaitForChild("Maid"))
    local maid = Maid.new()
    local Icon = require(ReplicatedStorage:WaitForChild("Dependencies"):WaitForChild("Icon"))
    local icon = Icon.new()
    icon:setImage(16291069301)
    icon:setOrder(5)
    local itemSample: Frame = ReplicatedStorage:WaitForChild("UI"):WaitForChild("Store"):WaitForChild("ShopItemSample")

    local player = Players.LocalPlayer
    local playerGui = player.PlayerGui or player:WaitForChild("PlayerGui")
    local storeGui: ScreenGui = playerGui:WaitForChild("StoreGui")
    local mainFrame: Frame = storeGui:WaitForChild("Frame")
    local tabsFrame: Frame = mainFrame:WaitForChild("Tabs")
    local shopFrame: Frame = mainFrame:WaitForChild("Shop")
    local infoFrame: Frame = mainFrame:WaitForChild("Info")
    local footer: Frame = mainFrame:WaitForChild("Footer")
    local closeButton: ImageButton = mainFrame:WaitForChild("CloseButton")
    local purchaseButton = infoFrame.Frame.PurchaseFrame.TextButton

    local defaultInfoIcon = "rbxthumb://type=Asset&w=768&h=432&id=15612206871"

    local selectedProductId = nil
    local selectedProductData = nil
    local isTokenProduct = false

    local tweenInfos = {
        tab = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
    }

    local function createPrompt(parent)
        local newPrompt = ReplicatedStorage.UI.Prompt:Clone()
        newPrompt.Parent = parent
        return newPrompt
    end

    local function updateTokensInfo()
        if not player:GetAttribute("Tokens") then
            repeat
                task.wait(0.1)
            until player:GetAttribute("Tokens")
        end

        local tokens = player:GetAttribute("Tokens")
        footer.Contents.TokensFrame.Amount.Text = Prettify.FormatThousands(tokens)
    end

    local function updateInfoFrame(id, data)
        selectedProductId = id
        selectedProductData = data
        if data.Icon == "rbxassetid://16289490517" then
            isTokenProduct = true
        else
            isTokenProduct = false
        end
        infoFrame.Frame.TitleFrame.TextLabel.Text = data.Name
        infoFrame.Frame.DescriptionFrame.TextLabel.Text = data.Description
        infoFrame.Frame.CostFrame.TextLabel.Text = Prettify.FormatThousands(data.Cost)
        infoFrame.Frame.CostFrame.Icon.Image = data.Icon
        infoFrame.Frame.CostFrame.Icon.ImageColor3 = data.IconColor
        infoFrame.Frame.IconFrame.Icon.Image = data.InfoIcon or defaultInfoIcon
        infoFrame.Frame.Visible = true
    end

    local function updateShopList(products: {any})
        maid:DoCleaning()

        for id,data in products do
            local item = itemSample:Clone()
            maid:GiveTask(item)
            item.Name = data.Name
            item.TextButton.Text = data.Name
            item.Cost.Text = data.Cost
            item.Icon.Image = data.Icon
            item.Icon.ImageColor3 = data.IconColor
            item.Background.ImageColor3 = data.BackgroundColor or Color3.fromRGB(103, 103, 103)
            item.LayoutOrder = data.LayoutOrder or 0
            item.Parent = shopFrame.ScrollingFrame
            local button = item.TextButton
            UIMount.mount(item.TextButton, "button", {
                button = button,
                mouseEnter = function()
                    local buttonTween = TweenService:Create(item.TextButton, tweenInfos.tab, {
                        Rotation = 3,
                    })
                    buttonTween:Play()
                    buttonTween.Completed:Wait()
                    TweenService:Create(item.TextButton, tweenInfos.tab, {
                        Rotation = 0
                    }):Play()
                end,
                mouseLeave = function()
                end,
                mouseClick = function()
                    updateInfoFrame(id, data)
                    local buttonTween = TweenService:Create(button, tweenInfos.tab, {
                        Size = UDim2.fromScale(0.9, 0.6),
                    })
                    buttonTween:Play()
                    buttonTween.Completed:Wait()
                    TweenService:Create(button, tweenInfos.tab, {
                        Size = UDim2.fromScale(0.85, 0.5),
                    }):Play()
                end,
            })
        end
    end

    UIMount.mount(closeButton, "close", {
        close = storeGui,
        mouseEnter = function()
            local buttonTween = TweenService:Create(closeButton, tweenInfos.tab, {
                Rotation = 3,
            })
            buttonTween:Play()
            buttonTween.Completed:Wait()
            TweenService:Create(closeButton, tweenInfos.tab, {
                Rotation = 0
            }):Play()
        end,
        mouseLeave = function()
        end,
        mouseClick = function()
            storeGui.Enabled = false
        end
    })

    UIMount.mount(purchaseButton, "button", {
        button = purchaseButton,
        mouseEnter = function()
            local buttonTween = TweenService:Create(purchaseButton, tweenInfos.tab, {
                Rotation = 3,
            })
            buttonTween:Play()
            buttonTween.Completed:Wait()
            TweenService:Create(purchaseButton, tweenInfos.tab, {
                Rotation = 0
            }):Play()
        end,
        mouseLeave = function()
        end,
        mouseClick = function()
            if not isTokenProduct then
                MarketplaceService:PromptProductPurchase(player, selectedProductId)
            else
                if isTokenProduct then
                    local prompt = createPrompt(storeGui)
                    maid:GiveTask(prompt)
                    prompt.TextLabel.Text = `Purchase {selectedProductData.Name} for {Prettify.FormatThousands(selectedProductData.Cost)} tokens?`
                    maid:GiveTask(prompt.Yes.MouseButton1Click:Connect(function()
                        Network.fireServer(Network.RemoteEvents.StoreEvent, "Purchase", selectedProductId)
                        prompt:Destroy()
                    end))
                    maid:GiveTask(prompt.No.MouseButton1Click:Connect(function()
                        prompt:Destroy()
                    end))
                end
            end
            local buttonTween = TweenService:Create(purchaseButton, tweenInfos.tab, {
                Size = UDim2.fromScale(1.1, 1.1),
            })
            buttonTween:Play()
            buttonTween.Completed:Wait()
            TweenService:Create(purchaseButton, tweenInfos.tab, {
                Size = UDim2.fromScale(1, 1),
            }):Play()
        end,
    })

    for _,tab: Frame in tabsFrame.Contents:GetChildren() do
        if not tab:IsA("Frame") then continue end
        local button: TextButton = tab.TextButton
        local products = Products[tab.Name:lower()]
        UIMount.mount(tab, "button", {
            button = button,
            mouseEnter = function()
                local buttonTween = TweenService:Create(button, tweenInfos.tab, {
                    Rotation = 3,
                })
                buttonTween:Play()
                buttonTween.Completed:Wait()
                TweenService:Create(button, tweenInfos.tab, {
                    Rotation = 0
                }):Play()
            end,
            mouseLeave = function()
            end,
            mouseClick = function()
                updateShopList(products)
                local buttonTween = TweenService:Create(button, tweenInfos.tab, {
                    Size = UDim2.fromScale(0.9, 1.1),
                })
                buttonTween:Play()
                buttonTween.Completed:Wait()
                TweenService:Create(button, tweenInfos.tab, {
                    Size = UDim2.fromScale(0.8, 1),
                }):Play()
            end,
        })
        if tab.Name == "Tokens" then
            updateShopList(products)
        end
    end

    Network.connectEvent(Network.RemoteEvents.StoreEvent, function(eventType: string, params: any)
        if eventType == "TokenPurchase" then
            updateTokensInfo()
            SoundService:PlayLocalSound(SoundService.Store.CoinSound)
            Notifier.new("Your token purchase was successful!", nil, 7)
        elseif eventType == "GamepassPurchase" then
            SoundService:PlayLocalSound(SoundService.Store.GamepassSound)
            Notifier.new("Your gamepass purchase was successful!", nil, 7)
        elseif eventType == "ClassPurchase" then
            SoundService:PlayLocalSound(SoundService.Store.ClassSound)
            Notifier.new("Your class purchase was successful!", nil, 7)
        elseif eventType == "MaterialPurchase" then
            SoundService:PlayLocalSound(SoundService.Store.MaterialSound)
            Notifier.new("Your material purchase was successful!", nil, 7)
        end
    end, Network.t.string, Network.t.number)

    player:GetAttributeChangedSignal("Tokens"):Connect(updateTokensInfo)

    if player.Character then
        updateTokensInfo()
    else
        player.CharacterAdded:Once(updateTokensInfo)
    end

    icon:bindEvent("selected", function()
        icon:deselect()
        storeGui.Enabled = not storeGui.Enabled
    end)
end

return module
