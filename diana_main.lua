-- =========================================================
-- 神 Hub | 白色简约风 UI
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =========================================================
-- 🖼️ 免责声明弹窗（在脚本加载前强制阻断）
-- =========================================================
local allowedToLoad = false
local popupGui = Instance.new("ScreenGui")
popupGui.Name = "AutoImagePopupUI"
popupGui.ResetOnSpawn = false
popupGui.IgnoreGuiInset = true
popupGui.DisplayOrder = 999999 
popupGui.Parent = playerGui

local bgBtn = Instance.new("TextButton")
bgBtn.Size = UDim2.new(1, 0, 1, 0)
bgBtn.BackgroundColor3 = Color3.new(0, 0, 0)
bgBtn.BackgroundTransparency = 0.3
bgBtn.Text = ""
bgBtn.AutoButtonColor = false
bgBtn.ZIndex = 1
bgBtn.Parent = popupGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 350)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.ZIndex = 2
frame.Parent = bgBtn

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 140, 255)
stroke.Thickness = 2
stroke.Parent = frame

local img = Instance.new("ImageLabel")
img.Size = UDim2.new(1, -10, 1, -80) -- 留出下面文字的空间
img.Position = UDim2.new(0.5, 0, 0, 5)
img.AnchorPoint = Vector2.new(0.5, 0)
img.BackgroundTransparency = 1
img.Image = "rbxassetid://120477606610755" -- 你的图片ID
img.ScaleType = Enum.ScaleType.Fit
img.ZIndex = 3
img.Parent = frame

local imgCorner = Instance.new("UICorner")
imgCorner.CornerRadius = UDim.new(0, 8)
imgCorner.Parent = img

-- 警告文字
local warnText = Instance.new("TextLabel")
warnText.Size = UDim2.new(1, -20, 0, 30)
warnText.Position = UDim2.new(0.5, 0, 1, -70)
warnText.AnchorPoint = Vector2.new(0.5, 0)
warnText.BackgroundTransparency = 1
warnText.Text = "如果用此脚本有任何封号问题，是否自己承担？"
warnText.TextColor3 = Color3.fromRGB(220, 80, 80)
warnText.Font = Enum.Font.GothamBold
warnText.TextSize = 12
warnText.TextWrapped = true
warnText.ZIndex = 4
warnText.Parent = frame

-- 按钮容器
local btnContainer = Instance.new("Frame")
btnContainer.Size = UDim2.new(1, -40, 0, 30)
btnContainer.Position = UDim2.new(0.5, 0, 1, -35)
btnContainer.AnchorPoint = Vector2.new(0.5, 0)
btnContainer.BackgroundTransparency = 1
btnContainer.ZIndex = 4
btnContainer.Parent = frame

local btnLayout = Instance.new("UIListLayout")
btnLayout.FillDirection = Enum.FillDirection.Horizontal
btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
btnLayout.Padding = UDim.new(0, 15)
btnLayout.Parent = btnContainer

local btnYes = Instance.new("TextButton")
btnYes.Size = UDim2.new(0, 100, 1, 0)
btnYes.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
btnYes.Text = "1 是"
btnYes.TextColor3 = Color3.new(1,1,1)
btnYes.Font = Enum.Font.GothamBold
btnYes.TextSize = 13
btnYes.AutoButtonColor = false
btnYes.ZIndex = 5
btnYes.Parent = btnContainer
local yesCorner = Instance.new("UICorner")
yesCorner.CornerRadius = UDim.new(0, 6)
yesCorner.Parent = btnYes

local btnNo = Instance.new("TextButton")
btnNo.Size = UDim2.new(0, 100, 1, 0)
btnNo.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
btnNo.Text = "2 否"
btnNo.TextColor3 = Color3.fromRGB(220, 80, 80)
btnNo.Font = Enum.Font.GothamBold
btnNo.TextSize = 13
btnNo.AutoButtonColor = false
btnNo.ZIndex = 5
btnNo.Parent = btnContainer
local noCorner = Instance.new("UICorner")
noCorner.CornerRadius = UDim.new(0, 6)
noCorner.Parent = btnNo

-- 交互逻辑
local loadTrigger = Instance.new("BindableEvent")

btnYes.MouseButton1Click:Connect(function()
    popupGui:Destroy() -- 关闭弹窗
    loadTrigger:Fire() -- 触发加载信号
end)

btnNo.MouseButton1Click:Connect(function()
    popupGui:Destroy() -- 直接关闭，后面代码全都不会执行
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "已取消",
        Text = "脚本已停止加载",
        Duration = 3
    })
end)

-- 阻塞等待：如果没点“是”，代码就会永远卡在这里不往下走
loadTrigger.Event:Wait()

-- =========================================================
-- 以下为原脚本核心逻辑（只有点击了“是”才会执行到这里）
-- =========================================================

local function safe(fn, ...)
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local HAS_DRAWING = (typeof(Drawing) == "table") and (typeof(Drawing.new) == "function")

local PRIMARY, ACCENT = Color3.fromRGB(0, 140, 255), Color3.fromRGB(70, 180, 255)
local WHITE_BG, CARD_BG, SOFT_BG = Color3.fromRGB(255,255,255), Color3.fromRGB(255,255,255), Color3.fromRGB(238,242,248)
local TEXT_DARK, TEXT_DIM, WARN_RED = Color3.fromRGB(40,50,70), Color3.fromRGB(140,150,170), Color3.fromRGB(220,80,80)

local THEMES = {
    {name="蓝色", color=Color3.fromRGB(0,140,255)},
    {name="紫色", color=Color3.fromRGB(160,100,255)},
    {name="绿色", color=Color3.fromRGB(60,200,120)},
    {name="橙色", color=Color3.fromRGB(255,150,60)},
    {name="粉色", color=Color3.fromRGB(255,100,180)},
    {name="红色", color=Color3.fromRGB(230,70,70)},
    {name="青色", color=Color3.fromRGB(70,220,220)},
    {name="金色", color=Color3.fromRGB(240,190,60)},
}
local themeIndex = 1
local themeTargets = {}
local function registerThemeTarget(obj, type)
    table.insert(themeTargets, {obj=obj, type=type})
end
local function applyTheme(color)
    safe(function()
        PRIMARY = color
        ACCENT = color:Lerp(Color3.fromRGB(255,255,255), 0.3)
        for _, t in ipairs(themeTargets) do
            if t.obj and t.obj.Parent then
                if t.type == "stroke" then t.obj.Color = color
                elseif t.type == "text" then t.obj.TextColor3 = color
                elseif t.type == "fill" then t.obj.BackgroundColor3 = color end
            end
        end
    end)
end

local function new(className, props, children)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do pcall(function() obj[k] = v end) end
    for _, c in ipairs(children or {}) do pcall(function() c.Parent = obj end) end
    return obj
end
local function corner(r) return new("UICorner", {CornerRadius=UDim.new(0,r)}) end
local strokeRegistry = {}
local function stroke(color, thickness, transparency)
    local s = new("UIStroke", {Color=color, Thickness=thickness, Transparency=transparency or 0, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    table.insert(strokeRegistry, s)
    return s
end
local function applyStrokeColor(color)
    safe(function()
        for _, s in ipairs(strokeRegistry) do if s and s.Parent then s.Color = color end end
    end)
end
local function padding(px)
    return new("UIPadding", {PaddingTop=UDim.new(0,px), PaddingBottom=UDim.new(0,px), PaddingLeft=UDim.new(0,px), PaddingRight=UDim.new(0,px)})
end

local gui = new("ScreenGui", {Name="N9Hub", ResetOnSpawn=false, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, IgnoreGuiInset=true, Parent=playerGui})

local window = new("Frame", {
    Name="MainWindow", Size=UDim2.fromOffset(460,340), Position=UDim2.new(0.5,-230,0.5,-170),
    BackgroundColor3=WHITE_BG, BorderSizePixel=0, Visible=false, Active=true, Draggable=true, ClipsDescendants=true, Parent=gui,
}, {corner(14), stroke(PRIMARY, 1.6, 0.35)})

local banner = new("Frame", {Name="Banner", Size=UDim2.new(1,-20,0,30), Position=UDim2.new(0,10,0,6), BackgroundColor3=WHITE_BG, BorderSizePixel=0, ZIndex=5, Parent=window}, {corner(6), stroke(PRIMARY, 1.2, 0.4)})
local bannerTitle = new("TextLabel", {Size=UDim2.new(0.22,0,1,0), Position=UDim2.fromOffset(10,0), BackgroundTransparency=1, Text="神脚本 V2.0", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=6, Parent=banner})
registerThemeTarget(bannerTitle, "text")
local clockLabel = new("TextLabel", {Size=UDim2.new(0.36,0,1,0), Position=UDim2.new(0.18,0,0,0), BackgroundTransparency=1, Text="--", TextColor3=TEXT_DARK, Font=Enum.Font.GothamMedium, TextSize=11, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6, Parent=banner})
local warnLabel = new("TextLabel", {Size=UDim2.new(0.28,0,1,0), Position=UDim2.new(0.54,0,0,0), BackgroundTransparency=1, Text="仅供娱乐，后果自负", TextColor3=WARN_RED, Font=Enum.Font.GothamMedium, TextSize=10, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=6, Parent=banner})
local adminBtn = new("TextButton", {Size=UDim2.fromOffset(80,20), Position=UDim2.new(1,-88,0.5,-10), BackgroundColor3=PRIMARY, Text="管理员面板", TextColor3=WHITE_BG, Font=Enum.Font.GothamBold, TextSize=11, AutoButtonColor=false, ZIndex=6, Parent=banner}, {corner(4)})
registerThemeTarget(adminBtn, "fill")
adminBtn.MouseButton1Click:Connect(function() safe(function() print("[神脚本] 管理员面板暂未开放") end) end)

task.spawn(function()
    while banner.Parent do
        safe(function()
            local t = os.date("*t")
            clockLabel.Text = string.format("%04d年%02d月%02d日 %02d:%02d:%02d", t.year, t.month, t.day, t.hour, t.min, t.sec)
        end)
        task.wait(1)
    end
end)

local searchRegistry = {}
local function registerSearchable(f, k) table.insert(searchRegistry, {frame=f, keyword=k:lower()}) end

local topBar = new("Frame", {Size=UDim2.new(1,0,0,36), Position=UDim2.new(0,0,0,40), BackgroundColor3=WHITE_BG, BorderSizePixel=0, ZIndex=2, Parent=window}, {corner(14)})
new("Frame", {Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,1,-12), BackgroundColor3=WHITE_BG, BorderSizePixel=0, ZIndex=2, Parent=topBar})
local title = new("TextLabel", {Size=UDim2.fromOffset(60,36), Position=UDim2.fromOffset(16,0), BackgroundTransparency=1, Text="神 HUB", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=15, TextXAlignment=Enum.TextXAlignment.Left, ZIndex=3, Parent=topBar})
registerThemeTarget(title, "text")
local titleAccent = new("Frame", {Size=UDim2.new(0,50,0,2), Position=UDim2.new(0,16,1,-4), BackgroundColor3=PRIMARY, BorderSizePixel=0, ZIndex=3, Parent=topBar}, {corner(1)})
registerThemeTarget(titleAccent, "fill")
local closeBtn = new("TextButton", {Size=UDim2.fromOffset(26,26), Position=UDim2.new(1,-34,0.5,-13), BackgroundColor3=SOFT_BG, Text="X", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=13, AutoButtonColor=false, ZIndex=3, Parent=topBar}, {corner(6), stroke(PRIMARY, 1, 0.6)})
registerThemeTarget(closeBtn, "text")

local playerCard = new("TextButton", {
    Name="PlayerCard",
    Size=UDim2.new(1, -125, 0, 36),
    Position=UDim2.new(0, 80, 0, 0),
    BackgroundTransparency=1,
    Text="", AutoButtonColor=false, ZIndex=10, Parent=topBar
})
local avatar = new("ImageLabel", {
    Name="Avatar", Size=UDim2.fromOffset(24,24), Position=UDim2.new(0,0,0.5,-12), 
    BackgroundColor3=SOFT_BG, Image="", ZIndex=11, Parent=playerCard
}, {corner(999)})
local pName = new("TextLabel", {
    Name="PlayerName", Size=UDim2.new(1,-36,0,14), Position=UDim2.fromOffset(30,4),
    BackgroundTransparency=1, Text=player.DisplayName or player.Name, TextColor3=TEXT_DARK, 
    Font=Enum.Font.GothamBold, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=11, Parent=playerCard
})
local pTag = new("TextLabel", {
    Name="PlayerTag", Size=UDim2.new(1,-36,0,12), Position=UDim2.fromOffset(30,18),
    BackgroundTransparency=1, Text="@"..player.Name, TextColor3=TEXT_DIM, Font=Enum.Font.GothamMedium, 
    TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, TextTruncate=Enum.TextTruncate.AtEnd, ZIndex=11, Parent=playerCard
})
task.spawn(function()
    safe(function()
        avatar.Image = string.format("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png", player.UserId)
    end)
end)
playerCard.MouseButton1Click:Connect(function()
    safe(function()
        themeIndex = themeIndex + 1
        if themeIndex > #THEMES then themeIndex = 1 end
        local t = THEMES[themeIndex]
        applyTheme(t.color)
        pTag.Text = "@"..player.Name.." · "..t.name
        task.delay(1.5, function() safe(function() pTag.Text = "@"..player.Name end) end)
    end)
end)

local sidebar = new("ScrollingFrame", {
    Size=UDim2.new(0,110,1,-76), Position=UDim2.new(0,0,0,76),
    BackgroundColor3=WHITE_BG, BorderSizePixel=0, ZIndex=2, ScrollBarThickness=4, ScrollBarImageColor3=PRIMARY,
    ScrollingDirection=Enum.ScrollingDirection.Y, CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=window,
}, {padding(8), new("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder})})

local content = new("ScrollingFrame", {
    Size=UDim2.new(1,-110,1,-76), Position=UDim2.new(0,110,0,76),
    BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=PRIMARY,
    CanvasSize=UDim2.new(0,0,0,0), ZIndex=2, Parent=window,
}, {padding(12), new("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder})})
content.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    safe(function() content.CanvasSize = UDim2.new(0,0,0, content.UIListLayout.AbsoluteContentSize.Y + 24) end)
end)

local tabs, activeTab, tabOrder = {}, nil, 0
local function createTab(name, icon)
    tabOrder = tabOrder + 1
    local btn = new("TextButton", {
        Name="Tab_"..name, Size=UDim2.new(1,0,0,32), BackgroundColor3=CARD_BG, BackgroundTransparency=1,
        Text="  "..(icon and (icon.."  ") or "")..name, TextColor3=TEXT_DIM, Font=Enum.Font.GothamMedium, TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left, AutoButtonColor=false, LayoutOrder=tabOrder, ZIndex=3, Parent=sidebar,
    }, {corner(6), padding(6), new("Frame", {Name="Indicator", Size=UDim2.new(0,3,0,0), Position=UDim2.new(0,-6,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=PRIMARY, BorderSizePixel=0, ZIndex=3}, {corner(2)})})
    local page = new("Frame", {Name="Page_"..name, Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundTransparency=1, Visible=false, LayoutOrder=tabOrder, Parent=content}, {new("UIListLayout", {Padding=UDim.new(0,10), SortOrder=Enum.SortOrder.LayoutOrder})})
    tabs[name] = {button=btn, page=page}
    btn.MouseEnter:Connect(function() safe(function() if activeTab ~= name then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=0.4}):Play() end end) end)
    btn.MouseLeave:Connect(function() safe(function() if activeTab ~= name then TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency=1}):Play() end end) end)
    btn.MouseButton1Click:Connect(function()
        safe(function()
            for n, t in pairs(tabs) do
                if n == name then
                    t.page.Visible = true
                    t.button.BackgroundTransparency = 0.2
                    t.button.TextColor3 = PRIMARY
                    TweenService:Create(t.button.Indicator, TweenInfo.new(0.2), {Size=UDim2.new(0,3,0,18)}):Play()
                    activeTab = name
                else
                    t.page.Visible = false
                    t.button.BackgroundTransparency = 1
                    t.button.TextColor3 = TEXT_DIM
                    TweenService:Create(t.button.Indicator, TweenInfo.new(0.2), {Size=UDim2.new(0,3,0,0)}):Play()
                end
            end
        end)
    end)
    return page
end

local controlOrder = 0
local function nextOrder() controlOrder = controlOrder + 1 return controlOrder end

local function makeToggle(parent, opts)
    local row = new("Frame", {Size=UDim2.new(1,0,0,40), BackgroundColor3=CARD_BG, BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=parent}, {corner(8), stroke(PRIMARY, 1, 0.7), padding(10)})
    new("TextLabel", {Size=UDim2.new(1,-60,1,0), BackgroundTransparency=1, Text=opts.Title or "Toggle", TextColor3=TEXT_DARK, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
    local state = opts.Value or false
    local track = new("Frame", {Size=UDim2.fromOffset(40,20), Position=UDim2.new(1,-40,0.5,-10), BackgroundColor3=state and PRIMARY or SOFT_BG, BorderSizePixel=0, Parent=row}, {corner(10), stroke(PRIMARY, 1, state and 0 or 0.5)})
    local knob = new("Frame", {Size=UDim2.fromOffset(16,16), Position=state and UDim2.new(1,-18,0.5,-8) or UDim2.fromOffset(2,2), BackgroundColor3=state and WHITE_BG or TEXT_DIM, BorderSizePixel=0, Parent=track}, {corner(8)})
    local function set(v)
        safe(function()
            state = v
            TweenService:Create(track, TweenInfo.new(0.15), {BackgroundColor3=v and PRIMARY or SOFT_BG}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position=v and UDim2.new(1,-18,0.5,-8) or UDim2.fromOffset(2,2), BackgroundColor3=v and WHITE_BG or TEXT_DIM}):Play()
            if opts.Callback then local ok, err = pcall(opts.Callback, v) if not ok then warn("[神脚本] Toggle callback 出错:", err) end end
        end)
    end
    local click = new("TextButton", {Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", Parent=row})
    click.MouseButton1Click:Connect(function() set(not state) end)
    if opts.Value == true and opts.Callback then
        task.defer(function() safe(function() local ok, err = pcall(opts.Callback, true) if not ok then warn("[神脚本] Toggle 初始化 callback 出错:", err) end end) end)
    end
    return row
end

local function makeButton(parent, opts)
    local btn = new("TextButton", {Size=UDim2.new(1,0,0,36), BackgroundColor3=CARD_BG, Text=opts.Title or "Button", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=12, AutoButtonColor=false, LayoutOrder=nextOrder(), Parent=parent}, {corner(8), stroke(PRIMARY, 1.2, 0.4)})
    btn.MouseEnter:Connect(function() safe(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=PRIMARY, TextColor3=WHITE_BG}):Play() end) end)
    btn.MouseLeave:Connect(function() safe(function() TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=CARD_BG, TextColor3=PRIMARY}):Play() end) end)
    btn.MouseButton1Click:Connect(function()
        if opts.Callback then
            local ok, err = pcall(opts.Callback)
            if not ok then warn("[神脚本] Button callback 出错:", err) end
        end
    end)
    return btn
end

local function makeSlider(parent, opts)
    local min, max, value = opts.Min or 0, opts.Max or 100, opts.Default or 0
    local row = new("Frame", {Size=UDim2.new(1,0,0,52), BackgroundColor3=CARD_BG, BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=parent}, {corner(8), stroke(PRIMARY, 1, 0.7), padding(10)})
    new("TextLabel", {Size=UDim2.new(1,-50,0,16), BackgroundTransparency=1, Text=opts.Title or "Slider", TextColor3=TEXT_DARK, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
    local valueLabel = new("TextLabel", {Size=UDim2.fromOffset(50,16), Position=UDim2.new(1,-50,0,0), BackgroundTransparency=1, Text=tostring(value), TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right, Parent=row})
    local track = new("Frame", {Size=UDim2.new(1,0,0,6), Position=UDim2.new(0,0,1,-10), BackgroundColor3=SOFT_BG, BorderSizePixel=0, Parent=row}, {corner(3), stroke(PRIMARY, 1, 0.6)})
    local rel = (value - min) / math.max(max - min, 1)
    local fill = new("Frame", {Size=UDim2.new(rel,0,1,0), BackgroundColor3=PRIMARY, BorderSizePixel=0, Parent=track}, {corner(3)})
    local knob = new("Frame", {Size=UDim2.fromOffset(14,14), AnchorPoint=Vector2.new(0.5,0.5), Position=UDim2.new(rel,0,0.5,0), BackgroundColor3=WHITE_BG, BorderSizePixel=0, ZIndex=2, Parent=track}, {corner(7), stroke(PRIMARY, 2, 0)})
    local hit = new("TextButton", {Size=UDim2.new(1,0,0,24), Position=UDim2.new(0,0,1,-24), BackgroundTransparency=1, Text="", ZIndex=3, Parent=row})
    local dragging = false
    local function updateFromX(x)
        safe(function()
            local r = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local v = math.floor(min + (max - min) * r + 0.5)
            fill.Size = UDim2.new(r,0,1,0)
            knob.Position = UDim2.new(r,0,0.5,0)
            valueLabel.Text = tostring(v)
            if opts.Callback then local ok, err = pcall(opts.Callback, v) if not ok then warn("[神脚本] Slider callback 出错:", err) end end
        end)
    end
    hit.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    return row
end

local function makeInput(parent, opts)
    local row = new("Frame", {Size=UDim2.new(1,0,0,56), BackgroundColor3=CARD_BG, BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=parent}, {corner(8), stroke(PRIMARY, 1, 0.7), padding(10)})
    new("TextLabel", {Size=UDim2.new(1,-50,0,16), BackgroundTransparency=1, Text=opts.Title or "Input", TextColor3=TEXT_DARK, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
    if opts.Desc and opts.Desc ~= "" then
        new("TextLabel", {Size=UDim2.new(1,0,0,14), Position=UDim2.new(0,0,0,18), BackgroundTransparency=1, Text=opts.Desc, TextColor3=TEXT_DIM, Font=Enum.Font.GothamMedium, TextSize=10, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
    end
    local box = new("TextBox", {Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,1,-24), BackgroundColor3=SOFT_BG, Text=opts.Value or "", PlaceholderText=opts.Placeholder or "", TextColor3=PRIMARY, PlaceholderColor3=TEXT_DIM, Font=Enum.Font.GothamMedium, TextSize=12, ClearTextOnFocus=false, TextXAlignment=Enum.TextXAlignment.Center, Parent=row}, {corner(6), stroke(PRIMARY, 1, 0.6), padding(4)})
    box.FocusLost:Connect(function()
        safe(function()
            if opts.Callback then local ok, err = pcall(opts.Callback, box.Text) if not ok then warn("[神脚本] Input callback 出错:", err) end end
        end)
    end)
    return row
end

local function makeDropdown(parent, opts)
    local row = new("Frame", {Size=UDim2.new(1,0,0,40), BackgroundColor3=CARD_BG, BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=parent, ClipsDescendants=false}, {corner(8), stroke(PRIMARY, 1, 0.7), padding(10)})
    new("TextLabel", {Size=UDim2.new(0.5,0,1,0), BackgroundTransparency=1, Text=opts.Title or "Dropdown", TextColor3=TEXT_DARK, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=row})
    local current = opts.Value or "点击选择"
    local selectedLabel = new("TextLabel", {Size=UDim2.new(0.45,0,1,0), Position=UDim2.new(0.55,0,0,0), BackgroundTransparency=1, Text=current, TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right, TextTruncate=Enum.TextTruncate.AtEnd, Parent=row})
    local popup = new("Frame", {Size=UDim2.new(1,0,0,140), Position=UDim2.new(0,0,1,6), BackgroundColor3=WHITE_BG, BorderSizePixel=0, Visible=false, ClipsDescendants=true, ZIndex=200, Parent=row}, {corner(6), stroke(PRIMARY, 1.2, 0.4)})
    local list = new("ScrollingFrame", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=4, ScrollBarImageColor3=PRIMARY, CanvasSize=UDim2.new(0,0,0,0), ZIndex=201, Parent=popup}, {padding(4), new("UIListLayout", {Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder})})
    list.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() safe(function() list.CanvasSize = UDim2.new(0,0,0, list.UIListLayout.AbsoluteContentSize.Y + 8) end) end)
    local dropdown = {options = opts.Options or {}, callback = opts.Callback}
    local function rebuild()
        for _, c in ipairs(list:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, name in ipairs(dropdown.options) do
            local optBtn = new("TextButton", {Size=UDim2.new(1,0,0,24), BackgroundColor3=SOFT_BG, Text=name, TextColor3=TEXT_DARK, Font=Enum.Font.GothamMedium, TextSize=12, AutoButtonColor=false, ZIndex=202, Parent=list}, {corner(4)})
            optBtn.MouseEnter:Connect(function() safe(function() TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3=PRIMARY, TextColor3=WHITE_BG}):Play() end) end)
            optBtn.MouseLeave:Connect(function() safe(function() TweenService:Create(optBtn, TweenInfo.new(0.1), {BackgroundColor3=SOFT_BG, TextColor3=TEXT_DARK}):Play() end) end)
            optBtn.MouseButton1Click:Connect(function()
                safe(function()
                    selectedLabel.Text = name
                    popup.Visible = false
                    if dropdown.callback then local ok, err = pcall(dropdown.callback, name) if not ok then warn("[神脚本] Dropdown callback 出错:", err) end end
                end)
            end)
        end
    end
    local hit = new("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="", ZIndex=3, Parent=row})
    hit.MouseButton1Click:Connect(function() safe(function() popup.Visible = not popup.Visible end) end)
    rebuild()
    dropdown.SetValues = function(values) dropdown.options = values or {} selectedLabel.Text = "点击选择" rebuild() end
    dropdown.SetValue = function(v) selectedLabel.Text = tostring(v) end
    return dropdown
end-- ============ 悬浮球 ============
local openBtn = new("ImageButton", {
    Name="OpenButton", Size=UDim2.fromOffset(42,42), Position=UDim2.new(0,20,0.5,-21),
    BackgroundColor3=WHITE_BG, Image="rbxassetid://262531136", ImageColor3=Color3.fromRGB(255,255,255),
    ScaleType=Enum.ScaleType.Crop, AutoButtonColor=false, Visible=true, Parent=gui,
}, {corner(21)})
openBtn.MouseEnter:Connect(function() safe(function() TweenService:Create(openBtn, TweenInfo.new(0.15), {Size=UDim2.fromOffset(50,50)}):Play() end) end)
openBtn.MouseLeave:Connect(function() safe(function() TweenService:Create(openBtn, TweenInfo.new(0.15), {Size=UDim2.fromOffset(42,42)}):Play() end) end)
openBtn.MouseButton1Down:Connect(function() safe(function() TweenService:Create(openBtn, TweenInfo.new(0.06), {Size=UDim2.fromOffset(36,36)}):Play() end) end)
openBtn.MouseButton1Up:Connect(function() safe(function() TweenService:Create(openBtn, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(42,42)}):Play() end) end)
do
    local dragging, dragStart, startPos
    openBtn.InputBegan:Connect(function(input)
        safe(function()
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = openBtn.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
    end)
    UIS.InputChanged:Connect(function(input)
        safe(function()
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                openBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end)
end

local function setWindowVisible(v)
    safe(function()
        if v then
            window.Visible = true
            window.Size = UDim2.fromOffset(420, 300)
            TweenService:Create(window, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size=UDim2.fromOffset(460,340)}):Play()
        else
            local tween = TweenService:Create(window, TweenInfo.new(0.15), {Size=UDim2.fromOffset(420,300)})
            tween:Play()
            tween.Completed:Connect(function() window.Visible = false end)
        end
    end)
end
openBtn.MouseButton1Click:Connect(function() setWindowVisible(not window.Visible) end)
closeBtn.MouseButton1Click:Connect(function() setWindowVisible(false) end)
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    safe(function() if input.KeyCode == Enum.KeyCode.F then setWindowVisible(not window.Visible) end end)
end)

-- ============ 🧪 内测人员 Tab ============
local betaTab = createTab("内测人员", "🧪")

new("TextLabel", {
    Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1,
    Text = "【 脚本作者 】",
    TextColor3 = PRIMARY,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = nextOrder(),
    Parent = betaTab,
})

local authorCard = new("Frame", {
    Size = UDim2.new(1, 0, 0, 76),
    BackgroundColor3 = CARD_BG,
    BorderSizePixel = 0,
    LayoutOrder = nextOrder(),
    Parent = betaTab,
}, {corner(10), stroke(PRIMARY, 1.5, 0.4), padding(10)}) 

local authorAvatarFrame = new("Frame", {
    Size = UDim2.fromOffset(50, 50),
    Position = UDim2.new(0, 0, 0.5, -25),
    BackgroundColor3 = SOFT_BG,
    Parent = authorCard,
}, {corner(999), stroke(PRIMARY, 1, 0.5)})

local authorAvatar = new("ImageLabel", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Image = "rbxassetid://73308017224118",
    ScaleType = Enum.ScaleType.Crop,
    Visible = true,
    Parent = authorAvatarFrame,
}, {corner(999)})

new("TextLabel", {
    Size = UDim2.new(1, -190, 0, 16),
    Position = UDim2.fromOffset(60, 0),
    BackgroundTransparency = 1,
    Text = "作者",
    TextColor3 = PRIMARY,
    Font = Enum.Font.GothamBold,
    TextSize = 13, 
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = authorCard,
})

new("TextLabel", {
    Size = UDim2.new(1, -190, 0, 16),
    Position = UDim2.fromOffset(60, 18),
    BackgroundTransparency = 1,
    Text = "神 (Shen Hub 开发者)",
    TextColor3 = TEXT_DARK,
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = authorCard,
})

new("TextLabel", {
    Size = UDim2.new(1, -190, 0, 16),
    Position = UDim2.fromOffset(60, 36),
    BackgroundTransparency = 1,
    Text = "快手号: 5733022742", 
    TextColor3 = TEXT_DIM,
    Font = Enum.Font.GothamMedium,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = authorCard,
})

local copyAuthorKs = new("TextButton", {
    Size = UDim2.fromOffset(60, 30),
    Position = UDim2.new(1, -60, 0.5, -15),
    BackgroundColor3 = PRIMARY,
    Text = "复制快手",
    TextColor3 = WHITE_BG,
    Font = Enum.Font.GothamBold,
    TextSize = 10,
    AutoButtonColor = false,
    Parent = authorCard,
}, {corner(6)})

copyAuthorKs.MouseButton1Click:Connect(function()
    safe(function()
        if setclipboard then
            setclipboard("5733022742")
            copyAuthorKs.Text = "已复制!"
            task.delay(1.5, function()
                safe(function() copyAuthorKs.Text = "复制快手" end)
            end)
        end
    end)
end)

new("TextLabel", {
    Size = UDim2.new(1,0,0,20),
    BackgroundTransparency = 1,
    Text = "【 内测人员名单 】",
    TextColor3 = PRIMARY,
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    LayoutOrder = nextOrder(),
    Parent = betaTab,
})

local betaMembers = {
    {
        title = "测试人员",
        name = "蛋仔派对板栗王",
        contact = "快手号：5721155297",
        copyText = "5721155297",
        qq = "2580525466",
        avatar = "rbxassetid://112961077620856",  
    },
}

for _, member in ipairs(betaMembers) do
    local card = new("Frame", {
        Size = UDim2.new(1, 0, 0, 76),
        BackgroundColor3 = CARD_BG,
        BorderSizePixel = 0,
        LayoutOrder = nextOrder(),
        Parent = betaTab,
    }, {corner(10), stroke(PRIMARY, 1, 0.7), padding(10)})

    local avatarFrame = new("Frame", {
        Size = UDim2.fromOffset(50, 50),
        Position = UDim2.new(0, 0, 0.5, -25),
        BackgroundColor3 = SOFT_BG, 
        Parent = card,
    }, {corner(999), stroke(PRIMARY, 1, 0.5)})

    local avatarImg = new("ImageLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = member.avatar,
        ScaleType = Enum.ScaleType.Crop,
        Visible = true,
        Parent = avatarFrame,
    }, {corner(999)})

    new("TextLabel", {
        Size = UDim2.new(1, -190, 0, 16),
        Position = UDim2.fromOffset(60, 0),
        BackgroundTransparency = 1,
        Text = member.title,
        TextColor3 = PRIMARY,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -190, 0, 16),
        Position = UDim2.fromOffset(60, 18),
        BackgroundTransparency = 1,
        Text = member.name,
        TextColor3 = TEXT_DARK,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    new("TextLabel", {
        Size = UDim2.new(1, -190, 0, 16),
        Position = UDim2.fromOffset(60, 36),
        BackgroundTransparency = 1,
        Text = member.contact,
        TextColor3 = TEXT_DIM,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local copyKsBtn = new("TextButton", {
        Size = UDim2.fromOffset(60, 22),
        Position = UDim2.new(1, -60, 0.5, 4),
        BackgroundColor3 = SOFT_BG,
        Text = "复制快手",
        TextColor3 = PRIMARY,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        AutoButtonColor = false,
        Parent = card,
    }, {corner(6), stroke(PRIMARY, 1, 0.4)})

    local copyQQBtn = new("TextButton", {
        Size = UDim2.fromOffset(60, 22),
        Position = UDim2.new(1, -60, 0.5, -26),
        BackgroundColor3 = SOFT_BG,
        Text = "复制 QQ",
        TextColor3 = PRIMARY,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        AutoButtonColor = false,
        Parent = card,
    }, {corner(6), stroke(PRIMARY, 1, 0.4)})

    for _, btn in ipairs({copyKsBtn, copyQQBtn}) do
        btn.MouseEnter:Connect(function()
            safe(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=PRIMARY, TextColor3=WHITE_BG}):Play()
            end)
        end)
        btn.MouseLeave:Connect(function()
            safe(function()
                TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3=SOFT_BG, TextColor3=PRIMARY}):Play()
            end)
        end)
    end

    copyKsBtn.MouseButton1Click:Connect(function()
        safe(function()
            if setclipboard then
                setclipboard(member.copyText)
                copyKsBtn.Text = "已复制!"
                task.delay(1.5, function()
                    safe(function() copyKsBtn.Text = "复制快手" end)
                end)
            end
        end)
    end)

    copyQQBtn.MouseButton1Click:Connect(function()
        safe(function()
            if setclipboard then
                setclipboard(tostring(member.qq))
                copyQQBtn.Text = "已复制!"
                task.delay(1.5, function()
                    safe(function() copyQQBtn.Text = "复制 QQ" end)
                end)
            end
        end)
    end)
end

-- ============ 主页 Tab ============
local homeTab = createTab("主页", "🏠")
local CONFIG_FOLDER, COUNT_FILE = "ShenHub", "ShenHub/launch_count.txt"
local launchCount = 0
safe(function() if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end end)
safe(function() if isfile(COUNT_FILE) then launchCount = tonumber(readfile(COUNT_FILE)) or 0 end end)
launchCount = launchCount + 1
safe(function() writefile(COUNT_FILE, tostring(launchCount)) end)

local launchRow = new("Frame", {Size=UDim2.new(1,0,0,36), BackgroundColor3=CARD_BG, BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=homeTab}, {corner(8), stroke(PRIMARY, 1.2, 0.5), padding(10)})
new("TextLabel", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text="你已启动脚本 "..tostring(launchCount).." 次", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=13, TextXAlignment=Enum.TextXAlignment.Center, Parent=launchRow})

local infoRow = new("Frame", {Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, BackgroundColor3=CARD_BG, BorderSizePixel=0, LayoutOrder=nextOrder(), Parent=homeTab}, {corner(8), stroke(PRIMARY, 1, 0.7), padding(10)})
new("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder, Parent=infoRow})
new("TextLabel", {Size=UDim2.new(1,0,0,18), BackgroundTransparency=1, Text="玩家信息", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=1, Parent=infoRow})
local infoOrder = 1
local function makeInfoLine(label, value)
    infoOrder = infoOrder + 1
    local line = new("Frame", {Size=UDim2.new(1,0,0,22), BackgroundTransparency=1, LayoutOrder=infoOrder, Parent=infoRow})
    new("TextLabel", {Size=UDim2.new(0.5,0,1,0), BackgroundTransparency=1, Text=label, TextColor3=TEXT_DIM, Font=Enum.Font.GothamMedium, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, Parent=line})
    local v = new("TextLabel", {Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0.5,0,0,0), BackgroundTransparency=1, Text=value, TextColor3=TEXT_DARK, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Right, Parent=line})
    return v
end
local healthLabel = makeInfoLine("血量", "-")
local speedLabel  = makeInfoLine("速度", "-")
local posLabel    = makeInfoLine("所在坐标", "-")
local playersLabel= makeInfoLine("服务器玩家", "-")
local pingLabel   = makeInfoLine("当前延迟", "-")
local playTimeLabel = makeInfoLine("游戏时长", "0 秒")
local fpsLabel    = makeInfoLine("帧率", "-")

local copyPosBtn = new("TextButton", {Size=UDim2.new(1,0,0,32), BackgroundColor3=CARD_BG, Text="复制当前坐标", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=12, AutoButtonColor=false, LayoutOrder=infoOrder + 1, Parent=infoRow}, {corner(8), stroke(PRIMARY, 1.2, 0.4)})
copyPosBtn.MouseEnter:Connect(function() safe(function() TweenService:Create(copyPosBtn, TweenInfo.new(0.15), {BackgroundColor3=PRIMARY, TextColor3=WHITE_BG}):Play() end) end)
copyPosBtn.MouseLeave:Connect(function() safe(function() TweenService:Create(copyPosBtn, TweenInfo.new(0.15), {BackgroundColor3=CARD_BG, TextColor3=PRIMARY}):Play() end) end)
copyPosBtn.MouseButton1Click:Connect(function()
    safe(function()
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = hrp.Position
            local text = string.format("%d, %d, %d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
            if setclipboard then setclipboard(text) end
            copyPosBtn.Text = "已复制："..text
            task.delay(2, function() safe(function() copyPosBtn.Text = "复制当前坐标" end) end)
        else
            copyPosBtn.Text = "角色未加载"
            task.delay(2, function() safe(function() copyPosBtn.Text = "复制当前坐标" end) end)
        end
    end)
end)
task.spawn(function()
    local frames, last = 0, tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - last >= 1 then safe(function() fpsLabel.Text = frames.." FPS" end) frames = 0 last = now end
    end)
end)
local antiAFKConn = nil
makeToggle(homeTab, {Title="防挂机", Value=true, Callback=function(s) safe(function()
    if antiAFKConn then antiAFKConn:Disconnect() antiAFKConn = nil end
    if s then
        antiAFKConn = player.Idled:Connect(function()
            safe(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController(); vu:ClickButton2(Vector2.new())
            end)
        end)
    end
end) end})
makeButton(homeTab, {Title="翻阅服务器（随机加入）", Callback=function() safe(function()
    local ok, result = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) end)
    if not ok or not result or not result.data then return end
    local candidates = {}
    for _, srv in ipairs(result.data) do
        if srv.id and srv.id ~= game.JobId and srv.playing < srv.maxPlayers then table.insert(candidates, srv.id) end
    end
    if #candidates == 0 then return end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, candidates[math.random(1, #candidates)], player)
end) end})
makeButton(homeTab, {Title="重新进入当前服务器", Callback=function() safe(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player) end) end})
makeButton(homeTab, {Title="退出服务器", Callback=function() safe(function() player:Kick("已退出服务器") end) end})

-- ============ 通用 Tab ============
local generalTab = createTab("通用", "⚙")

-- 原有通用功能
local spinEnabled, spinValue, spinConn = false, 40, nil
local function getHum()
    local char = player.Character
    if not char then return nil end
    return char:FindFirstChildOfClass("Humanoid")
end
local function setAutoRotate(s) local h = getHum() if h then h.AutoRotate = s end end
local function applySpin()
    if spinConn then spinConn:Disconnect() spinConn = nil end
    if not spinEnabled then setAutoRotate(true) return end
    setAutoRotate(false)
    spinConn = RunService.RenderStepped:Connect(function(dt)
        safe(function()
            local char = player.Character
            if not char then return end
            local h = char:FindFirstChildOfClass("Humanoid")
            if h and h.AutoRotate then h.AutoRotate = false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinValue * 36) * dt, 0) end
        end)
    end)
end
player.CharacterAdded:Connect(function() if spinEnabled then task.wait(0.3); setAutoRotate(false) end end)
makeToggle(generalTab, {Title="旋转", Value=false, Callback=function(s) safe(function() spinEnabled = s; applySpin() end) end})
makeInput(generalTab, {Title="旋转速度", Desc="请输入 1 - 99999 之间的数值", Placeholder="默认 40", Value="40", Callback=function(text) safe(function()
    local v = tonumber(text); if not v then return end
    spinValue = math.clamp(math.floor(v), 1, 99999)
end) end})
local speedEnabled, speedValue = false, 16
local jumpEnabled, jumpValue = false, 50
local fovEnabled, fovValue = false, 70
local infJumpEnabled, infJumpConn = false, nil
makeToggle(generalTab, {Title="开启速度修改", Value=false, Callback=function(s) safe(function()
    speedEnabled = s
    local h = getHum()
    if h then h.WalkSpeed = s and speedValue or 16 end
end) end})
makeInput(generalTab, {Title="速度数值", Desc="请输入 0 - 99999 之间的数值", Placeholder="默认 16", Value="16", Callback=function(text) safe(function()
    local v = tonumber(text); if not v then return end
    speedValue = math.clamp(math.floor(v), 0, 99999)
    if speedEnabled then local h = getHum() if h then h.WalkSpeed = speedValue end end
end) end})
makeToggle(generalTab, {Title="开启跳跃修改", Value=false, Callback=function(s) safe(function()
    jumpEnabled = s
    local h = getHum()
    if h then h.JumpPower = s and jumpValue or 50 end
end) end})
makeInput(generalTab, {Title="跳跃数值", Desc="请输入 0 - 99999 之间的数值", Placeholder="默认 50", Value="50", Callback=function(text) safe(function()
    local v = tonumber(text); if not v then return end
    jumpValue = math.clamp(math.floor(v), 0, 99999)
    if jumpEnabled then local h = getHum() if h then h.JumpPower = jumpValue end end
end) end})
makeToggle(generalTab, {Title="开启 FOV 修改", Value=false, Callback=function(s) safe(function()
    fovEnabled = s
    local cam = workspace.CurrentCamera
    if cam then cam.FieldOfView = s and fovValue or 70 end
end) end})
makeInput(generalTab, {Title="FOV 数值", Desc="请输入 20 - 999 之间的数值", Placeholder="默认 70", Value="70", Callback=function(text) safe(function()
    local v = tonumber(text); if not v then return end
    fovValue = math.clamp(math.floor(v), 20, 999)
    if fovEnabled then local cam = workspace.CurrentCamera if cam then cam.FieldOfView = fovValue end end
end) end})
makeToggle(generalTab, {Title="无限跳", Value=false, Callback=function(s) safe(function()
    infJumpEnabled = s
    if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
    if s then
        infJumpConn = UIS.JumpRequest:Connect(function()
            safe(function()
                if infJumpEnabled then local h = getHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
            end)
        end)
    end
end) end})
local noclipEnabled, noclipConn = false, nil
makeToggle(generalTab, {Title="穿墙", Value=false, Callback=function(s) safe(function()
    noclipEnabled = s
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    if s then
        noclipConn = RunService.Stepped:Connect(function()
            safe(function()
                if noclipEnabled then
                    local char = player.Character
                    if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
                end
            end)
        end)
    end
end) end})
makeButton(generalTab, {Title="神飞行", Callback=function() safe(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/bbb/main/shen.lua"))() end) end})
makeButton(generalTab, {Title="触碰甩飞", Callback=function() safe(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblox-scri/main/123"))() end) end})
makeButton(generalTab, {Title="🚗 坐标飞车", Callback=function() safe(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblox-1/main/6"))() end) end})

-- ========= 移到了最下面的：夜视 和 除雾 =========
local nightVisionEnabled = false
local nvBrightness = nil
local nvOutdoorAmbient = nil
local nvClockTime = nil

makeToggle(generalTab, {
    Title = "🌙 夜视",
    Value = false,
    Callback = function(s)
        safe(function()
            nightVisionEnabled = s
            if nightVisionEnabled then
                nvBrightness = nvBrightness or Lighting.Brightness
                nvOutdoorAmbient = nvOutdoorAmbient or Lighting.OutdoorAmbient
                nvClockTime = nvClockTime or Lighting.ClockTime
                
                Lighting.Brightness = 3
                Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
                Lighting.ClockTime = 12
                Lighting.GlobalShadows = false
            else
                Lighting.Brightness = nvBrightness or 1
                Lighting.OutdoorAmbient = nvOutdoorAmbient or Color3.fromRGB(128, 128, 128)
                Lighting.ClockTime = nvClockTime or 14
                Lighting.GlobalShadows = true
                nvBrightness, nvOutdoorAmbient, nvClockTime = nil, nil, nil
            end
        end)
    end
})

local noFogEnabled = false
local origFogStart, origFogEnd = nil, nil
local fogConn = nil

makeToggle(generalTab, {
    Title = "🌫️ 除雾",
    Value = false,
    Callback = function(s)
        safe(function()
            noFogEnabled = s
            if noFogEnabled then
                origFogStart = origFogStart or Lighting.FogStart
                origFogEnd = origFogEnd or Lighting.FogEnd
                
                if fogConn then fogConn:Disconnect() end
                fogConn = RunService.Heartbeat:Connect(function()
                    safe(function()
                        if noFogEnabled then
                            Lighting.FogEnd = 100000
                            Lighting.FogStart = 100000
                            for _, v in pairs(Lighting:GetChildren()) do
                                if v:IsA("Atmosphere") then v.Density = 0 end
                                if v:IsA("SunRaysEffect") then v.Intensity = 0 end
                                if v:IsA("BlurEffect") then v.Size = 0 end
                            end
                        end
                    end)
                end)
            else
                if fogConn then fogConn:Disconnect() fogConn = nil end
                if origFogStart then Lighting.FogStart = origFogStart end
                if origFogEnd then Lighting.FogEnd = origFogEnd end
                origFogStart, origFogEnd = nil, nil
            end
        end)
    end
})

-- ============ ESP ============
local espEnabled, espConn, espCache, espCleanConn = false, nil, {}, nil
local function espCreate(p)
    if not HAS_DRAWING then return nil end
    if espCache[p] then return espCache[p] end
    local box = Drawing.new("Square"); box.Thickness=1; box.Filled=false; box.Transparency=1; box.Visible=false
    local name = Drawing.new("Text"); name.Size=14; name.Center=true; name.Outline=true; name.Color=Color3.fromRGB(255,255,255); name.Visible=false
    local dist = Drawing.new("Text"); dist.Size=12; dist.Center=true; dist.Outline=true; dist.Color=Color3.fromRGB(255,255,0); dist.Visible=false
    espCache[p] = {box=box, name=name, dist=dist}
    return espCache[p]
end
local function espHideAll()
    for _, d in pairs(espCache) do
        pcall(function() d.box.Visible = false end)
        pcall(function() d.name.Visible = false end)
        pcall(function() d.dist.Visible = false end)
    end
end
local function espCleanupCache()
    for p, d in pairs(espCache) do
        if not p or not p.Parent then
            pcall(function() d.box:Remove() end)
            pcall(function() d.name:Remove() end)
            pcall(function() d.dist:Remove() end)
            espCache[p] = nil
        end
    end
end
local function espStart()
    if not HAS_DRAWING then return end
    if espConn then espConn:Disconnect() end
    if espCleanConn then espCleanConn:Disconnect() end
    espCleanConn = task.spawn(function()
        while espEnabled do
            task.wait(1)
            safe(function() espHideAll(); espCleanupCache() end)
        end
    end)
    espConn = RunService.RenderStepped:Connect(function()
        safe(function()
            if not espEnabled then espHideAll() return end
            local cam = workspace.CurrentCamera
            if not cam then return end
            local myPos = cam.CFrame.Position
            espHideAll()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    local char = p.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local head = char and char:FindFirstChild("Head")
                    if hum and hrp and head and hum.Health > 0 then
                        local rootPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
                        local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
                        if onScreen then
                            local d = espCreate(p)
                            if d then
                                local h = math.abs(rootPos.Y - headPos.Y) * 2.4
                                local w = h * 0.55
                                local tl = Vector2.new(rootPos.X - w / 2, rootPos.Y - h / 2)
                                d.box.Visible = true; d.box.Size = Vector2.new(w, h); d.box.Position = tl; d.box.Color = Color3.fromRGB(255, 0, 0)
                                d.name.Visible = true; d.name.Position = Vector2.new(rootPos.X, tl.Y - 18); d.name.Text = p.DisplayName.." (@"..p.Name..")"
                                local dd = (hrp.Position - myPos).Magnitude
                                d.dist.Visible = true; d.dist.Position = Vector2.new(rootPos.X, tl.Y + h + 4); d.dist.Text = string.format("[%dm]", math.floor(dd))
                            end
                        end
                    end
                end
            end
        end)
    end)
end
makeToggle(generalTab, {Title="ESP 透视", Value=false, Callback=function(s) safe(function()
    espEnabled = s
    if s then espStart()
    else
        if espConn then espConn:Disconnect() espConn = nil end
        if espCleanConn then espCleanConn:Disconnect() espCleanConn = nil end
        espHideAll(); espCleanupCache()
    end
end) end})

-- ============ 自由视角（仿森林99夜 WindUI 版） ============
local freeCamEnabled, freeCamSpeed = false, 50
local freeCamConn = nil
local savedCamType, savedCamSubject = nil, nil
local freeCamYaw, freeCamPitch = 0, 0
local freeCamInputConns = {}
local freeCamMove = {W=false, A=false, S=false, D=false, Up=false, Down=false}
local freeCamGui = nil

local function destroyFreeCamUI()
    if freeCamGui and freeCamGui.Parent then freeCamGui:Destroy() end    freeCamGui = nil
end

local function createFreeCamUI()
    if freeCamGui then return end
    local parentGui = game:GetService("CoreGui")
    local gui = new("ScreenGui", {Name="FreeCamUI", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=5000, Parent=parentGui})
    freeCamGui = gui

    local function makeBtn(text, pos, size, key)
        local btn = new("TextButton", {
            Size = size, Position = pos,
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.4,
            Text = text, TextColor3 = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.SourceSansBold, TextSize = 22, AutoButtonColor = false,
            Parent = gui,
        }, {corner(12)})
        new("UIStroke", {Color=PRIMARY, Thickness=2, Parent=btn})
        btn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                freeCamMove[key] = true
            end
        end)
        btn.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                freeCamMove[key] = false
            end
        end)
        return btn
    end

    local btnSize = UDim2.fromOffset(56, 56)
    local gap = 62
    local baseX = 30
    local baseY = -220

    makeBtn("▲", UDim2.new(0, baseX + gap, 1, baseY - gap), btnSize, "W")
    makeBtn("◀", UDim2.new(0, baseX, 1, baseY), btnSize, "A")
    makeBtn("▼", UDim2.new(0, baseX + gap, 1, baseY), btnSize, "S")
    makeBtn("▶", UDim2.new(0, baseX + gap * 2, 1, baseY), btnSize, "D")
    makeBtn("↑", UDim2.new(1, -80, 1, baseY - gap), UDim2.fromOffset(60, 60), "Up")
    makeBtn("↓", UDim2.new(1, -80, 1, baseY), UDim2.fromOffset(60, 60), "Down")
end

makeToggle(generalTab, {
    Title = "📸 自由视角（手机轮盘）",
    Value = false,
    Callback = function(state)
        freeCamEnabled = state
        local cam = workspace.CurrentCamera
        if not cam then return end

        if state then
            savedCamType = cam.CameraType
            savedCamSubject = cam.CameraSubject
            cam.CameraType = Enum.CameraType.Scriptable
            cam.CameraSubject = nil

            local look = cam.CFrame.LookVector
            freeCamYaw = math.deg(math.atan2(-look.X, -look.Z))
            freeCamPitch = math.deg(math.asin(look.Y))

            createFreeCamUI()

            local rotateTouchId = nil
            local lastTouchPos = nil
            table.insert(freeCamInputConns, UIS.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if input.UserInputType == Enum.UserInputType.Touch then
                    local pos = input.Position
                    if pos.X > cam.ViewportSize.X * 0.4 then
                        rotateTouchId = input
                        lastTouchPos = pos
                    end
                end
            end))
            table.insert(freeCamInputConns, UIS.InputChanged:Connect(function(input)
                if input == rotateTouchId and input.UserInputType == Enum.UserInputType.Touch then
                    local delta = input.Position - lastTouchPos
                    freeCamYaw = freeCamYaw - delta.X * 0.4
                    freeCamPitch = math.clamp(freeCamPitch - delta.Y * 0.4, -89, 89)
                    lastTouchPos = input.Position
                end
            end))
            table.insert(freeCamInputConns, UIS.InputEnded:Connect(function(input)
                if input == rotateTouchId then
                    rotateTouchId = nil
                    lastTouchPos = nil
                end
            end))

            freeCamConn = RunService.RenderStepped:Connect(function(dt)
                if not freeCamEnabled then return end
                local c = workspace.CurrentCamera
                if not c then return end

                local rot = CFrame.fromEulerAnglesYXZ(math.rad(freeCamPitch), math.rad(freeCamYaw), 0)
                local forward = rot.LookVector
                local right = rot.RightVector
                local move = Vector3.new(0, 0, 0)

                if freeCamMove.W then move = move + forward end
                if freeCamMove.S then move = move - forward end
                if freeCamMove.A then move = move - right end
                if freeCamMove.D then move = move + right end
                if freeCamMove.Up then move = move + Vector3.new(0, 1, 0) end
                if freeCamMove.Down then move = move - Vector3.new(0, 1, 0) end

                local newPos = c.CFrame.Position + move * freeCamSpeed * dt
                c.CFrame = CFrame.new(newPos) * rot
            end)
        else
            if freeCamConn then freeCamConn:Disconnect() freeCamConn = nil end
            for _, conn in ipairs(freeCamInputConns) do pcall(function() conn:Disconnect() end) end
            freeCamInputConns = {}
            freeCamMove = {W=false, A=false, S=false, D=false, Up=false, Down=false}
            destroyFreeCamUI()

            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = hum or hrp or char
            if hrp then
                local behind = hrp.CFrame.Position - hrp.CFrame.LookVector * 10 + Vector3.new(0, 5, 0)
                cam.CFrame = CFrame.new(behind, hrp.CFrame.Position)
            end
            if savedCamType and savedCamType ~= Enum.CameraType.Scriptable then
                task.wait(0.05)
                cam.CameraType = savedCamType
                if savedCamSubject then cam.CameraSubject = savedCamSubject end
            end
        end
    end
})

makeSlider(generalTab, {
    Title = "自由视角速度",
    Min = 10, Max = 500, Default = 50,
    Callback = function(v) safe(function() freeCamSpeed = v end) end,
})

-- ============ 准星显示 ============
local crosshairGui = new("ScreenGui", {Name="CrosshairGui", ResetOnSpawn=false, IgnoreGuiInset=true, DisplayOrder=999, Parent=playerGui})
local crosshairH = new("Frame", {Size=UDim2.fromOffset(20,2), Position=UDim2.new(0.5,-10,0.5,-1), BackgroundColor3=Color3.fromRGB(255,0,0), BorderSizePixel=0, Visible=false, Parent=crosshairGui}, {corner(1)})
local crosshairV = new("Frame", {Size=UDim2.fromOffset(2,20), Position=UDim2.new(0.5,-1,0.5,-10), BackgroundColor3=Color3.fromRGB(255,0,0), BorderSizePixel=0, Visible=false, Parent=crosshairGui}, {corner(1)})
makeToggle(generalTab, {
    Title = "🎯 准星显示",
    Value = false,
    Callback = function(s)
        safe(function()
            crosshairH.Visible = s
            crosshairV.Visible = s
        end)
    end,
})

-- ============ 自动跳跃 ============
local autoJumpEnabled, autoJumpConn, autoJumpLastJump = false, nil, 0
makeToggle(generalTab, {
    Title = "🔄 自动跳跃",
    Value = false,
    Callback = function(s)
        safe(function()
            autoJumpEnabled = s
            if autoJumpConn then autoJumpConn:Disconnect() autoJumpConn = nil end
            if s then
                autoJumpLastJump = 0
                autoJumpConn = RunService.Heartbeat:Connect(function()
                    safe(function()
                        if not autoJumpEnabled then return end
                        local h = getHum()
                        if not h then return end
                        local char = player.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if not hrp then return end
                        local now = tick()
                        if now - autoJumpLastJump < 0.15 then return end
                        local state = h:GetState()
                        local onGround = (state == Enum.HumanoidStateType.Running)
                            or (state == Enum.HumanoidStateType.RunningNoPhysics)
                            or (state == Enum.HumanoidStateType.Landed)
                            or (h.FloorMaterial ~= Enum.Material.Air)
                        if onGround and hrp.AssemblyLinearVelocity.Y <= 1 then
                            h.Jump = true
                            h:ChangeState(Enum.HumanoidStateType.Jumping)
                            autoJumpLastJump = now
                        end
                        if hrp.AssemblyLinearVelocity.Y > h.JumpPower then
                            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, h.JumpPower, hrp.AssemblyLinearVelocity.Z)
                        end
                    end)
                end)
            end
        end)
    end,
})

-- ============ 自瞄 Tab ============
local aimTab = createTab("自瞄", "🎯")
local aimEnabled, aimFOVEnabled, aimFOVRadius, aimWallCheck, aimPart, aimConn = false, false, 120, false, "头部", nil
local aimCircle = nil
if HAS_DRAWING then
    aimCircle = Drawing.new("Circle")
    aimCircle.Thickness=2; aimCircle.Radius=aimFOVRadius; aimCircle.Filled=false; aimCircle.Transparency=1; aimCircle.Visible=false
end
task.spawn(function()
    while true do
        task.wait(0.05)
        safe(function()
            if not aimCircle then return end
            if aimFOVEnabled and aimEnabled then
                local cam = workspace.CurrentCamera
                if cam then
                    aimCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
                    aimCircle.Radius = aimFOVRadius; aimCircle.Visible = true
                    aimCircle.Color = Color3.fromHSV((tick() * 0.5) % 1, 1, 1)
                else aimCircle.Visible = false end
            else aimCircle.Visible = false end
        end)
    end
end)
local function hasClearLine(fromPos, toPos, targetChar)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ignore = {player.Character}
    if targetChar then table.insert(ignore, targetChar) end
    params.FilterDescendantsInstances = ignore
    return workspace:Raycast(fromPos, toPos - fromPos, params) == nil
end
local function getAimPart(char)
    if aimPart == "头部" then return char:FindFirstChild("Head")
    elseif aimPart == "身体" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    elseif aimPart == "最近" then return char:FindFirstChild("HumanoidRootPart")
    elseif aimPart == "随机" then
        local ps = {}
        if char:FindFirstChild("Head") then table.insert(ps, char.Head) end
        if char:FindFirstChild("UpperTorso") then table.insert(ps, char.UpperTorso) end
        if char:FindFirstChild("Torso") then table.insert(ps, char.Torso) end
        if char:FindFirstChild("HumanoidRootPart") then table.insert(ps, char.HumanoidRootPart) end
        if #ps > 0 then return ps[math.random(1, #ps)] end
    end
    return char:FindFirstChild("Head")
end
local function findAimTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local best, bestDist = nil, aimFOVRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local sp, onScreen = cam:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                    if d < bestDist then
                        if not aimWallCheck or hasClearLine(cam.CFrame.Position, hrp.Position, char) then best = p; bestDist = d end
                    end
                end
            end
        end
    end
    return best
end
local function applyAim()
    if aimConn then aimConn:Disconnect() aimConn = nil end
    if not aimEnabled then return end
    aimConn = RunService.RenderStepped:Connect(function()
        safe(function()
            if not aimEnabled then return end
            local cam = workspace.CurrentCamera; if not cam then return end
            local t = findAimTarget()
            if t then
                local char = t.Character
                local part = char and getAimPart(char)
                if part then cam.CFrame = CFrame.new(cam.CFrame.Position, part.Position) end
            end
        end)
    end)
end
makeToggle(aimTab, {Title="自瞄", Value=false, Callback=function(s) safe(function() aimEnabled = s; applyAim() end) end})
makeToggle(aimTab, {Title="显示 FOV 圈（彩虹）", Value=false, Callback=function(s) safe(function() aimFOVEnabled = s end) end})
makeSlider(aimTab, {Title="FOV 圈半径", Min=30, Max=400, Default=120, Callback=function(v) safe(function() aimFOVRadius = v end) end})
makeToggle(aimTab, {Title="墙体检测", Value=false, Callback=function(s) safe(function() aimWallCheck = s end) end})
makeDropdown(aimTab, {Title="瞄准部位", Options={"头部","身体","随机","最近"}, Value="头部", Callback=function(o) safe(function() aimPart = o end) end})

-- ============ 碰撞箱修改 Tab ============
local hitboxTab = createTab("碰撞箱修改", "📦")
local hbAllEnabled, hbAllSize, hbAllColor, hbAllDepth, hbAllVisual = false, 10, Color3.fromRGB(0,100,255), 0.5, false
local hbAllConn, hbAllOriginals, hbAllHL = nil, {}, {}
local function hbAllApplyOne(plr)
    if plr == player then return end
    local char = plr.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if not hbAllOriginals[hrp] then
        hbAllOriginals[hrp] = {Size=hrp.Size, Transparency=hrp.Transparency, Color=hrp.Color, Material=hrp.Material, CanCollide=hrp.CanCollide}
    end
    hrp.Size = Vector3.new(hbAllSize, hbAllSize, hbAllSize)
    hrp.Color = hbAllColor; hrp.Transparency = 1 - hbAllDepth; hrp.Material = Enum.Material.ForceField; hrp.CanCollide = false
    local hl = hbAllHL[plr]
    if hbAllVisual then
        if not hl or not hl.Parent then
            hl = Instance.new("Highlight"); hl.FillTransparency = 1; hl.OutlineColor = hbAllColor; hl.OutlineTransparency = 0; hl.Adornee = hrp; hl.Parent = hrp; hbAllHL[plr] = hl
        else hl.OutlineColor = hbAllColor; hl.Adornee = hrp end
    else if hl then hl:Destroy() hbAllHL[plr] = nil end end
end
local function hbAllApply()
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= player then hbAllApplyOne(plr) end end
end
local function hbAllRestore()
    for hrp, d in pairs(hbAllOriginals) do
        pcall(function()
            if hrp and hrp.Parent then
                hrp.Size=d.Size; hrp.Transparency=d.Transparency; hrp.Color=d.Color; hrp.Material=d.Material; hrp.CanCollide=d.CanCollide
            end
        end)
    end
    hbAllOriginals = {}
    for _, hl in pairs(hbAllHL) do pcall(function() hl:Destroy() end) end
    hbAllHL = {}
end
local function hbAllStartLoop()
    if hbAllConn then hbAllConn:Disconnect() hbAllConn = nil end
    if not hbAllEnabled then return end
    hbAllConn = RunService.Heartbeat:Connect(function() safe(function() if hbAllEnabled then hbAllApply() end end) end)
end
new("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="【 所有玩家 】", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=nextOrder(), Parent=hitboxTab})
makeToggle(hitboxTab, {Title="开启碰撞箱扩大（所有玩家）", Value=false, Callback=function(s) safe(function()
    hbAllEnabled = s
    if s then hbAllApply(); hbAllStartLoop()
    else if hbAllConn then hbAllConn:Disconnect() hbAllConn = nil end hbAllRestore() end
end) end})
makeSlider(hitboxTab, {Title="碰撞箱倍数（所有玩家）", Min=1, Max=200, Default=10, Callback=function(v) safe(function() hbAllSize = v; if hbAllEnabled then hbAllApply() end end) end})
makeSlider(hitboxTab, {Title="颜色深度（所有玩家）", Min=0, Max=100, Default=50, Callback=function(v) safe(function() hbAllDepth = v/100; if hbAllEnabled then hbAllApply() end end) end})
makeToggle(hitboxTab, {Title="显示线框（所有玩家）", Value=false, Callback=function(s) safe(function() hbAllVisual = s; if hbAllEnabled then hbAllApply() end end) end})
makeDropdown(hitboxTab, {Title="颜色（所有玩家）", Options={"蓝色","红色","绿色","黄色","紫色","青色","白色","橙色"}, Value="蓝色", Callback=function(o) safe(function()
    if o=="蓝色" then hbAllColor=Color3.fromRGB(0,100,255)
    elseif o=="红色" then hbAllColor=Color3.fromRGB(255,0,0)
    elseif o=="绿色" then hbAllColor=Color3.fromRGB(0,255,0)
    elseif o=="黄色" then hbAllColor=Color3.fromRGB(255,255,0)
    elseif o=="紫色" then hbAllColor=Color3.fromRGB(255,0,255)
    elseif o=="青色" then hbAllColor=Color3.fromRGB(0,255,255)
    elseif o=="白色" then hbAllColor=Color3.fromRGB(255,255,255)
    elseif o=="橙色" then hbAllColor=Color3.fromRGB(255,128,0) end
    if hbAllEnabled then hbAllApply() end
end) end})
makeButton(hitboxTab, {Title="重置碰撞箱", Callback=function() safe(function()
    hbAllEnabled = false; hbAllSize = 10; hbAllDepth = 0.5
    if hbAllConn then hbAllConn:Disconnect() hbAllConn = nil end
    hbAllRestore()
end) end})

-- ============ 工具 Tab ============
local toolTab = createTab("工具", "🧰")
local tlState = {trail=nil, trailAtt=nil, highlight=nil, glow=nil, fire=nil, sparkles=nil, headFire=nil}
local function tlGetHRP() local c = player.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function tlGetHead() local c = player.Character; return c and c:FindFirstChild("Head") end
new("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="【 特效 】", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=nextOrder(), Parent=toolTab})
makeToggle(toolTab, {Title="人物拖尾", Value=false, Callback=function(s) safe(function()
    if s then
        local hrp = tlGetHRP(); if not hrp then return end
        if tlState.trail then tlState.trail:Destroy() end
        if tlState.trailAtt then for _, a in ipairs(tlState.trailAtt) do a:Destroy() end end
        local a0 = Instance.new("Attachment", hrp); local a1 = Instance.new("Attachment", hrp)
        a0.Position = Vector3.new(0, 1, 0); a1.Position = Vector3.new(0, -1, 0)
        tlState.trail = Instance.new("Trail")
        tlState.trail.Attachment0 = a0; tlState.trail.Attachment1 = a1
        tlState.trail.Lifetime = 0.5; tlState.trail.Color = ColorSequence.new(PRIMARY, ACCENT); tlState.trail.Parent = hrp
        tlState.trailAtt = {a0, a1}
    else
        if tlState.trail then tlState.trail:Destroy() tlState.trail = nil end
        if tlState.trailAtt then for _, a in ipairs(tlState.trailAtt) do pcall(function() a:Destroy() end) end tlState.trailAtt = nil end
    end
end) end})
makeToggle(toolTab, {Title="人物发光", Value=false, Callback=function(s) safe(function()
    if s then
        local char = player.Character; if not char then return end
        if tlState.highlight then tlState.highlight:Destroy() end
        tlState.highlight = Instance.new("Highlight")
        tlState.highlight.FillColor = PRIMARY; tlState.highlight.OutlineColor = WHITE_BG
        tlState.highlight.FillTransparency = 0.5; tlState.highlight.OutlineTransparency = 0
        tlState.highlight.Adornee = char; tlState.highlight.Parent = char
    else if tlState.highlight then tlState.highlight:Destroy() tlState.highlight = nil end end
end) end})
makeToggle(toolTab, {Title="人物泛光", Value=false, Callback=function(s) safe(function()
    if s then
        local hrp = tlGetHRP(); if not hrp then return end
        if tlState.glow then tlState.glow:Destroy() end
        tlState.glow = Instance.new("PointLight")
        tlState.glow.Brightness = 3; tlState.glow.Range = 15; tlState.glow.Parent = hrp
    else if tlState.glow then tlState.glow:Destroy() tlState.glow = nil end end
end) end})
makeToggle(toolTab, {Title="火焰特效", Value=false, Callback=function(s) safe(function()
    if s then
        local hrp = tlGetHRP(); if not hrp then return end
        if tlState.fire then tlState.fire:Destroy() end
        tlState.fire = Instance.new("Fire"); tlState.fire.Size = 5; tlState.fire.Heat = 10; tlState.fire.Parent = hrp
    else if tlState.fire then tlState.fire:Destroy() tlState.fire = nil end end
end) end})
makeToggle(toolTab, {Title="闪光粒子", Value=false, Callback=function(s) safe(function()
    if s then
        local hrp = tlGetHRP(); if not hrp then return end
        if tlState.sparkles then tlState.sparkles:Destroy() end
        tlState.sparkles = Instance.new("Sparkles"); tlState.sparkles.SparkleColor = Color3.fromRGB(255,255,0); tlState.sparkles.Parent = hrp
    else if tlState.sparkles then tlState.sparkles:Destroy() tlState.sparkles = nil end end
end) end})
makeToggle(toolTab, {Title="头顶火焰冠", Value=false, Callback=function(s) safe(function()
    if s then
        local head = tlGetHead(); if not head then return end
        if tlState.headFire then tlState.headFire:Destroy() end
        tlState.headFire = Instance.new("Fire"); tlState.headFire.Size = 3; tlState.headFire.Heat = 5; tlState.headFire.Parent = head
    else if tlState.headFire then tlState.headFire:Destroy() tlState.headFire = nil end end
end) end})
makeButton(toolTab, {Title="一键拾取周围所有工具", Callback=function() safe(function()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and not obj.Parent:IsA("Backpack") then
            local dist = (obj:GetPivot().Position - hrp.Position).Magnitude
            if dist < 200 then pcall(function() obj.Parent = player.Backpack; count = count + 1 end) end
        end
    end
    print("[工具] 已拾取 "..count.." 个工具")
end) end})
makeButton(toolTab, {Title="清空背包所有工具", Callback=function() safe(function()
    for _, t in ipairs(player.Backpack:GetChildren()) do if t:IsA("Tool") then t:Destroy() end end
end) end})
makeSlider(toolTab, {Title="人物透明度", Min=0, Max=100, Default=0, Callback=function(v) safe(function()
    local char = player.Character; if not char then return end
    local t = v / 100
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then part.Transparency = t end
    end
end) end})
makeButton(toolTab, {Title="视角拉近", Callback=function() safe(function() workspace.CurrentCamera.FieldOfView = 30 end) end})
makeButton(toolTab, {Title="视角恢复正常", Callback=function() safe(function() workspace.CurrentCamera.FieldOfView = 70 end) end})
makeButton(toolTab, {Title="视角拉远", Callback=function() safe(function() workspace.CurrentCamera.FieldOfView = 120 end) end})

-- ============ 甩飞 Tab ============
local flingTab = createTab("甩飞", "💥")
makeButton(flingTab, {Title="甩飞", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/996/main/787878787878"))()
end) end})

-- ============ 各大脚本 Tab ============
local scriptsTab = createTab("各大脚本", "📜")
makeButton(scriptsTab, {Title="🎮 皮脚本", Callback=function() safe(function()
    getgenv().XiaoPi = "皮脚本QQ群1002100032"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua"))()
end) end})
makeButton(scriptsTab, {Title="🧪 神脚本测试版", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblox-script/main/shenjiaoben"))()
end) end})
makeButton(scriptsTab, {Title="🤖 ROB脚本", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4"))()
end) end})
makeButton(scriptsTab, {Title="🍃 叶脚本", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua"))()
end) end})
makeButton(scriptsTab, {Title="🖤 黑脚本", Callback=function() safe(function()
    loadstring(game:HttpGet("\x68\x74\x74\x70\x73\x3a\x2f\x2f\x72\x61\x77\x2e\x67\x69\x74\x68\x75\x62\x75\x73\x65\x72\x63\x6f\x6e\x74\x65\x6e\x74\x2e\x63\x6f\x6d\x2f\x68\x67\x76\x75\x79\x67\x75\x79\x67\x2f\x48\x45\x49\x4a\x49\x41\x4f\x42\x45\x4e\x2f\x6d\x61\x69\x6e\x2f\x61\x61\x61"))()
end) end})

-- ============ 服务器 Tab ============
local serverTab = createTab("服务器", "🌐")
makeButton(serverTab, {Title="🌲 森林中的九九夜", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblox-s/main/7"))()
end) end})
makeButton(serverTab, {Title="👋 偷走巴掌", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblox-sript/main/14"))()
end) end})
makeButton(serverTab, {Title="👋 找出谁打了一巴掌", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblox-scrpt/main/1"))()
end) end})
makeButton(serverTab, {Title="🛤️ 死铁轨", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblox-cript/main/铁轨"))()
end) end})
makeButton(serverTab, {Title="🏥 动物医院", Callback=function() safe(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblox-scipt/main/动物医院"))()
end) end})
makeButton(serverTab, {
    Title = "🌪️ 自然灾害",
    Callback = function()
        safe(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/luauser729/roblo-script/main/自然灾害"))()
            end)
            if not ok then
                warn("[自然灾害] 加载失败:", err)
            end
        end)
    end,
})

-- ============ 设置 Tab ============
local settingsTab = createTab("设置", "🔧")
new("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="【 UI 外观 】", TextColor3=PRIMARY, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=nextOrder(), Parent=settingsTab})
makeDropdown(settingsTab, {Title="UI 边框颜色", Options={"蓝色","红色","绿色","黄色","紫色","青色","白色","黑色","橙色","粉色"}, Value="蓝色", Callback=function(opt) safe(function()
    local c
    if opt=="蓝色" then c = Color3.fromRGB(0,140,255)
    elseif opt=="红色" then c = Color3.fromRGB(230,70,70)
    elseif opt=="绿色" then c = Color3.fromRGB(60,200,120)
    elseif opt=="黄色" then c = Color3.fromRGB(240,200,60)
    elseif opt=="紫色" then c = Color3.fromRGB(160,100,255)
    elseif opt=="青色" then c = Color3.fromRGB(70,220,220)
    elseif opt=="白色" then c = Color3.fromRGB(255,255,255)
    elseif opt=="黑色" then c = Color3.fromRGB(30,30,30)
    elseif opt=="橙色" then c = Color3.fromRGB(255,150,60)
    elseif opt=="粉色" then c = Color3.fromRGB(255,100,180) end
    if c then applyStrokeColor(c) end
end) end})
new("TextLabel", {Size=UDim2.new(1,0,0,20), BackgroundTransparency=1, Text="【 危险操作 】", TextColor3=WARN_RED, Font=Enum.Font.GothamBold, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left, LayoutOrder=nextOrder(), Parent=settingsTab})
makeButton(settingsTab, {Title="摧毁 UI（关闭当前脚本）", Callback=function() safe(function()
    if HAS_DRAWING then
        pcall(function()
            for _, d in pairs(espCache) do
                pcall(function() d.box:Remove() end)
                pcall(function() d.name:Remove() end)
                pcall(function() d.dist:Remove() end)
            end
            espCache = {}
            if aimCircle then pcall(function() aimCircle:Remove() end) aimCircle = nil end
        end)
    end
    pcall(function()
        local char = player.Character
        if char then for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end end
    end)
    pcall(function() gui:Destroy() end)
    pcall(function() if crosshairGui then crosshairGui:Destroy() end end)
    pcall(function() if freeCamGui then freeCamGui:Destroy() end end)
    print("[神脚本] UI 已摧毁，脚本已关闭")
end) end})

-- ============ 实时刷新 ============
local joinTime = tick()
task.spawn(function()
    while true do
        task.wait(1)
        safe(function()
            if not infoRow.Parent then return end
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                healthLabel.Text = math.floor(hum.Health).." / "..math.floor(hum.MaxHealth)
                speedLabel.Text = tostring(math.floor(hum.WalkSpeed))
            else healthLabel.Text = "-" speedLabel.Text = "-" end
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                posLabel.Text = string.format("%d, %d, %d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z))
            else posLabel.Text = "-" end
            playersLabel.Text = #Players:GetPlayers().." 人"
            local ok, ping = pcall(function() return math.floor(player:GetNetworkPing() * 1000) end)
            pingLabel.Text = ok and (ping.." ms") or "-"
            local elapsed = math.floor(tick() - joinTime)
            local m = math.floor(elapsed / 60); local s = elapsed % 60
            playTimeLabel.Text = m.." 分 "..s.." 秒"
        end)
    end
end)

safe(function() tabs["内测人员"].button.MouseButton1Click:Fire() end)
