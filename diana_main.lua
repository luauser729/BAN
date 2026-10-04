local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

getgenv = getgenv or function() return _G end
if getgenv().ShenScriptLoaded then return end
getgenv().ShenScriptLoaded = true
getgenv().ShenScriptStartTime = tick()

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats              = game:GetService("Stats")
local TweenService       = game:GetService("TweenService")
local VirtualUser        = game:GetService("VirtualUser")
local UserInputService   = game:GetService("UserInputService")
local LocalPlayer        = Players.LocalPlayer

function gradient(text, startColor, endColor)
    local result = ""
    local chars = {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end
    local length = #chars
    for i = 1, length do
        local t = (i - 1) / math.max(length - 1, 1)
        local r = startColor.R + (endColor.R - startColor.R) * t
        local g = startColor.G + (endColor.G - startColor.G) * t
        local b = startColor.B + (endColor.B - startColor.B) * t
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>',
            math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5),
            math.floor(b * 255 + 0.5), chars[i])
    end
    return result
end

function blueGradient(text)
    return gradient(text, Color3.fromRGB(0, 120, 255), Color3.fromRGB(150, 220, 255))
end

function rainbowGradient(text, phase)
    phase = phase or 0
    local result = ""
    local chars = {}
    for uchar in text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        table.insert(chars, uchar)
    end
    local length = #chars
    for i = 1, length do
        local t = ((i - 1) / math.max(length - 1, 1) + phase) % 1
        local color = Color3.fromHSV(t, 1, 1)
        result = result .. string.format('<font color="rgb(%d,%d,%d)">%s</font>',
            math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5), chars[i])
    end
    return result
end

local gamename = "Unknown Game"
pcall(function()
    gamename = MarketplaceService:GetProductInfo(game.PlaceId).Name or "Unknown Game"
end)

if getgenv().TransparencyEnabled == nil then getgenv().TransparencyEnabled = false end
if getgenv().PlayerNotifyEnabled == nil then getgenv().PlayerNotifyEnabled = false end
if getgenv().FpsDisplayEnabled == nil then getgenv().FpsDisplayEnabled = false end
if getgenv().AntiAfkEnabled == nil then getgenv().AntiAfkEnabled = true end
if getgenv().WelcomeTextEnabled == nil then getgenv().WelcomeTextEnabled = false end

local themes = {"Dark", "Light"}
local currentThemeIndex = 1

local Window = WindUI:CreateWindow({
    Title = blueGradient("[ SHEN | 神脚本 ]"),
    IconThemed = true,
    Folder = "shenscript",
    Size = UDim2.fromOffset(150, 100),
    Transparent = getgenv().TransparencyEnabled,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 150,
    Background = "https://raw.githubusercontent.com/tnine-n9/n9/refs/heads/main/tnine.png",
    BackgroundImageTransparency = 0.5,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            currentThemeIndex = currentThemeIndex + 1
            if currentThemeIndex > #themes then currentThemeIndex = 1 end
            local newTheme = themes[currentThemeIndex]
            WindUI:SetTheme(newTheme)
            WindUI:Notify({ Title = "主题已切换", Content = "当前主题: " .. newTheme, Duration = 2, Icon = "palette" })
        end,
    },
})

local OPEN_BTN_WIDTH  = 160
local OPEN_BTN_HEIGHT = 40

Window:EditOpenButton({
    Title = "★ SHEN｜神脚本 ★",
    CornerRadius = UDim.new(0, 10),
    StrokeThickness = 1.25,
    Draggable = true,
})

task.spawn(function()
    local main = Window.UIElements and Window.UIElements.Main
    if not main then
        repeat task.wait() until Window.UIElements and Window.UIElements.Main
        main = Window.UIElements.Main
    end
    local openBtn = main:FindFirstChild("OpenButton", true)
    if not openBtn then
        repeat task.wait() until main:FindFirstChild("OpenButton", true)
        openBtn = main:FindFirstChild("OpenButton", true)
    end
    if not openBtn then return end
    openBtn.Size = UDim2.fromOffset(OPEN_BTN_WIDTH, OPEN_BTN_HEIGHT)
    local textLabel = openBtn:FindFirstChildWhichIsA("TextLabel", true)
    if textLabel then
        textLabel.RichText = true
        textLabel.TextSize = 14
        textLabel.TextXAlignment = Enum.TextXAlignment.Center
        textLabel.TextYAlignment = Enum.TextYAlignment.Center
    end
    openBtn:GetPropertyChangedSignal("Size"):Connect(function()
        if openBtn.Size ~= UDim2.fromOffset(OPEN_BTN_WIDTH, OPEN_BTN_HEIGHT) then
            openBtn.Size = UDim2.fromOffset(OPEN_BTN_WIDTH, OPEN_BTN_HEIGHT)
        end
    end)
    local colorA = Color3.fromRGB(0, 80, 200)
    local colorB = Color3.fromRGB(0, 200, 255)
    RunService.Heartbeat:Connect(function()
        local t = tick() * 0.8
        local keypoints = {}
        for i = 0, 10 do
            local x = i / 10
            local wave = (math.sin((x - t) * math.pi * 2) + 1) / 2
            table.insert(keypoints, ColorSequenceKeypoint.new(x, colorA:Lerp(colorB, wave)))
        end
        Window:EditOpenButton({
            CornerRadius = UDim.new(0, 10),
            StrokeThickness = 1.25,
            Color = ColorSequence.new(keypoints),
        })
    end)
end)

Window:Tag({ Title = "免费", Radius = 5, Color = Color3.fromRGB(0, 150, 255) })
Window:SetToggleKey(Enum.KeyCode.F, true)

local borderEnabled = true
local borderConnection = nil

local function ensureBlurElement()
    local mainFrame = Window.UIElements and Window.UIElements.Main
    if not mainFrame then return end
    local blur = mainFrame:FindFirstChild("Blur")
    if not blur then
        blur = Instance.new("ImageLabel")
        blur.Name = "Blur"
        blur.Size = UDim2.new(1, 0, 1, 0)
        blur.Position = UDim2.new(0, 0, 0, 0)
        blur.BackgroundTransparency = 1
        blur.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
        blur.ImageTransparency = 0.2
        blur.ZIndex = 0
        blur.Parent = mainFrame
    end
    return blur
end

local function applyBorderColor(color, transparency)
    local mainFrame = Window.UIElements and Window.UIElements.Main
    if not mainFrame then return end
    local blur = mainFrame:FindFirstChild("Blur", true)
    if blur and blur:IsA("ImageLabel") then
        blur.ImageColor3 = color
        blur.ImageTransparency = transparency
    end
end

local function startBorderAnimation()
    if borderConnection then borderConnection:Disconnect() borderConnection = nil end
    if not borderEnabled then return end
    ensureBlurElement()
    borderConnection = RunService.Heartbeat:Connect(function()
        local mainFrame = Window.UIElements and Window.UIElements.Main
        if not mainFrame or not mainFrame.Visible then return end
        local time = tick() * 2
        local t = (math.sin(time) + 1) / 2
        local color = Color3.fromRGB(0, 100, 255):Lerp(Color3.fromRGB(80, 200, 255), t)
        applyBorderColor(color, 0.2)
    end)
end

local function stopBorderAnimation()
    if borderConnection then borderConnection:Disconnect() borderConnection = nil end
end

local function setupVisibilityListener()
    local mainFrame = Window.UIElements and Window.UIElements.Main
    if not mainFrame then
        task.spawn(function()
            repeat task.wait() until Window.UIElements and Window.UIElements.Main
            setupVisibilityListener()
        end)
        return
    end
    if mainFrame.Visible and borderEnabled then
        startBorderAnimation()
    elseif not mainFrame.Visible then
        stopBorderAnimation()
    end
    mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if mainFrame.Visible and borderEnabled then
            startBorderAnimation()
        else
            stopBorderAnimation()
        end
    end)
end

setupVisibilityListener()
Window:OnClose(function() stopBorderAnimation() end)

local infoGui = Instance.new("ScreenGui")
infoGui.Name = "ShenInfoPanel"
infoGui.ResetOnSpawn = false
infoGui.IgnoreGuiInset = true
infoGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
infoGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local EXPANDED_HEIGHT  = 100
local COLLAPSED_HEIGHT = 32
local PANEL_WIDTH      = 215
local START_X          = 12
local START_Y          = -12 - EXPANDED_HEIGHT

local infoFrame = Instance.new("Frame")
infoFrame.Name = "InfoFrame"
infoFrame.AnchorPoint = Vector2.new(0, 0)
infoFrame.Position = UDim2.new(0, START_X, 1, START_Y)
infoFrame.Size = UDim2.fromOffset(PANEL_WIDTH, EXPANDED_HEIGHT)
infoFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
infoFrame.BackgroundTransparency = 0.25
infoFrame.BorderSizePixel = 0
infoFrame.Active = true
infoFrame.ClipsDescendants = true
infoFrame.Parent = infoGui

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 8)
infoCorner.Parent = infoFrame

local infoStroke = Instance.new("UIStroke")
infoStroke.Color = Color3.fromRGB(0, 150, 255)
infoStroke.Thickness = 1.4
infoStroke.Transparency = 0.15
infoStroke.Parent = infoFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -160, 0, 24)
titleLabel.Position = UDim2.new(0, 12, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
titleLabel.Text = "状态信息"
titleLabel.ZIndex = 5
titleLabel.Parent = infoFrame

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, -80, 1, -38)
contentFrame.Position = UDim2.new(0, 6, 0, 32)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.ZIndex = 1
contentFrame.Parent = infoFrame

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 1)
contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
contentLayout.Parent = contentFrame

local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop = UDim.new(0, 2)
contentPad.PaddingBottom = UDim.new(0, 4)
contentPad.PaddingLeft = UDim.new(0, 4)
contentPad.PaddingRight = UDim.new(0, 4)
contentPad.Parent = contentFrame

local function makeRow(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 15)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.RichText = true
    lbl.Text = text
    lbl.Parent = contentFrame
    return lbl
end

local fpsLabel    = makeRow("帧率: --")
local pingLabel   = makeRow("延迟: --")
local memLabel    = makeRow("内存: --")
local playerLabel = makeRow("玩家: --")

local AVATAR_SIZE   = 54
local NAME_HEIGHT   = 14
local RIGHT_BLOCK_W = 62
local RIGHT_PAD     = 8

local avatarHolder = Instance.new("Frame")
avatarHolder.Name = "AvatarHolder"
avatarHolder.AnchorPoint = Vector2.new(1, 0.5)
avatarHolder.Position = UDim2.new(1, -RIGHT_PAD, 0.5, 6)
avatarHolder.Size = UDim2.fromOffset(RIGHT_BLOCK_W, AVATAR_SIZE + 2 + NAME_HEIGHT)
avatarHolder.BackgroundTransparency = 1
avatarHolder.ZIndex = 6
avatarHolder.Parent = infoFrame

local avatarImg = Instance.new("ImageLabel")
avatarImg.Name = "Avatar"
avatarImg.AnchorPoint = Vector2.new(0.5, 0)
avatarImg.Position = UDim2.new(0.5, 0, 0, 0)
avatarImg.Size = UDim2.fromOffset(AVATAR_SIZE, AVATAR_SIZE)
avatarImg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
avatarImg.BackgroundTransparency = 0.1
avatarImg.BorderSizePixel = 0
avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
avatarImg.ZIndex = 7
avatarImg.Parent = avatarHolder

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(0, 8)
avatarCorner.Parent = avatarImg

local nameLbl = Instance.new("TextLabel")
nameLbl.Name = "NameLabel"
nameLbl.AnchorPoint = Vector2.new(0.5, 0)
nameLbl.Position = UDim2.new(0.5, 0, 0, AVATAR_SIZE + 2)
nameLbl.Size = UDim2.new(1, 0, 0, NAME_HEIGHT)
nameLbl.BackgroundTransparency = 1
nameLbl.Font = Enum.Font.GothamBold
nameLbl.TextSize = 10
nameLbl.TextXAlignment = Enum.TextXAlignment.Center
nameLbl.TextYAlignment = Enum.TextYAlignment.Center
nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
nameLbl.RichText = true
nameLbl.Text = LocalPlayer.DisplayName
nameLbl.ZIndex = 7
nameLbl.Parent = avatarHolder

task.spawn(function()
    while task.wait(5) do
        if not avatarHolder.Parent then break end
        pcall(function()
            avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(LocalPlayer.UserId) .. "&w=150&h=150"
        end)
    end
end)

LocalPlayer:GetPropertyChangedSignal("DisplayName"):Connect(function()
    nameLbl.Text = LocalPlayer.DisplayName
end)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleBtn"
toggleBtn.Size = UDim2.fromOffset(22, 22)
toggleBtn.Position = UDim2.new(1, -58, 0, 5)
toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.Text = "–"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 16
toggleBtn.AutoButtonColor = true
toggleBtn.ZIndex = 10
toggleBtn.Active = true
toggleBtn.Parent = infoFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 6)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = Color3.fromRGB(255, 255, 255)
toggleStroke.Thickness = 1
toggleStroke.Transparency = 0.4
toggleStroke.Parent = toggleBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.fromOffset(22, 22)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
closeBtn.BackgroundTransparency = 0.2
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.AutoButtonColor = true
closeBtn.ZIndex = 10
closeBtn.Active = true
closeBtn.Parent = infoFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = Color3.fromRGB(255, 255, 255)
closeStroke.Thickness = 1
closeStroke.Transparency = 0.5
closeStroke.Parent = closeBtn

local expanded = true
local tweenInfo = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function setExpanded(state)
    expanded = state
    local targetHeight = expanded and EXPANDED_HEIGHT or COLLAPSED_HEIGHT
    TweenService:Create(infoFrame, tweenInfo, { Size = UDim2.fromOffset(PANEL_WIDTH, targetHeight) }):Play()
    if expanded then
        toggleBtn.Text = "–"
        contentFrame.Visible = true
        avatarHolder.Visible = true
    else
        toggleBtn.Text = "+"
        task.delay(0.22, function()
            if not expanded then
                contentFrame.Visible = false
                avatarHolder.Visible = false
            end
        end)
    end
end

toggleBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        setExpanded(not expanded)
    end
end)

closeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        infoGui:Destroy()
    end
end)

local dragging = false
local dragStart = nil
local startPos = nil
local dragInput = nil

local function isOverBtn(btn, screenPos)
    local p = btn.AbsolutePosition
    local s = btn.AbsoluteSize
    return screenPos.X >= p.X and screenPos.X <= p.X + s.X
       and screenPos.Y >= p.Y and screenPos.Y <= p.Y + s.Y
end

local function updateDrag(input)
    if input == dragInput then
        local delta = input.Position - dragStart
        infoFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end

infoFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if isOverBtn(toggleBtn, input.Position) or isOverBtn(closeBtn, input.Position) or isOverBtn(avatarHolder, input.Position) then
            return
        end
        dragging = true
        dragStart = input.Position
        startPos = infoFrame.Position
        dragInput = input
    end
end)

infoFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        if dragging and dragInput == input then
            updateDrag(input)
        end
    end
end)

infoFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        dragInput = nil
    end
end)

local fps = 60
RunService.RenderStepped:Connect(function(dt)
    if dt > 0 then
        fps = fps + (1 / dt - fps) * 0.1
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        if not infoGui.Parent then break end
        local mem = Stats:GetTotalMemoryUsageMb()
        local ping = 0
        pcall(function()
            ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        fpsLabel.Text    = string.format('帧率: <font color="rgb(0,255,120)">%d</font>', math.floor(fps + 0.5))
        pingLabel.Text   = string.format('延迟: <font color="rgb(255,200,0)">%d ms</font>', math.floor(ping))
        memLabel.Text    = string.format('内存: <font color="rgb(120,200,255)">%.1f MB</font>', mem)
        playerLabel.Text = string.format('玩家: <font color="rgb(255,120,120)">%d / %d</font>', #Players:GetPlayers(), Players.MaxPlayers)
    end
end)

local welcomeGui = Instance.new("ScreenGui")
welcomeGui.Name = "ShenWelcomeGui"
welcomeGui.ResetOnSpawn = false
welcomeGui.IgnoreGuiInset = true
welcomeGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
welcomeGui.DisplayOrder = 998
welcomeGui.Enabled = false
welcomeGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local welcomeLabel = Instance.new("TextLabel")
welcomeLabel.Name = "WelcomeLabel"
welcomeLabel.AnchorPoint = Vector2.new(1, 0)
welcomeLabel.Position = UDim2.new(1, -20, 0, 60)
welcomeLabel.Size = UDim2.fromOffset(400, 70)
welcomeLabel.BackgroundTransparency = 1
welcomeLabel.Font = Enum.Font.GothamBold
welcomeLabel.TextSize = 26
welcomeLabel.TextXAlignment = Enum.TextXAlignment.Right
welcomeLabel.TextYAlignment = Enum.TextYAlignment.Top
welcomeLabel.RichText = true
welcomeLabel.Text = ""
welcomeLabel.Parent = welcomeGui

task.spawn(function()
    local phase = 0
    while task.wait(0.05) do
        if not welcomeGui.Parent then break end
        if not getgenv().WelcomeTextEnabled then continue end
        phase = (phase + 0.02) % 1
        local line1 = rainbowGradient("欢迎使用神脚本", phase)
        local line2 = rainbowGradient(": " .. LocalPlayer.Name, phase)
        welcomeLabel.Text = line1 .. "\n" .. line2
    end
end)

local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "ShenFpsGui"
fpsGui.ResetOnSpawn = false
fpsGui.IgnoreGuiInset = true
fpsGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
fpsGui.DisplayOrder = 998
fpsGui.Enabled = false
fpsGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local fpsDisplay = Instance.new("TextLabel")
fpsDisplay.Name = "FpsDisplay"
fpsDisplay.AnchorPoint = Vector2.new(1, 0)
fpsDisplay.Position = UDim2.new(1, -20, 0, 145)
fpsDisplay.Size = UDim2.fromOffset(200, 24)
fpsDisplay.BackgroundTransparency = 1
fpsDisplay.Font = Enum.Font.GothamBold
fpsDisplay.TextSize = 16
fpsDisplay.TextXAlignment = Enum.TextXAlignment.Right
fpsDisplay.TextColor3 = Color3.fromRGB(0, 200, 255)
fpsDisplay.TextStrokeTransparency = 0.3
fpsDisplay.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
fpsDisplay.Text = "FPS: --"
fpsDisplay.Parent = fpsGui

task.spawn(function()
    while task.wait(0.25) do
        if not fpsGui.Parent then break end
        fpsDisplay.Text = string.format("FPS: %d", math.floor(fps + 0.5))
    end
end)

task.spawn(function()
    while task.wait(60) do
        if not getgenv().AntiAfkEnabled then continue end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

LocalPlayer.Idled:Connect(function()
    if not getgenv().AntiAfkEnabled then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

local MainTab = Window:Tab({ Title = "信息", Icon = "crown" })
MainTab:Paragraph({ Title = "玩家信息", Desc = "", Image = "user", ImageSize = 20 })

local function getExecutorName()
    local name = "Unknown"
    if identifyexecutor then
        local ok, result = pcall(identifyexecutor)
        if ok and result then name = result end
    end
    return name
end

local function getAccountAge()
    local ok, days = pcall(function() return LocalPlayer.AccountAge end)
    if ok and days then return days end
    return 0
end

MainTab:Paragraph({ Title = "你的注入器:" .. getExecutorName(), Desc = "" })
MainTab:Paragraph({ Title = "你的账号年龄:" .. getAccountAge() .. "天", Desc = "" })
MainTab:Paragraph({ Title = "您的用户ID:" .. tostring(LocalPlayer.UserId), Desc = "" })
MainTab:Paragraph({ Title = "您的用户名:" .. LocalPlayer.Name, Desc = "" })
MainTab:Paragraph({ Title = "您当前服务器的ID:" .. tostring(game.JobId), Desc = "" })
MainTab:Paragraph({ Title = "更新日志: 2026年8月23日21点", Desc = "" })

MainTab:Toggle({
    Title = "显示用户信息",
    Desc = "开启后在屏幕右上角显示彩虹闪烁欢迎文字",
    Value = false,
    Callback = function(state)
        getgenv().WelcomeTextEnabled = state
        welcomeGui.Enabled = state
    end,
})

MainTab:Toggle({
    Title = "玩家进出通知",
    Desc = "开启后玩家加入/离开服务器时右下角弹出通知",
    Value = false,
    Callback = function(state) getgenv().PlayerNotifyEnabled = state end,
})

MainTab:Toggle({
    Title = "显示 FPS",
    Desc = "开启后屏幕右上角显示实时帧率",
    Value = false,
    Callback = function(state)
        getgenv().FpsDisplayEnabled = state
        fpsGui.Enabled = state
    end,
})

MainTab:Toggle({
    Title = "防挂机",
    Desc = "开启后每 60 秒模拟一次操作，防止 20 分钟被踢出",
    Value = true,
    Callback = function(state) getgenv().AntiAfkEnabled = state end,
})

local NoticeTab = Window:Tab({ Title = "公告", Icon = "megaphone" })
NoticeTab:Paragraph({ Title = "📢 神脚本公告", Desc = "", Image = "megaphone", ImageSize = 20 })
NoticeTab:Paragraph({ Title = "1. 本脚本永久免费，请勿倒卖！", Desc = "" })
NoticeTab:Paragraph({ Title = "2. 如有问题请联系作者反馈", Desc = "" })
NoticeTab:Paragraph({ Title = "3. 使用脚本造成的一切后果由使用者自行承担", Desc = "" })
NoticeTab:Paragraph({ Title = "4. 更新日志：2026年8月23日21点", Desc = "" })
NoticeTab:Paragraph({ Title = "5. 感谢您的使用，祝您游戏愉快！", Desc = "" })
NoticeTab:Divider()
NoticeTab:Paragraph({ Title = "🐧 官方 QQ 群", Desc = "点击下方按钮复制群号加入我们" })

NoticeTab:Button({
    Title = "点击复制 QQ 群号：1128281427",
    Desc = "复制后打开 QQ 搜索群号即可加入",
    Callback = function()
        local qqGroup = "1128281427"
        if setclipboard then
            setclipboard(qqGroup)
            WindUI:Notify({ Title = "✅ 复制成功", Content = "QQ 群号 " .. qqGroup .. " 已复制到剪贴板", Duration = 3, Icon = "clipboard-check" })
        else
            WindUI:Notify({ Title = "❌ 复制失败", Content = "您的执行器不支持 setclipboard", Duration = 3, Icon = "alert-circle" })
        end
    end,
})

NoticeTab:Paragraph({ Title = "👉 加群获取最新脚本 + 反馈问题", Desc = "" })

local LocalTab = Window:Tab({ Title = "本地玩家", Icon = "user" })
LocalTab:Paragraph({ Title = "本地玩家修改", Desc = "修改移速、跳跃等自身属性", Image = "user", ImageSize = 20 })

local function getHum()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end

local speedEnabled = false
local speedValue = 16
local speedConn = nil

local function applySpeed()
    if speedConn then speedConn:Disconnect() speedConn = nil end
    if not speedEnabled then return end
    speedConn = RunService.Heartbeat:Connect(function()
        local hum = getHum()
        if hum then
            if hum.WalkSpeed ~= speedValue then hum.WalkSpeed = speedValue end
        end
    end)
end

LocalTab:Toggle({
    Title = "开启速度修改",
    Desc = "锁定角色移动速度",
    Value = false,
    Callback = function(state) speedEnabled = state; applySpeed() end,
})

LocalTab:Input({
    Title = "速度数值",
    Desc = "请输入 0 - 99999 之间的数值",
    Value = "16",
    Placeholder = "默认 16",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 and num <= 99999 then
            speedValue = num
        else
            WindUI:Notify({ Title = "数值错误", Content = "请输入 0 - 99999 之间的有效数字", Duration = 3, Icon = "alert-circle" })
        end
    end,
})

LocalTab:Divider()

local jumpEnabled = false
local jumpValue = 50
local jumpMode = "修改原生跳跃"
local jumpConn = nil

local function applyJump()
    if jumpConn then jumpConn:Disconnect() jumpConn = nil end
    if not jumpEnabled then return end
    jumpConn = RunService.Heartbeat:Connect(function()
        local hum = getHum()
        if not hum then return end
        if jumpMode == "修改原生跳跃" then
            if hum.UseJumpPower then
                if hum.JumpPower ~= jumpValue then hum.JumpPower = jumpValue end
            else
                local targetHeight = jumpValue / 50 * 7.5
                if math.abs(hum.JumpHeight - targetHeight) > 0.01 then hum.JumpHeight = targetHeight end
            end
        else
            if hum.UseJumpPower and hum.JumpPower ~= jumpValue then hum.JumpPower = jumpValue end
        end
    end)
end

LocalTab:Dropdown({
    Title = "跳跃模式",
    Desc = "选择跳跃修改方式",
    Values = { "修改原生跳跃", "覆盖式跳跃" },
    Value = "修改原生跳跃",
    Callback = function(option) jumpMode = option end,
})

LocalTab:Toggle({
    Title = "开启跳跃修改",
    Desc = "让角色可以跳得更高",
    Value = false,
    Callback = function(state) jumpEnabled = state; applyJump() end,
})

LocalTab:Input({
    Title = "跳跃数值",
    Desc = "输入跳跃力度 (0-500)",
    Value = "50",
    Placeholder = "输入跳跃力度",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 and num <= 500 then
            jumpValue = num
        else
            WindUI:Notify({ Title = "数值错误", Content = "请输入 0 - 500 之间的有效数字", Duration = 3, Icon = "alert-circle" })
        end
    end,
})

LocalTab:Divider()

local gravityEnabled = false
local gravityValue = 196.2
local gravityConn = nil

local function applyGravity()
    if gravityConn then gravityConn:Disconnect() gravityConn = nil end
    if not gravityEnabled then
        workspace.Gravity = 196.2
        return
    end
    gravityConn = RunService.Heartbeat:Connect(function()
        if workspace.Gravity ~= gravityValue then workspace.Gravity = gravityValue end
    end)
end

LocalTab:Toggle({
    Title = "开启重力控制",
    Desc = "修改全局重力（默认 196.2）",
    Value = false,
    Callback = function(state) gravityEnabled = state; applyGravity() end,
})

LocalTab:Input({
    Title = "重力数值",
    Desc = "推荐 0 - 500，默认 196.2",
    Value = "196.2",
    Placeholder = "默认 196.2",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 and num <= 9999 then
            gravityValue = num
            if gravityEnabled then workspace.Gravity = gravityValue end
        else
            WindUI:Notify({ Title = "数值错误", Content = "请输入 0 - 9999 之间的有效数字", Duration = 3, Icon = "alert-circle" })
        end
    end,
})

LocalTab:Divider()

local spinEnabled = false
local spinValue = 40
local spinConn = nil

local function setAutoRotate(state)
    local hum = getHum()
    if hum then hum.AutoRotate = state end
end

local function applySpin()
    if spinConn then spinConn:Disconnect() spinConn = nil end
    if not spinEnabled then setAutoRotate(true) return end
    setAutoRotate(false)
    spinConn = RunService.RenderStepped:Connect(function(dt)
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.AutoRotate then hum.AutoRotate = false end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local degPerSec = spinValue * 36
        local angle = math.rad(degPerSec) * dt
        root.CFrame = root.CFrame * CFrame.Angles(0, angle, 0)
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if spinEnabled then task.wait(0.3); setAutoRotate(false) end
end)

LocalTab:Toggle({
    Title = "开启旋转控制",
    Desc = "开启后角色原地自转",
    Value = false,
    Callback = function(state) spinEnabled = state; applySpin() end,
})

LocalTab:Input({
    Title = "旋转速度",
    Desc = "每 +10 = 每秒多转 1 圈（10=1圈/秒，40=4圈/秒，100=10圈/秒）",
    Value = "40",
    Placeholder = "默认 40 = 每秒 4 圈",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 1 and num <= 500 then
            spinValue = num
        else
            WindUI:Notify({ Title = "数值错误", Content = "请输入 1 - 500 之间的有效数字", Duration = 3, Icon = "alert-circle" })
        end
    end,
})

LocalTab:Divider()

local infJumpEnabled = false
local infJumpConn = nil

local function applyInfJump()
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    if not infJumpEnabled then return end
    infJumpConn = UserInputService.JumpRequest:Connect(function()
        local hum = getHum()
        if hum and infJumpEnabled then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

LocalTab:Toggle({
    Title = "开启无限跳跃",
    Desc = "允许在空中无限次跳跃",
    Value = false,
    Callback = function(state) infJumpEnabled = state; applyInfJump() end,
})

LocalTab:Divider()

local noclipEnabled = false
local noclipConn = nil

local function applyNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if not noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
        return
    end
    noclipConn = RunService.Stepped:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.CanCollide then
                part.CanCollide = false
            end
        end
    end)
end

LocalTab:Toggle({
    Title = "开启穿墙",
    Desc = "可穿过墙壁/门（部分游戏可能无效）",
    Value = false,
    Callback = function(state) noclipEnabled = state; applyNoclip() end,
})

LocalTab:Divider()

local antiFlingEnabled = false
local antiFlingConn = nil
local savedCanCollide = {}
local antiFlingOverlapParams = OverlapParams.new()
antiFlingOverlapParams.FilterType = Enum.RaycastFilterType.Exclude
antiFlingOverlapParams.MaxParts = 20

local otherCharCache = {}
local function refreshOtherChars()
    otherCharCache = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            otherCharCache[plr.Character] = true
        end
    end
end

local function isOtherPlayerPart(part)
    local model = part:FindFirstAncestorOfClass("Model")
    return model and otherCharCache[model] == true
end

local function restoreAllCanCollide()
    for part, orig in pairs(savedCanCollide) do
        if part and part.Parent then
            pcall(function() part.CanCollide = orig end)
        end
    end
    savedCanCollide = {}
end

local antiFlingAccum = 0
local ANTI_FLING_INTERVAL = 1 / 30

local function applyAntiFling()
    if antiFlingConn then antiFlingConn:Disconnect() antiFlingConn = nil end
    if not antiFlingEnabled then
        restoreAllCanCollide()
        return
    end
    refreshOtherChars()
    local lastRefresh = tick()
    antiFlingAccum = 0
    antiFlingConn = RunService.Heartbeat:Connect(function(dt)
        antiFlingAccum = antiFlingAccum + dt
        if antiFlingAccum < ANTI_FLING_INTERVAL then return end
        antiFlingAccum = 0
        if tick() - lastRefresh > 2 then
            refreshOtherChars()
            lastRefresh = tick()
        end
        local char = LocalPlayer.Character
        if not char then return end
        antiFlingOverlapParams.FilterDescendantsInstances = { char }
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                if savedCanCollide[part] == nil then
                    savedCanCollide[part] = part.CanCollide
                end
                local overlaps = workspace:GetPartsInPart(part, antiFlingOverlapParams)
                local touching = false
                for _, hit in ipairs(overlaps) do
                    if isOtherPlayerPart(hit) then
                        touching = true
                        break
                    end
                end
                if touching and part.CanCollide then
                    part.CanCollide = false
                elseif not touching and savedCanCollide[part] and not part.CanCollide then
                    part.CanCollide = true
                end
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    savedCanCollide = {}
    if antiFlingEnabled then
        task.wait(0.3)
        refreshOtherChars()
    end
end)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(refreshOtherChars)
end)

Players.PlayerRemoving:Connect(refreshOtherChars)

LocalTab:Toggle({
    Title = "开启防甩飞",
    Desc = "靠近其他玩家自动穿透，离开后恢复碰撞（可随时开关）",
    Value = false,
    Callback = function(state)
        antiFlingEnabled = state
        applyAntiFling()
        if state then
            WindUI:Notify({ Title = "防甩飞", Content = "已开启，你现在可以穿透其他玩家", Duration = 2, Icon = "shield" })
        else
            WindUI:Notify({ Title = "防甩飞", Content = "已关闭", Duration = 2, Icon = "shield-off" })
        end
    end,
})

LocalTab:Divider()

local respawnEnabled = false
local lastDeathCFrame = nil
local originalAutoLoads = Players.CharacterAutoLoads
local respawnConnections = {}

local function clearRespawnConnections()
    for _, c in ipairs(respawnConnections) do
        pcall(function() c:Disconnect() end)
    end
    respawnConnections = {}
end

local function addRespawnConnection(conn)
    table.insert(respawnConnections, conn)
end

local function watchCharForRespawn(char)
    if not respawnEnabled or not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then hum = char:WaitForChild("Humanoid", 5) end
    if not hum then return end
    addRespawnConnection(hum.Died:Connect(function()
        if not respawnEnabled then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then lastDeathCFrame = root.CFrame end
        task.wait(0.2)
        if not respawnEnabled then return end
        pcall(function() LocalPlayer:LoadCharacter() end)
    end))
end

local function onRespawned(char)
    if not respawnEnabled then return end
    local root = char:WaitForChild("HumanoidRootPart", 5)
    if not root then return end
    if lastDeathCFrame then root.CFrame = lastDeathCFrame end
    task.spawn(function()
        for _ = 1, 10 do
            if not respawnEnabled then return end
            local r = char:FindFirstChild("HumanoidRootPart")
            if r and lastDeathCFrame then
                if (r.Position - lastDeathCFrame.Position).Magnitude > 5 then
                    r.CFrame = lastDeathCFrame
                end
            end
            task.wait(0.1)
        end
    end)
end

local function applyRespawn()
    clearRespawnConnections()
    if not respawnEnabled then
        Players.CharacterAutoLoads = originalAutoLoads
        lastDeathCFrame = nil
        return
    end
    Players.CharacterAutoLoads = false
    lastDeathCFrame = nil
    addRespawnConnection(LocalPlayer.CharacterAdded:Connect(function(char)
        watchCharForRespawn(char)
        onRespawned(char)
    end))
    if LocalPlayer.Character then
        watchCharForRespawn(LocalPlayer.Character)
    end
end

LocalTab:Toggle({
    Title = "开启死亡原地复活",
    Desc = "死亡后在原地复活（部分游戏可能无效）",
    Value = false,
    Callback = function(state) respawnEnabled = state; applyRespawn() end,
})

LocalTab:Divider()

local invisEnabled = false
local invisConn = nil
local savedTransparency = {}

local function makeInvisible()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if savedTransparency[part] == nil then savedTransparency[part] = part.Transparency end
            part.Transparency = 1
        elseif part:IsA("Decal") then
            if savedTransparency[part] == nil then savedTransparency[part] = part.Transparency end
            part.Transparency = 1
        end
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("BillboardGui") or child:IsA("TextLabel") then child.Enabled = false end
        end
    end
end

local function makeVisible()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if (part:IsA("BasePart") or part:IsA("Decal")) and savedTransparency[part] ~= nil then
            part.Transparency = savedTransparency[part]
            savedTransparency[part] = nil
        end
    end
    local head = char:FindFirstChild("Head")
    if head then
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("BillboardGui") or child:IsA("TextLabel") then child.Enabled = true end
        end
    end
end

local function applyInvis()
    if invisConn then invisConn:Disconnect() invisConn = nil end
    if not invisEnabled then
        makeVisible()
        savedTransparency = {}
        return
    end
    invisConn = RunService.Heartbeat:Connect(function() makeInvisible() end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if invisEnabled then task.wait(0.3); makeInvisible() end
end)

LocalTab:Toggle({
    Title = "开启隐身",
    Desc = "开启后角色完全隐身",
    Value = false,
    Callback = function(state) invisEnabled = state; applyInvis() end,
})

LocalTab:Divider()

local healthLabel = LocalTab:Paragraph({
    Title = "❤️ 生命值: -- / --",
    Desc = "实时更新",
})

task.spawn(function()
    while task.wait(0.5) do
        local hum = getHum()
        if hum then
            pcall(function()
                healthLabel:SetTitle(string.format(
                    '❤️ 生命值: <font color="rgb(0,255,120)">%d</font> / %d',
                    math.floor(hum.Health + 0.5),
                    math.floor(hum.MaxHealth + 0.5)
                ))
            end)
        else
            pcall(function() healthLabel:SetTitle("❤️ 生命值: -- / --") end)
        end
    end
end)local CommonTab = Window:Tab({ Title = "通用", Icon = "settings" })
CommonTab:Paragraph({ Title = "通用功能", Desc = "适用于大多数游戏的通用工具", Image = "settings", ImageSize = 20 })

CommonTab:Button({
    Title = "🔄 服务器跳跃",
    Desc = "跳转到同游戏的其他服务器",
    Callback = function()
        pcall(function()
            local TS = game:GetService("TeleportService")
            local HttpService = game:GetService("HttpService")
            local req = (syn and syn.request) or http_request or request
            if not req then
                WindUI:Notify({ Title = "❌ 不支持", Content = "执行器不支持 HTTP 请求", Duration = 3, Icon = "alert-circle" })
                return
            end
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            local res = req({ Url = url, Method = "GET" })
            local data = HttpService:JSONDecode(res.Body)
            for _, server in ipairs(data.data or {}) do
                if server.id ~= game.JobId and server.playing < server.maxPlayers then
                    TS:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    WindUI:Notify({ Title = "✅ 正在跳转", Content = "目标服务器: " .. server.id, Duration = 3, Icon = "check" })
                    return
                end
            end
            WindUI:Notify({ Title = "❌ 失败", Content = "未找到可用服务器", Duration = 3, Icon = "alert-circle" })
        end)
    end,
})

CommonTab:Button({
    Title = "🔁 重新进入当前服务器",
    Desc = "重新连接当前服务器",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end,
})

CommonTab:Button({
    Title = "⚡ 解锁 FPS 上限 (设置为 240)",
    Desc = "提升游戏帧率上限",
    Callback = function()
        pcall(function()
            if setfpscap then
                setfpscap(240)
                WindUI:Notify({ Title = "✅ 成功", Content = "FPS 上限已设置为 240", Duration = 3, Icon = "check" })
            else
                WindUI:Notify({ Title = "❌ 不支持", Content = "执行器不支持 setfpscap", Duration = 3, Icon = "alert-circle" })
            end
        end)
    end,
})

CommonTab:Button({
    Title = "💀 重置角色",
    Desc = "立即重生角色",
    Callback = function()
        pcall(function()
            if LocalPlayer.Character then LocalPlayer.Character:BreakJoints() end
        end)
    end,
})

local xrayEnabled = false
local xrayTransparency = 0.75
local xraySaved = {}
local xrayThread = nil

local function isXrayExcluded(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then return true end
    if obj:IsDescendantOf(workspace.Terrain) then return true end
    if obj:IsDescendantOf(workspace.CurrentCamera) then return true end
    return false
end

local function applyXrayToPart(part)
    if not part:IsA("BasePart") then return end
    if isXrayExcluded(part) then return end
    if xraySaved[part] == nil then xraySaved[part] = part.Transparency end
    part.Transparency = xrayTransparency
end

local function applyXrayAll()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then applyXrayToPart(obj) end
    end
end

local function restoreXrayAll()
    for obj, t in pairs(xraySaved) do
        if obj and obj.Parent then pcall(function() obj.Transparency = t end) end
    end
    xraySaved = {}
end

local function startXray()
    if xrayThread then pcall(function() task.cancel(xrayThread) end); xrayThread = nil end
    applyXrayAll()
    xrayThread = task.spawn(function()
        while xrayEnabled do task.wait(0.5); applyXrayAll() end
    end)
end

local function stopXray()
    if xrayThread then pcall(function() task.cancel(xrayThread) end); xrayThread = nil end
    restoreXrayAll()
end

CommonTab:Toggle({
    Title = "🔦 X光透视地图",
    Desc = "把整个地图变半透明，能看到墙后的东西",
    Value = false,
    Callback = function(state)
        xrayEnabled = state
        if state then
            startXray()
            WindUI:Notify({ Title = "🔦 X光透视", Content = "已开启，地图已透明化", Duration = 2, Icon = "eye" })
        else
            stopXray()
            WindUI:Notify({ Title = "🔦 X光透视", Content = "已关闭，地图已恢复", Duration = 2, Icon = "eye-off" })
        end
    end,
})

CommonTab:Input({
    Title = "🔦 X光透明度",
    Desc = "0 = 完全可见，1 = 完全透明，推荐 0.7~0.9",
    Value = "0.75",
    Placeholder = "默认 0.75",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 and num <= 1 then
            xrayTransparency = num
            if xrayEnabled then applyXrayAll() end
        else
            WindUI:Notify({ Title = "数值错误", Content = "请输入 0 - 1 之间的数字", Duration = 3, Icon = "alert-circle" })
        end
    end,
})

CommonTab:Button({
    Title = "🚂 火车头",
    Desc = "点击执行火车头脚本",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/giobolqv1/A-Train-by-GioBolqv1-/refs/heads/main/train.lua"))()
        end)
        WindUI:Notify({ Title = "🚂 火车头", Content = "脚本已执行", Duration = 2, Icon = "train" })
    end,
})

CommonTab:Button({
    Title = "🌐 TX 全自动翻译",
    Desc = "点击执行 TX 全自动翻译脚本",
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"))()
        end)
        if ok then
            WindUI:Notify({ Title = "🌐 TX 翻译", Content = "脚本已执行", Duration = 2, Icon = "languages" })
        else
            WindUI:Notify({ Title = "❌ 加载失败", Content = tostring(err), Duration = 4, Icon = "alert-circle" })
        end
    end,
})

local NDS_FALL_ENABLED = false
local NDS_FALL_CONN = nil

local function NDS_applyToChar(char)
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end
    if NDS_FALL_CONN then NDS_FALL_CONN:Disconnect() NDS_FALL_CONN = nil end
    NDS_FALL_CONN = RunService.Heartbeat:Connect(function()
        if not NDS_FALL_ENABLED then return end
        if not hrp or not hrp.Parent then return end
        local vel = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.zero
        RunService.RenderStepped:Wait()
        if hrp and hrp.Parent then
            hrp.AssemblyLinearVelocity = vel
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if NDS_FALL_ENABLED then task.wait(0.3); NDS_applyToChar(char) end
end)

CommonTab:Toggle({
    Title = "💥 禁用摔落伤害（自然灾害）",
    Desc = "专为《自然灾害生存》设计，阻止摔落扣血",
    Value = false,
    Callback = function(state)
        NDS_FALL_ENABLED = state
        if state then
            if LocalPlayer.Character then NDS_applyToChar(LocalPlayer.Character) end
            WindUI:Notify({ Title = "💥 摔落保护", Content = "已开启", Duration = 2, Icon = "shield" })
        else
            if NDS_FALL_CONN then NDS_FALL_CONN:Disconnect() NDS_FALL_CONN = nil end
            WindUI:Notify({ Title = "💥 摔落保护", Content = "已关闭", Duration = 2, Icon = "shield" })
        end
    end,
})

local voidWalkEnabled = false
local voidWalkPart = nil
local voidWalkConn = nil

local function removeVoidWalkPart()
    if voidWalkPart then pcall(function() voidWalkPart:Destroy() end); voidWalkPart = nil end
end

local function createVoidWalkPart()
    removeVoidWalkPart()
    local p = Instance.new("Part")
    p.Name = "ShenVoidWalkPlatform"
    p.Size = Vector3.new(8, 1, 8)
    p.Anchored = true
    p.CanCollide = true
    p.Transparency = 1
    p.CanQuery = false
    p.CanTouch = false
    p.Massless = true
    p.Parent = workspace
    voidWalkPart = p
end

local function applyVoidWalk()
    if voidWalkConn then voidWalkConn:Disconnect() voidWalkConn = nil end
    if not voidWalkEnabled then removeVoidWalkPart(); return end
    createVoidWalkPart()
    local lastY = nil
    voidWalkConn = RunService.Heartbeat:Connect(function()
        if not voidWalkEnabled then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if not voidWalkPart or not voidWalkPart.Parent then createVoidWalkPart() end
        local pos = hrp.Position
        local isFalling = false
        if lastY and pos.Y < lastY - 0.15 then isFalling = true end
        lastY = pos.Y
        local targetPlatY = isFalling and (pos.Y - 3.5) or voidWalkPart.Position.Y
        voidWalkPart.CFrame = CFrame.new(pos.X, targetPlatY, pos.Z)
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if voidWalkEnabled then task.wait(0.3); applyVoidWalk() end
end)

local function updateVoidWalkQuickUI()
    if _G._shenVoidWalkQuickBtn then
        if voidWalkEnabled then
            _G._shenVoidWalkQuickBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            _G._shenVoidWalkQuickBtn.Text = "☁️\nON"
        else
            _G._shenVoidWalkQuickBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            _G._shenVoidWalkQuickBtn.Text = "☁️\nOFF"
        end
    end
end

CommonTab:Toggle({
    Title = "☁️ 踏空",
    Desc = "脚下持续生成隐形平台，可在空中站立/行走",
    Value = false,
    Callback = function(state)
        voidWalkEnabled = state
        applyVoidWalk()
        updateVoidWalkQuickUI()
        WindUI:Notify({ Title = "☁️ 踏空", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "cloud" })
    end,
})

local quickGui = Instance.new("ScreenGui")
quickGui.Name = "ShenVoidWalkQuick"
quickGui.ResetOnSpawn = false
quickGui.IgnoreGuiInset = true
quickGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
quickGui.DisplayOrder = 997
quickGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
quickGui.Enabled = false

local quickBtn = Instance.new("TextButton")
quickBtn.Name = "QuickBtn"
quickBtn.Size = UDim2.fromOffset(60, 60)
quickBtn.Position = UDim2.new(0, 20, 0.5, -30)
quickBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
quickBtn.BackgroundTransparency = 0.15
quickBtn.Text = "☁️\nOFF"
quickBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
quickBtn.TextSize = 14
quickBtn.Font = Enum.Font.GothamBold
quickBtn.AutoButtonColor = false
quickBtn.Active = true
quickBtn.Parent = quickGui

local qCorner = Instance.new("UICorner")
qCorner.CornerRadius = UDim.new(1, 0)
qCorner.Parent = quickBtn

local qStroke = Instance.new("UIStroke")
qStroke.Color = Color3.fromRGB(0, 150, 255)
qStroke.Thickness = 1.5
qStroke.Transparency = 0.3
qStroke.Parent = quickBtn

_G._shenVoidWalkQuickBtn = quickBtn

local qDragging = false
local qDragStart = nil
local qStartPos = nil
local qMoved = false

quickBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        qDragging = true
        qMoved = false
        qDragStart = input.Position
        qStartPos = quickBtn.Position
    end
end)

quickBtn.InputChanged:Connect(function(input)
    if qDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - qDragStart
        if math.abs(delta.X) > 4 or math.abs(delta.Y) > 4 then qMoved = true end
        quickBtn.Position = UDim2.new(
            qStartPos.X.Scale, qStartPos.X.Offset + delta.X,
            qStartPos.Y.Scale, qStartPos.Y.Offset + delta.Y
        )
    end
end)

quickBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if qDragging and not qMoved then
            voidWalkEnabled = not voidWalkEnabled
            applyVoidWalk()
            updateVoidWalkQuickUI()
            WindUI:Notify({
                Title = "☁️ 踏空",
                Content = voidWalkEnabled and "已开启" or "已关闭",
                Duration = 1.5,
                Icon = "cloud",
            })
        end
        qDragging = false
        qDragStart = nil
        qStartPos = nil
        qMoved = false
    end
end)

CommonTab:Toggle({
    Title = "🔘 显示踏空快捷按钮",
    Desc = "默认关闭，开启后屏幕左侧出现踏空悬浮按钮",
    Value = false,
    Callback = function(state)
        quickGui.Enabled = state
    end,
})

local QIURONG_SILK_CODE = [==[
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera
local pgui = lp:WaitForChild("PlayerGui")

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    if getnamecallmethod() == "FireServer" and tostring(self) == "ForceSelfDamage" then
        return nil
    end
    return old(self, ...)
end)
setreadonly(mt, true)

if pgui:FindFirstChild("QiuRong_Silk_V15") then pgui.QiuRong_Silk_V15:Destroy() end
local ScreenGui = Instance.new("ScreenGui", pgui)
ScreenGui.Name = "QiuRong_Silk_V15"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 180, 0, 140)
MainFrame.Position = UDim2.new(0.5, -90, 0.4, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "官方"
Title.TextColor3 = Color3.new(0.8, 0.8, 0.8)
Title.TextSize = 12

local SpeedInput = Instance.new("TextBox", MainFrame)
SpeedInput.Size = UDim2.new(0, 140, 0, 30); SpeedInput.Position = UDim2.new(0.5, -70, 0, 40)
SpeedInput.BackgroundColor3 = Color3.fromRGB(40, 40, 40); SpeedInput.Text = "35"
SpeedInput.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", SpeedInput).CornerRadius = UDim.new(0, 8)

local Toggle = Instance.new("TextButton", MainFrame)
Toggle.Size = UDim2.new(0, 140, 0, 40); Toggle.Position = UDim2.new(0.5, -70, 0, 85)
Toggle.BackgroundColor3 = Color3.fromRGB(60, 60, 60); Toggle.Text = "纯坐标飞行: OFF"
Toggle.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 10)

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then update(input) end
end)

local joystickActive = false
local joystickVector = Vector3.new()

local JoyBase = Instance.new("Frame", ScreenGui)
JoyBase.Size = UDim2.new(0, 130, 0, 130)
JoyBase.Position = UDim2.new(0, 40, 1, -160)
JoyBase.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
JoyBase.BackgroundTransparency = 0.6
JoyBase.Active = false
JoyBase.ZIndex = 100
JoyBase.Visible = false
Instance.new("UICorner", JoyBase).CornerRadius = UDim.new(1, 0)

local JoyKnob = Instance.new("Frame", JoyBase)
JoyKnob.Size = UDim2.new(0, 60, 0, 60)
JoyKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
JoyKnob.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
JoyKnob.BackgroundTransparency = 0.2
JoyKnob.ZIndex = 101
Instance.new("UICorner", JoyKnob).CornerRadius = UDim.new(1, 0)

local MAX_RADIUS = 50
local joyBasePos = Vector2.new()

local function updateJoystickFromTouch(touchPos)
    local delta = touchPos - joyBasePos
    local mag = delta.Magnitude
    if mag > MAX_RADIUS then
        delta = delta.Unit * MAX_RADIUS
        mag = MAX_RADIUS
    end
    JoyKnob.Position = UDim2.new(0.5, delta.X - 30, 0.5, delta.Y - 30)
    local norm = delta / MAX_RADIUS
    joystickVector = Vector3.new(norm.X, 0, norm.Y)
end

local joyMode = false
local JoyButton = nil
local function setJoyMode(mode)
    joyMode = mode
    if JoyBase then JoyBase.Visible = false end
    if JoyButton then
        JoyButton.Text = joyMode and "ON" or "摇"
        JoyButton.BackgroundColor3 = joyMode and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(70, 70, 70)
    end
    if not joyMode then
        joystickActive = false
        joystickVector = Vector3.new()
    end
end

local function isInJoyZone(pos)
    if not joyMode then return false end
    local vp = camera.ViewportSize
    return pos.X <= vp.X * 0.5 and pos.Y >= vp.Y * 0.55
end

local joyDragInput = nil

UserInputService.InputBegan:Connect(function(input, processed)
    if not joyMode then return end
    if input.UserInputType == Enum.UserInputType.Touch then
        if isInJoyZone(input.Position) and not joyDragInput then
            joystickActive = true
            joyDragInput = input
            joyBasePos = input.Position
            JoyBase.Position = UDim2.fromOffset(input.Position.X - 65, input.Position.Y - 65)
            JoyBase.Visible = true
            JoyKnob.Position = UDim2.new(0.5, -30, 0.5, -30)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input, processed)
    if not joyMode then return end
    if joystickActive and joyDragInput and input == joyDragInput then
        if input.UserInputType == Enum.UserInputType.Touch then
            updateJoystickFromTouch(input.Position)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input, processed)
    if joyDragInput and input == joyDragInput then
        joystickActive = false
        joystickVector = Vector3.new()
        joyDragInput = nil
        if joyMode then JoyBase.Visible = false end
    end
end)

local isFlying = false
local flySpeed = 35
local animCache
local ControlModule = require(lp.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
local flightConnection = nil
local lastUpdateTime = tick()

local function startFly()
    local char = lp.Character or lp.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local animate = char:FindFirstChild("Animate")

    if animate then animCache = animate; animate.Parent = nil end
    hum.AutoRotate = false

    if flightConnection then flightConnection:Disconnect() end

    lastUpdateTime = tick()
    flightConnection = RunService.Heartbeat:Connect(function()
        if not isFlying or not char.Parent then
            if flightConnection then flightConnection:Disconnect() end
            return
        end

        local now = tick()
        local dt = now - lastUpdateTime
        lastUpdateTime = now

        local moveVec
        if joystickActive and joyMode then
            moveVec = joystickVector
        else
            moveVec = ControlModule:GetMoveVector()
        end

        local camCF = camera.CFrame
        local moveDir = (camCF.LookVector * -moveVec.Z) + (camCF.RightVector * moveVec.X) + (Vector3.new(0, moveVec.Y, 0))

        if moveVec.Magnitude > 0 then
            local newPos = hrp.Position + moveDir.Unit * (flySpeed * dt)
            hrp.CFrame = CFrame.new(newPos, newPos + camCF.LookVector)
        else
            hrp.CFrame = CFrame.lookAlong(hrp.Position, Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z))
        end

        hrp.AssemblyLinearVelocity = Vector3.new()
    end)
end

Toggle.MouseButton1Click:Connect(function()
    isFlying = not isFlying
    flySpeed = tonumber(SpeedInput.Text) or 35
    Toggle.Text = isFlying and "已开启 - 运行中" or "纯坐标飞行: OFF"
    TweenService:Create(Toggle, TweenInfo.new(0.3), {BackgroundColor3 = isFlying and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(60, 60, 60)}):Play()
    if isFlying then
        startFly()
    else
        if flightConnection then
            flightConnection:Disconnect()
            flightConnection = nil
        end
        local char = lp.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.AutoRotate = true end
            local animate = char:FindFirstChild("Animate")
            if animCache and not animate then
                animCache.Parent = char
                animCache = nil
            end
        end
    end
end)

local function topBtn(t, x, c, f)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0, 25, 0, 25); b.Position = UDim2.new(1, x, 0, 5); b.Text = t
    b.BackgroundColor3 = c; b.TextColor3 = Color3.new(1, 1, 1); Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(f)
end

topBtn("×", -30, Color3.fromRGB(150, 50, 50), function()
    isFlying = false
    if flightConnection then flightConnection:Disconnect() end
    local char = lp.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.AutoRotate = true end
        local animate = char:FindFirstChild("Animate")
        if animCache and not animate then
            animCache.Parent = char
        end
    end
    ScreenGui:Destroy()
end)

topBtn("-", -60, Color3.fromRGB(70, 70, 70), function()
    local isCollapsed = MainFrame.Size.Y.Offset < 140
    local targetH = isCollapsed and 140 or 35
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 180, 0, targetH)}):Play()
    Toggle.Visible, SpeedInput.Visible = isCollapsed, isCollapsed
end)

JoyButton = Instance.new("TextButton", MainFrame)
JoyButton.Size = UDim2.new(0, 26, 0, 26)
JoyButton.Position = UDim2.new(0, 6, 0, 2)
JoyButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
JoyButton.BorderSizePixel = 0
JoyButton.Text = "摇"
JoyButton.TextColor3 = Color3.new(1, 1, 1)
JoyButton.TextSize = 13
local JoyBtnCorner = Instance.new("UICorner", JoyButton)
JoyBtnCorner.CornerRadius = UDim.new(0, 6)
JoyButton.ZIndex = 50
JoyButton.MouseButton1Click:Connect(function()
    setJoyMode(not joyMode)
end)

MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame:TweenSize(UDim2.new(0, 180, 0, 140), "Out", "Back", 0.5)
]==]

CommonTab:Button({
    Title = "🚗 坐标飞车",
    Desc = "点击弹出纯坐标飞行 + 手机移动摇杆面板",
    Callback = function()
        local ok, err = pcall(function()
            local fn = loadstring(QIURONG_SILK_CODE)
            if fn then fn() end
        end)
        if ok then
            WindUI:Notify({ Title = "🚗 坐标飞车", Content = "面板已打开", Duration = 2, Icon = "car" })
        else
            WindUI:Notify({ Title = "❌ 加载失败", Content = tostring(err), Duration = 4, Icon = "alert-circle" })
        end
    end,
})

CommonTab:Divider()

CommonTab:Button({
    Title = "✈️ 飞行 V3",
    Desc = "点击直接执行飞行脚本",
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/9966/main/7878"))()
        end)
        if ok then
            WindUI:Notify({ Title = "✈️ 飞行 V3", Content = "飞行脚本已执行", Duration = 2, Icon = "plane" })
        else
            WindUI:Notify({ Title = "❌ 加载失败", Content = tostring(err), Duration = 4, Icon = "alert-circle" })
        end
    end,
})

CommonTab:Button({
    Title = "✈️ 神飞行",
    Desc = "点击执行神飞行脚本",
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/bbb/main/shen.lua"))()
        end)
        if ok then
            WindUI:Notify({ Title = "✈️ 神飞行", Content = "脚本已执行", Duration = 2, Icon = "plane" })
        else
            WindUI:Notify({ Title = "❌ 加载失败", Content = tostring(err), Duration = 4, Icon = "alert-circle" })
        end
    end,
})

CommonTab:Button({
    Title = "🦸 无敌少侠",
    Desc = "点击执行无敌少侠脚本",
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/396abc/Script/refs/heads/main/MobileFly.lua"))()
        end)
        if ok then
            WindUI:Notify({ Title = "🦸 无敌少侠", Content = "脚本已执行", Duration = 2, Icon = "shield" })
        else
            WindUI:Notify({ Title = "❌ 加载失败", Content = tostring(err), Duration = 4, Icon = "alert-circle" })
        end
    end,
})

CommonTab:Button({
    Title = "🦸 祖国人",
    Desc = "点击执行祖国人脚本",
    Callback = function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/-/refs/heads/main/祖国人汉化"))()
        end)
        if ok then
            WindUI:Notify({ Title = "🦸 祖国人", Content = "脚本已执行", Duration = 2, Icon = "shield" })
        else
            WindUI:Notify({ Title = "❌ 加载失败", Content = tostring(err), Duration = 4, Icon = "alert-circle" })
        end
    end,
})local ItemTab = Window:Tab({ Title = "道具", Icon = "package" })

ItemTab:Paragraph({
    Title = "神之道具",
    Desc = "开启后在背包生成对应道具，拿在手上点击使用",
    Image = "package",
    ImageSize = 20,
})

local function buildGlowTool(name, color, tooltip)
    local tool = Instance.new("Tool")
    tool.Name = name
    tool.RequiresHandle = true
    tool.CanBeDropped = false
    tool.ToolTip = tooltip or name

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Transparency = 0.2
    handle.Material = Enum.Material.Neon
    handle.Color = color
    handle.CanCollide = false
    handle.Massless = true
    handle.Parent = tool

    local light = Instance.new("PointLight")
    light.Color = color
    light.Range = 8
    light.Brightness = 2
    light.Parent = handle

    local sel = Instance.new("SelectionBox")
    sel.Adornee = handle
    sel.LineThickness = 0.05
    sel.Color3 = color
    sel.Parent = handle

    return tool
end

local function makeToolManager(toolName, builder, onActivated)
    local enabled = false
    local conn = nil
    local watcher = nil

    local function give()
        if not enabled then return end
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if not bp then return end
        local char = LocalPlayer.Character
        if bp:FindFirstChild(toolName) then return end
        if char and char:FindFirstChild(toolName) then return end

        local tool = builder()
        tool.Parent = bp

        if conn then pcall(function() conn:Disconnect() end) end
        conn = tool.Activated:Connect(function()
            if not enabled then return end
            pcall(onActivated, tool)
        end)
    end

    local function remove()
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            local t = bp:FindFirstChild(toolName)
            if t then t:Destroy() end
        end
        local char = LocalPlayer.Character
        if char then
            local t = char:FindFirstChild(toolName)
            if t then t:Destroy() end
        end
        if conn then
            pcall(function() conn:Disconnect() end)
            conn = nil
        end
    end

    local function startWatch()
        if watcher then return end
        watcher = task.spawn(function()
            while enabled do
                task.wait(0.5)
                pcall(give)
            end
            watcher = nil
        end)
    end

    LocalPlayer.CharacterAdded:Connect(function()
        if enabled then
            task.wait(0.5)
            give()
        end
    end)

    return {
        set = function(state)
            enabled = state
            if state then
                give()
                startWatch()
            else
                remove()
            end
        end,
    }
end

local TP_TOOL_NAME = "神之传送器"
local tpManager = makeToolManager(
    TP_TOOL_NAME,
    function()
        local tool = Instance.new("Tool")
        tool.Name = TP_TOOL_NAME
        tool.RequiresHandle = true
        tool.CanBeDropped = false
        tool.ToolTip = "拿起点地图任意位置，瞬移过去"

        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.Transparency = 0.2
        handle.Material = Enum.Material.Neon
        handle.Color = Color3.fromRGB(0, 180, 255)
        handle.CanCollide = false
        handle.Massless = true
        handle.Parent = tool

        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(0, 180, 255)
        light.Range = 8
        light.Brightness = 2
        light.Parent = handle

        local selection = Instance.new("SelectionBox")
        selection.Adornee = handle
        selection.LineThickness = 0.05
        selection.Color3 = Color3.fromRGB(0, 200, 255)
        selection.Parent = handle

        return tool
    end,
    function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local mouse = LocalPlayer:GetMouse()
        if not mouse then return end
        local hit = mouse.Hit
        if not hit then return end
        hrp.CFrame = CFrame.new(hit.Position)
    end
)

ItemTab:Toggle({
    Title = "🎯 传送道具",
    Desc = "背包生成「神之传送器」，拿起来点地图任意位置瞬移过去",
    Value = false,
    Callback = function(state)
        tpManager.set(state)
        if state then
            WindUI:Notify({ Title = "🎯 传送道具", Content = "已发放「神之传送器」，拿起来点哪传哪", Duration = 3, Icon = "crosshair" })
        else
            WindUI:Notify({ Title = "🎯 传送道具", Content = "道具已移除", Duration = 2, Icon = "x" })
        end
    end,
})

local blinkManager = makeToolManager(
    "神之闪现",
    function() return buildGlowTool("神之闪现", Color3.fromRGB(255, 200, 0), "点击朝鼠标方向瞬移") end,
    function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local mouse = LocalPlayer:GetMouse()
        if not mouse or not mouse.Hit then return end

        local from = hrp.Position
        local to = mouse.Hit.Position
        local dir = (to - from)
        local dist = math.min(dir.Magnitude, 60)
        if dist < 1 then return end
        hrp.CFrame = CFrame.new(from + dir.Unit * dist + Vector3.new(0, 3, 0))
    end
)

ItemTab:Toggle({
    Title = "⚡ 神之闪现",
    Desc = "背包生成「神之闪现」，拿起来点地图方向瞬移（最多 60 格）",
    Value = false,
    Callback = function(state)
        blinkManager.set(state)
        if state then
            WindUI:Notify({ Title = "⚡ 神之闪现", Content = "已发放，拿起来点哪闪哪", Duration = 2, Icon = "zap" })
        else
            WindUI:Notify({ Title = "⚡ 神之闪现", Content = "已移除", Duration = 2, Icon = "x" })
        end
    end,
})

local bombManager = makeToolManager(
    "神之炸弹",
    function()
        return buildGlowTool("神之炸弹", Color3.fromRGB(255, 120, 0), "点击在鼠标位置生成爆炸推力")
    end,
    function()
        local mouse = LocalPlayer:GetMouse()
        if not mouse or not mouse.Hit then return end

        local pos = mouse.Hit.Position

        local bomb = Instance.new("Part")
        bomb.Shape = Enum.PartType.Ball
        bomb.Size = Vector3.new(1, 1, 1)
        bomb.Position = pos
        bomb.Anchored = true
        bomb.CanCollide = false
        bomb.Material = Enum.Material.Neon
        bomb.Color = Color3.fromRGB(255, 100, 0)
        bomb.Parent = workspace

        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 120, 0)
        light.Range = 30
        light.Brightness = 6
        light.Parent = bomb

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://5801257793"
        sound.Volume = 3
        sound.Parent = bomb
        pcall(function() sound:Play() end)

        TweenService:Create(bomb, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = Vector3.new(8, 8, 8),
            Transparency = 1,
        }):Play()

        local attach = Instance.new("Attachment")
        attach.Parent = bomb
        local sparks = Instance.new("ParticleEmitter")
        sparks.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        sparks.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 200)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 160, 40)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(120, 30, 0)),
        })
        sparks.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 1.5),
            NumberSequenceKeypoint.new(1.0, 0.0),
        })
        sparks.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.0),
            NumberSequenceKeypoint.new(1.0, 1.0),
        })
        sparks.Lifetime = NumberRange.new(0.4, 0.8)
        sparks.Rate = 200
        sparks.Speed = NumberRange.new(20, 40)
        sparks.SpreadAngle = Vector2.new(180, 180)
        sparks.LightEmission = 1
        sparks.Parent = attach

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - pos).Magnitude < 25 then
                    local dir = (hrp.Position - pos)
                    if dir.Magnitude < 0.1 then dir = Vector3.new(0, 1, 0) end
                    hrp.AssemblyLinearVelocity = dir.Unit * 50 + Vector3.new(0, 30, 0)
                end
            end
        end

        task.delay(1, function()
            pcall(function() bomb:Destroy() end)
        end)
    end
)

ItemTab:Toggle({
    Title = "💣 神之炸弹",
    Desc = "背包生成「神之炸弹」，点击在鼠标位置产生可见爆炸+音效+推力",
    Value = false,
    Callback = function(state)
        bombManager.set(state)
        if state then
            WindUI:Notify({ Title = "💣 神之炸弹", Content = "已发放，点击轰炸", Duration = 2, Icon = "bomb" })
        else
            WindUI:Notify({ Title = "💣 神之炸弹", Content = "已移除", Duration = 2, Icon = "x" })
        end
    end,
})

local shieldEnabled = false
local shieldPart = nil
local shieldConn = nil

local function applyShield()
    if shieldConn then shieldConn:Disconnect() shieldConn = nil end
    if shieldPart then pcall(function() shieldPart:Destroy() end) shieldPart = nil end

    if not shieldEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    shieldPart = Instance.new("Part")
    shieldPart.Shape = Enum.PartType.Ball
    shieldPart.Size = Vector3.new(6, 6, 6)
    shieldPart.Anchored = true
    shieldPart.CanCollide = false
    shieldPart.CanQuery = false
    shieldPart.CanTouch = false
    shieldPart.Material = Enum.Material.ForceField
    shieldPart.Color = Color3.fromRGB(0, 200, 255)
    shieldPart.Transparency = 0.5
    shieldPart.Parent = workspace

    shieldConn = RunService.Heartbeat:Connect(function()
        if not shieldEnabled or not shieldPart or not shieldPart.Parent then return end
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        shieldPart.CFrame = r.CFrame
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if shieldEnabled then
        task.wait(0.3)
        applyShield()
    end
end)

ItemTab:Toggle({
    Title = "🛡️ 神之护盾（视觉）",
    Desc = "给自己套一个跟随的发光球体，纯装饰无实际防御",
    Value = false,
    Callback = function(state)
        shieldEnabled = state
        applyShield()
    end,
})

local torchManager = makeToolManager(
    "火把",
    function()
        local tool = Instance.new("Tool")
        tool.Name = "火把"
        tool.RequiresHandle = true
        tool.CanBeDropped = false
        tool.ToolTip = "本地火把，只有你自己能看见"

        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(0.35, 2.4, 0.35)
        handle.Color = Color3.fromRGB(90, 55, 25)
        handle.Material = Enum.Material.Wood
        handle.CanCollide = false
        handle.Massless = true
        handle.Parent = tool

        local attach = Instance.new("Attachment")
        attach.Name = "FireAttach"
        attach.Position = Vector3.new(0, handle.Size.Y / 2, 0)
        attach.Parent = handle

        local fire = Instance.new("ParticleEmitter")
        fire.Name = "Fire"
        fire.Texture = "rbxasset://textures/particles/fire_main.dds"
        fire.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 240, 120)),
            ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 160, 40)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(120, 30, 0)),
        })
        fire.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.3),
            NumberSequenceKeypoint.new(0.5, 0.8),
            NumberSequenceKeypoint.new(1.0, 0.0),
        })
        fire.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.2),
            NumberSequenceKeypoint.new(1.0, 1.0),
        })
        fire.Lifetime = NumberRange.new(0.5, 0.9)
        fire.Rate = 25
        fire.Speed = NumberRange.new(0.5, 1.5)
        fire.SpreadAngle = Vector2.new(15, 15)
        fire.LightEmission = 0.8
        fire.LightInfluence = 0.2
        fire.Parent = attach

        local light = Instance.new("PointLight")
        light.Color = Color3.fromRGB(255, 170, 60)
        light.Range = 18
        light.Brightness = 2.5
        light.Shadows = true
        light.Parent = handle

        return tool
    end,
    function() end
)

ItemTab:Toggle({
    Title = "🔥 火把",
    Desc = "背包生成「火把」，拿在手上发光发热，只有你自己能看见",
    Value = false,
    Callback = function(state)
        torchManager.set(state)
        if state then
            WindUI:Notify({ Title = "🔥 火把", Content = "已发放，拿起来照明（仅自己可见）", Duration = 2, Icon = "flame" })
        else
            WindUI:Notify({ Title = "🔥 火把", Content = "已移除", Duration = 2, Icon = "x" })
        end
    end,
})

local rainbowEnabled = false
local rainbowAttachment = nil
local rainbowConn = nil

local function applyRainbow()
    if rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
    if rainbowAttachment then pcall(function() rainbowAttachment:Destroy() end) rainbowAttachment = nil end

    if not rainbowEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    rainbowAttachment = Instance.new("Attachment")
    rainbowAttachment.Name = "RainbowTrailAttach"
    rainbowAttachment.Position = Vector3.new(0, 0, 0)
    rainbowAttachment.Parent = hrp

    local rainbowEmitter = Instance.new("ParticleEmitter")
    rainbowEmitter.Name = "RainbowTrail"
    rainbowEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    rainbowEmitter.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.2, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.4, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 255)),
    })
    rainbowEmitter.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 1.2),
        NumberSequenceKeypoint.new(1.0, 0.0),
    })
    rainbowEmitter.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.2),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    rainbowEmitter.Lifetime = NumberRange.new(0.8, 1.4)
    rainbowEmitter.Rate = 60
    rainbowEmitter.Speed = NumberRange.new(0.5, 2)
    rainbowEmitter.SpreadAngle = Vector2.new(180, 180)
    rainbowEmitter.LightEmission = 0.7
    rainbowEmitter.LightInfluence = 0.2
    rainbowEmitter.Parent = rainbowAttachment
end

LocalPlayer.CharacterAdded:Connect(function()
    if rainbowEnabled then
        task.wait(0.3)
        applyRainbow()
    end
end)

ItemTab:Toggle({
    Title = "🌈 彩虹拖尾",
    Desc = "身上拖一条彩虹色粒子拖尾（本地视觉效果）",
    Value = false,
    Callback = function(state)
        rainbowEnabled = state
        applyRainbow()
        WindUI:Notify({ Title = "🌈 彩虹拖尾", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "sparkles" })
    end,
})

-- ✨ 星辰环绕
local starsEnabled = false
local starsConn = nil
local starsParts = {}

local function applyStars()
    if starsConn then starsConn:Disconnect() starsConn = nil end
    for _, p in ipairs(starsParts) do
        pcall(function() p:Destroy() end)
    end
    starsParts = {}

    if not starsEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for i = 1, 6 do
        local star = Instance.new("Part")
        star.Shape = Enum.PartType.Ball
        star.Size = Vector3.new(0.4, 0.4, 0.4)
        star.Anchored = true
        star.CanCollide = false
        star.CanQuery = false
        star.CanTouch = false
        star.Material = Enum.Material.Neon
        star.Color = Color3.fromHSV((i - 1) / 6, 1, 1)
        star.Parent = workspace

        local light = Instance.new("PointLight")
        light.Color = star.Color
        light.Range = 4
        light.Brightness = 2
        light.Parent = star

        table.insert(starsParts, star)
    end

    local t = 0
    starsConn = RunService.RenderStepped:Connect(function(dt)
        t = t + dt * 2
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        for i, star in ipairs(starsParts) do
            if star.Parent then
                local ang = t + (i - 1) * (math.pi * 2 / 6)
                star.CFrame = r.CFrame * CFrame.new(math.cos(ang) * 3, 4, math.sin(ang) * 3)
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if starsEnabled then task.wait(0.3); applyStars() end
end)

ItemTab:Toggle({
    Title = "✨ 星辰环绕",
    Desc = "头顶环绕 6 颗彩色光球（本地视觉）",
    Value = false,
    Callback = function(state)
        starsEnabled = state
        applyStars()
        WindUI:Notify({ Title = "✨ 星辰环绕", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "sparkles" })
    end,
})

-- 🎇 神之礼花
local burstManager = makeToolManager(
    "神之礼花",
    function() return buildGlowTool("神之礼花", Color3.fromRGB(255, 100, 200), "点击在鼠标位置炸出彩色粒子") end,
    function()
        local mouse = LocalPlayer:GetMouse()
        if not mouse or not mouse.Hit then return end
        local pos = mouse.Hit.Position

        local anchor = Instance.new("Part")
        anchor.Size = Vector3.new(0.1, 0.1, 0.1)
        anchor.Position = pos
        anchor.Anchored = true
        anchor.CanCollide = false
        anchor.Transparency = 1
        anchor.CanQuery = false
        anchor.CanTouch = false
        anchor.Parent = workspace

        local attach = Instance.new("Attachment")
        attach.Parent = anchor

        local pe = Instance.new("ParticleEmitter")
        pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
        pe.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0, 150, 255)),
            ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 0, 255)),
        })
        pe.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 1.5),
            NumberSequenceKeypoint.new(1.0, 0.0),
        })
        pe.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.0),
            NumberSequenceKeypoint.new(1.0, 1.0),
        })
        pe.Lifetime = NumberRange.new(1, 1.6)
        pe.Speed = NumberRange.new(30, 60)
        pe.SpreadAngle = Vector2.new(180, 180)
        pe.Rate = 0
        pe.LightEmission = 1
        pe.Parent = attach
        pe:Emit(200)

        task.delay(2, function()
            pcall(function() anchor:Destroy() end)
        end)
    end
)

ItemTab:Toggle({
    Title = "🎇 神之礼花",
    Desc = "背包生成「神之礼花」，点击在鼠标位置炸出彩色粒子",
    Value = false,
    Callback = function(state)
        burstManager.set(state)
        WindUI:Notify({ Title = "🎇 神之礼花", Content = state and "已发放" or "已移除", Duration = 2, Icon = "sparkles" })
    end,
})

-- 🎈 气球
local balloonEnabled = false
local balloonPart = nil
local balloonConn = nil

local function applyBalloon()
    if balloonConn then balloonConn:Disconnect() balloonConn = nil end
    if balloonPart then pcall(function() balloonPart:Destroy() end) balloonPart = nil end

    if not balloonEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    balloonPart = Instance.new("Part")
    balloonPart.Shape = Enum.PartType.Ball
    balloonPart.Size = Vector3.new(2, 2.5, 2)
    balloonPart.Anchored = true
    balloonPart.CanCollide = false
    balloonPart.CanQuery = false
    balloonPart.CanTouch = false
    balloonPart.Color = Color3.fromRGB(255, 80, 120)
    balloonPart.Material = Enum.Material.SmoothPlastic
    balloonPart.Parent = workspace

    balloonConn = RunService.Heartbeat:Connect(function()
        if not balloonEnabled or not balloonPart or not balloonPart.Parent then return end
        local c = LocalPlayer.Character
        if not c then return end
        local h = c:FindFirstChild("Head")
        if not h then return end
        balloonPart.CFrame = h.CFrame * CFrame.new(0, 3.5, 0)
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if balloonEnabled then task.wait(0.3); applyBalloon() end
end)

ItemTab:Toggle({
    Title = "🎈 气球",
    Desc = "头顶飘一个粉色气球（本地视觉）",
    Value = false,
    Callback = function(state)
        balloonEnabled = state
        applyBalloon()
        WindUI:Notify({ Title = "🎈 气球", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "circle" })
    end,
})

-- 👑 王冠（真皇冠造型，戴在头顶）
local crownEnabled = false
local crownModel = nil
local crownConn = nil

local function buildCrownModel()
    local model = Instance.new("Model")
    model.Name = "ShenCrown"

    local gold = Color3.fromRGB(255, 200, 40)

    local base = Instance.new("Part")
    base.Name = "Base"
    base.Shape = Enum.PartType.Cylinder
    base.Size = Vector3.new(0.3, 1.4, 1.4)
    base.Material = Enum.Material.Metal
    base.Color = gold
    base.Anchored = true
    base.CanCollide = false
    base.CanQuery = false
    base.CanTouch = false
    base.Parent = model
    base:SetAttribute("Type", "Base")

    for i = 1, 4 do
        local spike = Instance.new("Part")
        spike.Name = "BigSpike" .. i
        spike.Size = Vector3.new(0.18, 0.9, 0.18)
        spike.Material = Enum.Material.Metal
        spike.Color = gold
        spike.Anchored = true
        spike.CanCollide = false
        spike.CanQuery = false
        spike.CanTouch = false
        spike.Parent = model
        spike:SetAttribute("Type", "Spike")
        spike:SetAttribute("Angle", (i - 1) / 4 * math.pi * 2)
        spike:SetAttribute("Height", 0.9)
    end

    for i = 1, 8 do
        local spike = Instance.new("Part")
        spike.Name = "SmallSpike" .. i
        spike.Size = Vector3.new(0.12, 0.55, 0.12)
        spike.Material = Enum.Material.Metal
        spike.Color = gold
        spike.Anchored = true
        spike.CanCollide = false
        spike.CanQuery = false
        spike.CanTouch = false
        spike.Parent = model
        spike:SetAttribute("Type", "Spike")
        spike:SetAttribute("Angle", (i - 1) / 8 * math.pi * 2)
        spike:SetAttribute("Height", 0.55)
    end

    for i = 1, 12 do
        local ball = Instance.new("Part")
        ball.Name = "Ball" .. i
        ball.Shape = Enum.PartType.Ball
        ball.Size = Vector3.new(0.18, 0.18, 0.18)
        ball.Material = Enum.Material.Neon
        ball.Color = gold
        ball.Anchored = true
        ball.CanCollide = false
        ball.CanQuery = false
        ball.CanTouch = false
        ball.Parent = model
        ball:SetAttribute("Type", "Ball")
        ball:SetAttribute("Angle", (i - 1) / 12 * math.pi * 2)
    end

    return model
end

local function applyCrown()
    if crownConn then crownConn:Disconnect() crownConn = nil end
    if crownModel then pcall(function() crownModel:Destroy() end) crownModel = nil end

    if not crownEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    crownModel = buildCrownModel()
    crownModel.Parent = workspace

    crownConn = RunService.Heartbeat:Connect(function()
        if not crownEnabled or not crownModel or not crownModel.Parent then return end
        local c = LocalPlayer.Character
        if not c then return end
        local h = c:FindFirstChild("Head")
        if not h then return end

        local headCF = h.CFrame

        for _, p in ipairs(crownModel:GetChildren()) do
            if p:IsA("BasePart") then
                local t = p:GetAttribute("Type")
                if t == "Base" then
                    p.CFrame = headCF * CFrame.new(0, 1.4, 0) * CFrame.Angles(0, 0, math.rad(90))
                elseif t == "Spike" then
                    local ang = p:GetAttribute("Angle") or 0
                    local hh = p:GetAttribute("Height") or 0.9
                    local radius = 0.55
                    p.CFrame = headCF * CFrame.new(
                        math.sin(ang) * radius,
                        1.4 + hh / 2,
                        math.cos(ang) * radius
                    ) * CFrame.Angles(math.rad(15), ang, 0)
                elseif t == "Ball" then
                    local ang = p:GetAttribute("Angle") or 0
                    local radius = 0.75
                    p.CFrame = headCF * CFrame.new(
                        math.sin(ang) * radius,
                        1.4,
                        math.cos(ang) * radius
                    )
                end
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if crownEnabled then task.wait(0.3); applyCrown() end
end)

ItemTab:Toggle({
    Title = "👑 王冠",
    Desc = "头顶戴一顶真皇冠（本地视觉）",
    Value = false,
    Callback = function(state)
        crownEnabled = state
        applyCrown()
        WindUI:Notify({ Title = "👑 王冠", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "crown" })
    end,
})

-- 🔥 燃烧特效
local burnEnabled = false
local burnAttach = nil

local function applyBurn()
    if burnAttach then pcall(function() burnAttach:Destroy() end) burnAttach = nil end
    if not burnEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    burnAttach = Instance.new("Attachment")
    burnAttach.Position = Vector3.new(0, -1, 0)
    burnAttach.Parent = hrp

    local pe = Instance.new("ParticleEmitter")
    pe.Texture = "rbxasset://textures/particles/fire_main.dds"
    pe.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 240, 120)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 20)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(60, 10, 0)),
    })
    pe.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 1.5),
        NumberSequenceKeypoint.new(1.0, 0.0),
    })
    pe.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.3),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    pe.Lifetime = NumberRange.new(0.6, 1.2)
    pe.Rate = 80
    pe.Speed = NumberRange.new(2, 5)
    pe.SpreadAngle = Vector2.new(30, 30)
    pe.LightEmission = 1
    pe.Parent = burnAttach
end

LocalPlayer.CharacterAdded:Connect(function()
    if burnEnabled then task.wait(0.3); applyBurn() end
end)

ItemTab:Toggle({
    Title = "🔥 燃烧特效",
    Desc = "自己身上持续冒火焰（本地视觉）",
    Value = false,
    Callback = function(state)
        burnEnabled = state
        applyBurn()
        WindUI:Notify({ Title = "🔥 燃烧特效", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "flame" })
    end,
})

-- ❄️ 冰霜特效
local frostEnabled = false
local frostAttach = nil

local function applyFrost()
    if frostAttach then pcall(function() frostAttach:Destroy() end) frostAttach = nil end
    if not frostEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    frostAttach = Instance.new("Attachment")
    frostAttach.Position = Vector3.new(0, 0, 0)
    frostAttach.Parent = hrp

    local pe = Instance.new("ParticleEmitter")
    pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    pe.Color = ColorSequence.new(Color3.fromRGB(180, 230, 255), Color3.fromRGB(90, 150, 255))
    pe.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 1.2),
        NumberSequenceKeypoint.new(1.0, 0.0),
    })
    pe.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.2),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    pe.Lifetime = NumberRange.new(0.8, 1.5)
    pe.Rate = 60
    pe.Speed = NumberRange.new(3, 8)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.LightEmission = 0.8
    pe.Parent = frostAttach
end

LocalPlayer.CharacterAdded:Connect(function()
    if frostEnabled then task.wait(0.3); applyFrost() end
end)

ItemTab:Toggle({
    Title = "❄️ 冰霜特效",
    Desc = "自己身上持续冒冰霜（本地视觉）",
    Value = false,
    Callback = function(state)
        frostEnabled = state
        applyFrost()
        WindUI:Notify({ Title = "❄️ 冰霜特效", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "snowflake" })
    end,
})

-- ⚡ 电击特效
local sparkEnabled = false
local sparkAttach = nil

local function applySpark()
    if sparkAttach then pcall(function() sparkAttach:Destroy() end) sparkAttach = nil end
    if not sparkEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    sparkAttach = Instance.new("Attachment")
    sparkAttach.Position = Vector3.new(0, 0, 0)
    sparkAttach.Parent = hrp

    local pe = Instance.new("ParticleEmitter")
    pe.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    pe.Color = ColorSequence.new(Color3.fromRGB(255, 255, 100), Color3.fromRGB(100, 200, 255))
    pe.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.8),
        NumberSequenceKeypoint.new(1.0, 0.0),
    })
    pe.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.1),
        NumberSequenceKeypoint.new(1.0, 1.0),
    })
    pe.Lifetime = NumberRange.new(0.2, 0.5)
    pe.Rate = 120
    pe.Speed = NumberRange.new(15, 25)
    pe.SpreadAngle = Vector2.new(180, 180)
    pe.LightEmission = 1
    pe.Parent = sparkAttach
end

LocalPlayer.CharacterAdded:Connect(function()
    if sparkEnabled then task.wait(0.3); applySpark() end
end)

ItemTab:Toggle({
    Title = "⚡ 电击特效",
    Desc = "自己身上持续冒电火花（本地视觉）",
    Value = false,
    Callback = function(state)
        sparkEnabled = state
        applySpark()
        WindUI:Notify({ Title = "⚡ 电击特效", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "zap" })
    end,
})

-- 🌟 神之印记
local markEnabled = false
local markPart = nil
local markConn = nil

local function applyMark()
    if markConn then markConn:Disconnect() markConn = nil end
    if markPart then pcall(function() markPart:Destroy() end) markPart = nil end
    if not markEnabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    markPart = Instance.new("Part")
    markPart.Shape = Enum.PartType.Cylinder
    markPart.Size = Vector3.new(0.1, 6, 6)
    markPart.Anchored = true
    markPart.CanCollide = false
    markPart.CanQuery = false
    markPart.CanTouch = false
    markPart.Material = Enum.Material.Neon
    markPart.Color = Color3.fromRGB(0, 200, 255)
    markPart.Transparency = 0.4
    markPart.Parent = workspace

    markConn = RunService.Heartbeat:Connect(function()
        if not markEnabled or not markPart or not markPart.Parent then return end
        local c = LocalPlayer.Character
        if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart")
        if not r then return end
        markPart.CFrame = CFrame.new(r.Position - Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    if markEnabled then task.wait(0.3); applyMark() end
end)

ItemTab:Toggle({
    Title = "🌟 神之印记",
    Desc = "脚下有一个发光光环（本地视觉）",
    Value = false,
    Callback = function(state)
        markEnabled = state
        applyMark()
        WindUI:Notify({ Title = "🌟 神之印记", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "circle" })
    end,
})

-- 📸 拍照模式
local cameraModeEnabled = false
local cameraConn = nil
local savedCameraType = nil

local function applyCameraMode()
    if cameraConn then cameraConn:Disconnect() cameraConn = nil end
    if not cameraModeEnabled then
        if savedCameraType then
            pcall(function() workspace.CurrentCamera.CameraType = savedCameraType end)
        end
        return
    end
    savedCameraType = workspace.CurrentCamera.CameraType
    cameraConn = RunService.Heartbeat:Connect(function()
        pcall(function() workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable end)
    end)
end

ItemTab:Toggle({
    Title = "📸 拍照模式",
    Desc = "把相机设为自由模式（相机不再跟随角色）",
    Value = false,
    Callback = function(state)
        cameraModeEnabled = state
        applyCameraMode()
        WindUI:Notify({ Title = "📸 拍照模式", Content = state and "已开启（相机自由）" or "已关闭", Duration = 2, Icon = "camera" })
    end,
})

-- 🔍 视野放大
local fovEnabled = false
local fovValue = 120
local fovConn = nil

local function applyFov()
    if fovConn then fovConn:Disconnect() fovConn = nil end
    if not fovEnabled then return end
    fovConn = RunService.Heartbeat:Connect(function()
        pcall(function() workspace.CurrentCamera.FieldOfView = fovValue end)
    end)
end

ItemTab:Toggle({
    Title = "🔍 视野放大",
    Desc = "把相机 FOV 拉到指定值（默认 120）",
    Value = false,
    Callback = function(state)
        fovEnabled = state
        applyFov()
        WindUI:Notify({ Title = "🔍 视野放大", Content = state and "已开启" or "已关闭", Duration = 2, Icon = "eye" })
    end,
})

ItemTab:Input({
    Title = "FOV 数值",
    Desc = "推荐 70 - 120，默认 120",
    Value = "120",
    Placeholder = "120",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 30 and num <= 120 then
            fovValue = num
            if fovEnabled then
                pcall(function() workspace.CurrentCamera.FieldOfView = fovValue end)
            end
        else
            WindUI:Notify({ Title = "数值错误", Content = "请输入 30 - 120 之间的数字", Duration = 3, Icon = "alert-circle" })
        end
    end,
})

-- 🌫️ 烟雾弹
local smokeManager = makeToolManager(
    "烟雾弹",
    function() return buildGlowTool("烟雾弹", Color3.fromRGB(180, 180, 180), "点击在鼠标位置生成一大团烟雾") end,
    function()
        local mouse = LocalPlayer:GetMouse()
        if not mouse or not mouse.Hit then return end
        local pos = mouse.Hit.Position

        local anchor = Instance.new("Part")
        anchor.Size = Vector3.new(0.1, 0.1, 0.1)
        anchor.Position = pos
        anchor.Anchored = true
        anchor.CanCollide = false
        anchor.Transparency = 1
        anchor.CanQuery = false
        anchor.CanTouch = false
        anchor.Parent = workspace

        local attach = Instance.new("Attachment")
        attach.Parent = anchor

        local pe = Instance.new("ParticleEmitter")
        pe.Texture = "rbxasset://textures/particles/smoke_main.dds"
        pe.Color = ColorSequence.new(Color3.fromRGB(180, 180, 180), Color3.fromRGB(90, 90, 90))
        pe.Size = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 3),
            NumberSequenceKeypoint.new(0.5, 8),
            NumberSequenceKeypoint.new(1.0, 14),
        })
        pe.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0.0, 0.3),
            NumberSequenceKeypoint.new(1.0, 1.0),
        })
        pe.Lifetime = NumberRange.new(2, 3)
        pe.Speed = NumberRange.new(2, 6)
        pe.SpreadAngle = Vector2.new(180, 180)
        pe.Rate = 0
        pe.LightEmission = 0
        pe.Parent = attach
        pe:Emit(150)

        task.delay(4, function()
            pcall(function() anchor:Destroy() end)
        end)
    end
)

ItemTab:Toggle({
    Title = "🌫️ 烟雾弹",
    Desc = "背包生成「烟雾弹」，点击在鼠标位置生成一大团烟雾",
    Value = false,
    Callback = function(state)
        smokeManager.set(state)
        WindUI:Notify({ Title = "🌫️ 烟雾弹", Content = state and "已发放" or "已移除", Duration = 2, Icon = "cloud" })
    end,
})

ItemTab:Button({
    Title = "🧹 清空背包",
    Desc = "删除背包里所有工具（不会影响游戏内已装备的）",
    Callback = function()
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if not bp then return end
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                pcall(function() item:Destroy() end)
            end
        end
        WindUI:Notify({ Title = "🧹 清空背包", Content = "已清空", Duration = 2, Icon = "trash" })
    end,
})

ItemTab:Button({
    Title = "📦 复制背包所有工具",
    Desc = "把背包里每个工具再复制一份（可能被游戏检测）",
    Callback = function()
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if not bp then return end
        local tools = {}
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then table.insert(tools, item) end
        end
        for _, t in ipairs(tools) do
            pcall(function()
                local c = t:Clone()
                c.Parent = bp
            end)
        end
        WindUI:Notify({ Title = "📦 复制工具", Content = "已复制 " .. #tools .. " 个工具", Duration = 2, Icon = "copy" })
    end,
})

ItemTab:Divider()

ItemTab:Paragraph({
    Title = "⚠️ 道具类功能可能被部分游戏检测，请谨慎使用",
    Desc = "",
})

--============================================================
-- 通知系统
--============================================================
local notifyGui = Instance.new("ScreenGui")
notifyGui.Name = "ShenNotifyGui"
notifyGui.ResetOnSpawn = false
notifyGui.IgnoreGuiInset = true
notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
notifyGui.DisplayOrder = 999
notifyGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local container = Instance.new("Frame")
container.Name = "Container"
container.AnchorPoint = Vector2.new(1, 1)
container.Position = UDim2.new(1, -12, 1, -12)
container.Size = UDim2.fromOffset(200, 400)
container.BackgroundTransparency = 1
container.Parent = notifyGui

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.Padding = UDim.new(0, 6)
layout.Parent = container

local NOTIFY_ICON = "rbxassetid://10709798840"

local function createNotify(title, content, duration, imageId, avatarUserId)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.fromOffset(180, 62)
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = false

    local card = Instance.new("Frame")
    card.Size = UDim2.fromScale(1, 1)
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    card.BackgroundTransparency = 0.15
    card.BorderSizePixel = 0
    card.ClipsDescendants = true
    card.Parent = holder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 150, 255)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.2
    stroke.Parent = card

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 2, 1, 0)
    bar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    bar.BorderSizePixel = 0
    bar.Parent = card
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(0, 6)
    barCorner.Parent = bar

    local textX = 10
    if avatarUserId then
        local avatar = Instance.new("ImageLabel")
        avatar.Size = UDim2.fromOffset(34, 34)
        avatar.Position = UDim2.new(0, 8, 0.5, -17)
        avatar.BackgroundTransparency = 1
        avatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(avatarUserId) .. "&w=150&h=150"
        avatar.Parent = card
        textX = 48
        local avatarCorner = Instance.new("UICorner")
        avatarCorner.CornerRadius = UDim.new(0, 5)
        avatarCorner.Parent = avatar
    elseif imageId then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.fromOffset(22, 22)
        img.Position = UDim2.new(0, 8, 0.5, -11)
        img.BackgroundTransparency = 1
        img.Image = imageId
        img.Parent = card
        textX = 34
    end

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -textX - 8, 0, 15)
    titleLbl.Position = UDim2.new(0, textX, 0, 6)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextColor3 = Color3.fromRGB(100, 200, 255)
    titleLbl.RichText = true
    titleLbl.Text = title
    titleLbl.Parent = card

    local contentLbl = Instance.new("TextLabel")
    contentLbl.Size = UDim2.new(1, -textX - 8, 1, -24)
    contentLbl.Position = UDim2.new(0, textX, 0, 22)
    contentLbl.BackgroundTransparency = 1
    contentLbl.Font = Enum.Font.Gotham
    contentLbl.TextSize = 10
    contentLbl.TextXAlignment = Enum.TextXAlignment.Left
    contentLbl.TextYAlignment = Enum.TextYAlignment.Top
    contentLbl.TextWrapped = true
    contentLbl.TextColor3 = Color3.fromRGB(220, 220, 220)
    contentLbl.Text = content
    contentLbl.Parent = card

    holder.Parent = container
    holder.Position = UDim2.new(1, 60, 0, 0)
    holder.AnchorPoint = Vector2.new(1, 0)
    card.BackgroundTransparency = 1
    for _, d in ipairs(card:GetDescendants()) do
        if d:IsA("TextLabel") then d.TextTransparency = 1
        elseif d:IsA("ImageLabel") then d.ImageTransparency = 1
        elseif d:IsA("UIStroke") then d.Transparency = 1
        elseif d:IsA("Frame") and d ~= card then d.BackgroundTransparency = 1 end
    end

    TweenService:Create(holder, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, 0, 0, 0) }):Play()
    TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0.15 }):Play()

    for _, d in ipairs(card:GetDescendants()) do
        if d:IsA("TextLabel") then
            TweenService:Create(d, TweenInfo.new(0.35), { TextTransparency = 0 }):Play()
        elseif d:IsA("ImageLabel") then
            TweenService:Create(d, TweenInfo.new(0.35), { ImageTransparency = 0 }):Play()
        elseif d:IsA("UIStroke") then
            TweenService:Create(d, TweenInfo.new(0.35), { Transparency = 0.2 }):Play()
        elseif d:IsA("Frame") and d ~= card then
            TweenService:Create(d, TweenInfo.new(0.35), { BackgroundTransparency = 0 }):Play()
        end
    end

    task.delay(duration, function()
        local slideOut = TweenService:Create(holder, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(1, 60, 0, 0) })
        slideOut:Play()
        TweenService:Create(card, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
        for _, d in ipairs(card:GetDescendants()) do
            if d:IsA("TextLabel") then
                TweenService:Create(d, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
            elseif d:IsA("ImageLabel") then
                TweenService:Create(d, TweenInfo.new(0.3), { ImageTransparency = 1 }):Play()
            elseif d:IsA("UIStroke") then
                TweenService:Create(d, TweenInfo.new(0.3), { Transparency = 1 }):Play()
            elseif d:IsA("Frame") and d ~= card then
                TweenService:Create(d, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
            end
        end
        slideOut.Completed:Connect(function() holder:Destroy() end)
    end)
end

Players.PlayerAdded:Connect(function(player)
    if not getgenv().PlayerNotifyEnabled then return end
    RunService.Heartbeat:Wait()
    if not getgenv().PlayerNotifyEnabled then return end
    local count = #Players:GetPlayers()
    createNotify("游戏通知", "当前服务器玩家人数：" .. count .. "\n" .. player.Name .. " 加入了游戏", 5, nil, player.UserId)
end)

Players.PlayerRemoving:Connect(function(player)
    if not getgenv().PlayerNotifyEnabled then return end
    local count = #Players:GetPlayers() - 1
    if count < 0 then count = 0 end
    createNotify("游戏通知", "当前服务器玩家人数：" .. count .. "\n" .. player.Name .. " 离开了游戏", 5, nil, player.UserId)
end)

task.spawn(function()
    repeat task.wait() until Window and Window.UIElements
    task.wait(0.8)
    local loadTime = tick() - (getgenv().ShenScriptStartTime or tick())
    local loadTimeText = string.format("%.2f 秒", loadTime)
    local notifications = {
        { Title = "验证成功", Content = "欢迎使用脚本", Duration = 3, Icon = nil },
        { Title = "神脚本", Content = "欢迎使用神脚本", Duration = 3, Icon = NOTIFY_ICON },
        { Title = "脚本功能多多", Content = "感谢您的使用", Duration = 3, Icon = nil },
        { Title = "神脚本", Content = "脚本加载耗时：" .. loadTimeText, Duration = 4, Icon = NOTIFY_ICON },
        { Title = "此脚本是永久免费的", Content = "请勿倒卖", Duration = 4, Icon = nil },
    }
    for _, n in ipairs(notifications) do
        createNotify(n.Title, n.Content, n.Duration, n.Icon)
        task.wait(0.65)
    end
end)
