local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local NewUIUrl = "https://raw.githubusercontent.com/sdxs221/sd/main/Newui"
local success, code = pcall(function() return game:HttpGet(NewUIUrl) end)

if success and code then
    local Library = loadstring(code)()
    local Window = Library.CreateWindow("神脚本")
    Window.FloatBall.Image = "rbxassetid://100987077383366"

    local lp = Players.LocalPlayer
    local injector = identifyexecutor and identifyexecutor() or "未知注入器"
    local accountDay = lp.AccountAge
    local uid = lp.UserId
    local uname = lp.Name
    local serverId = game.JobId

    local showUserInfo, userInfoGui = false, nil
    local playerNotifyEnabled, playerJoinConn, playerLeaveConn = false, nil, nil
    local showFps, fpsGui, fpsLabel, fpsLoopConn = false, nil, nil, nil
    local antiAfkOn, antiAfkLoop = false, nil
    local rotateSpeed, rotateLoop = 0, nil
    local walkSpeed, jumpPower, fovValue, gravityVal = 16, 50, 70, 196.2

    local showPosHp, posHpFolder, posHpConn = false, nil, nil
    if CoreGui:FindFirstChild("PosHpTags") then CoreGui.PosHpTags:Destroy() end
    posHpFolder = Instance.new("Folder")
    posHpFolder.Name = "PosHpTags"
    posHpFolder.Parent = CoreGui

    local infiniteJump, infJumpConn = false, nil
    local phaseThrough, phaseConn = false, nil
    local kongFlyLoader = nil
    local headTagGui = nil
    local headTagEnabled = false

    local nightVisionOn = false
    local noFogOn = false
    local nvOldAmbient, nvOldOutdoor, nvOldBrightness = nil, nil, nil
    local nvOldAtmoDensity, nvOldAtmoHaze = nil, nil
    local fogOldEnd, fogOldStart, fogOldColor = nil, nil, nil
    local fogOldAtmoDensity, fogOldAtmoHaze = nil, nil

    local function applyHumanoidSettings()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.PlatformStand then return end
        hum.WalkSpeed = walkSpeed
        hum.JumpPower = jumpPower
    end

    local function ToggleInfiniteJump(state)
        infiniteJump = state
        if infJumpConn then infJumpConn:Disconnect() end
        if state then
            infJumpConn = UserInputService.JumpRequest:Connect(function()
                local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
    end

    local function TogglePhaseThrough(state)
        phaseThrough = state
        if phaseConn then phaseConn:Disconnect() phaseConn = nil end
        if state then
            phaseConn = RunService.RenderStepped:Connect(function()
                local c = lp.Character
                if c then
                    for _,part in ipairs(c:GetChildren()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
            end)
        else
            local c = lp.Character
            if c then
                for _,part in ipairs(c:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end

    local function CreateHeadTag()
        local char = lp.Character
        if not char then return end
        local head = char:FindFirstChild("Head")
        if not head then return end
        if headTagGui then headTagGui:Destroy() end
        headTagGui = Instance.new("BillboardGui")
        headTagGui.Name = "HeadTag"
        headTagGui.Size = UDim2.new(0, 200, 0, 50)
        headTagGui.StudsOffset = Vector3.new(0, 2.5, 0)
        headTagGui.AlwaysOnTop = true
        headTagGui.Adornee = head
        headTagGui.Parent = head
        local lab = Instance.new("TextLabel")
        lab.Size = UDim2.new(1, 0, 1, 0)
        lab.BackgroundTransparency = 1
        lab.Text = "神脚本用户"
        lab.TextColor3 = Color3.fromRGB(0, 255, 120)
        lab.TextStrokeTransparency = 0
        lab.Font = Enum.Font.SourceSansBold
        lab.TextScaled = true
        lab.Parent = headTagGui
    end

    local function DestroyHeadTag()
        if headTagGui then headTagGui:Destroy() headTagGui = nil end
    end

    local function ToggleHeadTag(state)
        headTagEnabled = state
        if state then CreateHeadTag() else DestroyHeadTag() end
    end

    local function UpdatePosHp()
        local localChar = lp.Character
        if not localChar then return end
        local localHrp = localChar:FindFirstChild("HumanoidRootPart")
        if not localHrp then return end
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                local char = plr.Character
                local tag = posHpFolder:FindFirstChild(plr.Name.."_poshp")
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        if showPosHp then
                            if not tag then
                                local bill = Instance.new("BillboardGui")
                                bill.Name = plr.Name.."_poshp"
                                bill.AlwaysOnTop = true
                                bill.Size = UDim2.new(6,0,2.2,0)
                                bill.StudsOffset = Vector3.new(0,4.5,0)
                                bill.Adornee = hrp
                                local lab = Instance.new("TextLabel")
                                lab.BackgroundTransparency = 1
                                lab.TextColor3 = Color3.new(0,1,0)
                                lab.Font = Enum.Font.SourceSansBold
                                lab.TextSize = 13
                                lab.Size = UDim2.new(1,0,1,0)
                                lab.Parent = bill
                                bill.Parent = posHpFolder
                            end
                            local lab = posHpFolder[plr.Name.."_poshp"]:FindFirstChildWhichIsA("TextLabel")
                            local dist = math.floor((localHrp.Position - hrp.Position).Magnitude)
                            lab.Text = string.format("%s\n距离:%d\nX:%.0f Y:%.0f Z:%.0f",
                                plr.Name, dist, hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
                        else
                            if tag then tag:Destroy() end
                        end
                    else
                        if tag then tag:Destroy() end
                    end
                else
                    if tag then tag:Destroy() end
                end
            end
        end
    end

    local function TogglePosHpTag(state)
        showPosHp = state
        if posHpConn then posHpConn:Disconnect() posHpConn = nil end
        if not state then
            for _,v in ipairs(posHpFolder:GetChildren()) do v:Destroy() end
            return
        end
        posHpConn = RunService.RenderStepped:Connect(UpdatePosHp)
    end

    local function ToggleKongFly(state)
        if state then
            kongFlyLoader = loadstring(game:HttpGet("https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/fly.lua"))()
        else
            warn("恐飞行远程脚本无法直接关闭，需要重生角色或者重进服务器关闭")
        end
    end

    local function DestroyUserInfoPopup()
        if userInfoGui then userInfoGui:Destroy() userInfoGui = nil end
    end

    local function CreateUserInfoPopup()
        DestroyUserInfoPopup()
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "UserInfoPopup"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = lp.PlayerGui
        local TextLabel = Instance.new("TextLabel")
        TextLabel.Size = UDim2.new(0, 340, 0, 110)
        TextLabel.Position = UDim2.new(0.72, 0, 0.04, 0)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Font = Enum.Font.SourceSansBold
        TextLabel.TextSize = 18
        TextLabel.TextColor3 = Color3.new(1,1,1)
        TextLabel.Text = "欢迎使用神脚本\n"..uname.."\nID："..tostring(uid)
        TextLabel.ZIndex = 100
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left
        TextLabel.Parent = ScreenGui
        userInfoGui = ScreenGui
    end

    local function createNotifyText(msg)
        local sg = Instance.new("ScreenGui")
        sg.Parent = lp.PlayerGui
        sg.Name = "PlayerNotify"
        local lb = Instance.new("TextLabel")
        lb.Size = UDim2.new(0,320,0,70)
        lb.Position = UDim2.new(0.02,0,0.75,0)
        lb.BackgroundTransparency = 0.3
        lb.BackgroundColor3 = Color3.new(0,0,0)
        lb.TextColor3 = Color3.new(1,1,1)
        lb.Font = Enum.Font.SourceSansBold
        lb.TextSize = 16
        lb.Text = msg
        lb.Parent = sg
        task.wait(3)
        sg:Destroy()
    end

    local function TogglePlayerNotify(state)
        playerNotifyEnabled = state
        if state then
            playerJoinConn = Players.PlayerAdded:Connect(function(plr)
                createNotifyText("✅玩家进入："..plr.Name)
            end)
            playerLeaveConn = Players.PlayerRemoving:Connect(function(plr)
                createNotifyText("❌玩家离开："..plr.Name)
            end)
        else
            if playerJoinConn then playerJoinConn:Disconnect() end
            if playerLeaveConn then playerLeaveConn:Disconnect() end
        end
    end

    local function ToggleFpsDisplay(state)
        showFps = state
        if state then
            if fpsGui then fpsGui:Destroy() end
            fpsGui = Instance.new("ScreenGui")
            fpsGui.Name = "FpsGui"
            fpsGui.ResetOnSpawn = false
            fpsGui.Parent = lp.PlayerGui
            fpsLabel = Instance.new("TextLabel")
            fpsLabel.Size = UDim2.new(0,120,0,35)
            fpsLabel.Position = UDim2.new(0.5,0,0,0)
            fpsLabel.AnchorPoint = Vector2.new(0.5,0)
            fpsLabel.BackgroundTransparency = 1
            fpsLabel.TextColor3 = Color3.new(1,1,1)
            fpsLabel.Font = Enum.Font.SourceSansBold
            fpsLabel.TextSize = 17
            fpsLabel.TextXAlignment = Enum.TextXAlignment.Center
            fpsLabel.Parent = fpsGui
            fpsLoopConn = task.spawn(function()
                local last, frames = os.clock(), 0
                while showFps do
                    frames += 1
                    local now = os.clock()
                    if now - last >= 1 then
                        fpsLabel.Text = "FPS: "..tostring(frames)
                        frames, last = 0, os.clock()
                    end
                    task.wait()
                end
            end)
        else
            showFps = false
            if fpsLoopConn then task.cancel(fpsLoopConn) end
            if fpsGui then fpsGui:Destroy() fpsGui = nil end
        end
    end

    local function ToggleAntiAfk(state)
        antiAfkOn = state
        if state then
            antiAfkLoop = task.spawn(function()
                while antiAfkOn do
                    task.wait(4)
                    local char = lp.Character
                    if char and char:FindFirstChild("Humanoid") then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame *= CFrame.Angles(0, math.rad(1),0) end
                    end
                end
            end)
        else
            antiAfkOn = false
            if antiAfkLoop then task.cancel(antiAfkLoop) end
        end
    end

    local function StartRotate()
        if rotateLoop then task.cancel(rotateLoop) rotateLoop = nil end
        if rotateSpeed <= 0 then return end
        rotateLoop = task.spawn(function()
            while rotateSpeed > 0 do
                task.wait()
                local char = lp.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum and not hum.PlatformStand then
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then hrp.CFrame *= CFrame.Angles(0, math.rad(rotateSpeed/10),0) end
                    end
                end
            end
        end)
    end

    local function SetWalkSpeed(v)
        walkSpeed = v
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and not hum.PlatformStand then hum.WalkSpeed = walkSpeed end
        end
    end

    local function SetJumpPower(v)
        jumpPower = v
        local char = lp.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and not hum.PlatformStand then hum.JumpPower = jumpPower end
        end
    end

    local function SetFOV(v) fovValue = v workspace.CurrentCamera.FieldOfView = fovValue end
    local function SetGravity(v) gravityVal = v workspace.Gravity = gravityVal end

    local function ToggleNightVision(state)
        nightVisionOn = state
        if state then
            nvOldAmbient = Lighting.Ambient
            nvOldOutdoor = Lighting.OutdoorAmbient
            nvOldBrightness = Lighting.Brightness
            Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
            Lighting.Brightness = 3
            local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmo then
                nvOldAtmoDensity = atmo.Density
                nvOldAtmoHaze = atmo.Haze
                atmo.Density = 0
                atmo.Haze = 0
            end
        else
            if nvOldAmbient then Lighting.Ambient = nvOldAmbient end
            if nvOldOutdoor then Lighting.OutdoorAmbient = nvOldOutdoor end
            if nvOldBrightness then Lighting.Brightness = nvOldBrightness end
            local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmo and nvOldAtmoDensity then atmo.Density = nvOldAtmoDensity end
            if atmo and nvOldAtmoHaze then atmo.Haze = nvOldAtmoHaze end
        end
    end

    local function ToggleNoFog(state)
        noFogOn = state
        if state then
            fogOldEnd = Lighting.FogEnd
            fogOldStart = Lighting.FogStart
            fogOldColor = Lighting.FogColor
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
            local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmo then
                fogOldAtmoDensity = atmo.Density
                fogOldAtmoHaze = atmo.Haze
                atmo.Density = 0
                atmo.Haze = 0
            end
        else
            if fogOldEnd then Lighting.FogEnd = fogOldEnd end
            if fogOldStart then Lighting.FogStart = fogOldStart end
            if fogOldColor then Lighting.FogColor = fogOldColor end
            local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
            if atmo and fogOldAtmoDensity then atmo.Density = fogOldAtmoDensity end
            if atmo and fogOldAtmoHaze then atmo.Haze = fogOldAtmoHaze end
        end
    end

    lp.CharacterAdded:Connect(function()
        task.wait(0.15)
        applyHumanoidSettings()
        if infiniteJump then ToggleInfiniteJump(true) end
        if phaseThrough then TogglePhaseThrough(true) end
    end)

    local Tab1 = Window:CreateTab("信息")
    Tab1:AddButton("你的注入器:"..injector, function() end)
    Tab1:AddButton("你的账号年龄:"..tostring(accountDay).."天", function() end)
    Tab1:AddButton("您的用户ID:"..tostring(uid), function() end)
    Tab1:AddButton("您的用户名:"..uname, function() end)
    Tab1:AddButton("您当前服务器的ID:"..serverId, function() end)
    Tab1:AddButton("神脚本作者快手号：5733022742", function() end)
    Tab1:AddSwitch("显示用户信息",function(state)
        showUserInfo = state
        if state then CreateUserInfoPopup() else DestroyUserInfoPopup() end
    end)
    Tab1:AddSwitch("玩家进出服务器通知",function(state) TogglePlayerNotify(state) end)
    Tab1:AddSwitch("显示当前FPS(帧率)",function(state) ToggleFpsDisplay(state) end)
    Tab1:AddSwitch("防挂机20分钟被踢",function(state) ToggleAntiAfk(state) end)
    Tab1:AddSwitch("头顶文字", function(state) ToggleHeadTag(state) end)

    local Tab2 = Window:CreateTab("通用")
    Tab2:AddSlider("原地旋转速度",0,3000,0,function(val) rotateSpeed = val StartRotate() end)
    Tab2:AddSlider("人物移动速度",16,200,16,function(val) SetWalkSpeed(val) end)
    Tab2:AddSlider("跳跃高度",50,300,50,function(val) SetJumpPower(val) end)
    Tab2:AddSlider("广角FOV",70,120,70,function(val) SetFOV(val) end)
    Tab2:AddSlider("重力调节",50,400,196.2,function(val) SetGravity(val) end)
    Tab2:AddSwitch("显示人物位置和血量",function(state) TogglePosHpTag(state) end)
    Tab2:AddSwitch("无限跳跃",function(state) ToggleInfiniteJump(state) end)
    Tab2:AddSwitch("穿墙",function(state) TogglePhaseThrough(state) end)
    Tab2:AddSwitch("夜视",function(state) ToggleNightVision(state) end)
    Tab2:AddSwitch("除雾",function(state) ToggleNoFog(state) end)

    local tracersOn = false
    local tracerGui = nil
    local tracerFolder = nil
    local tracerConn = nil
    local tracerAddConn = nil
    local tracerRemoveConn = nil
    local tracerConfig = {
        Color = Color3.fromRGB(255, 40, 40),
        Thickness = 1.5,
        StartFromTop = true,
        ShowOffscreen = true,
        MaxDistance = 2000,
        TargetPart = "Head",
        Transparency = 0,
    }
    local function GetTracerTargetPosition(plr)
        local char = plr.Character
        if not char or not char.Parent then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then return nil end
        local part = char:FindFirstChild(tracerConfig.TargetPart) or char:FindFirstChild("HumanoidRootPart")
        return part and part.Position or nil
    end
    local function CreateTracerLine(name)
        if not tracerFolder then return nil end
        local existing = tracerFolder:FindFirstChild(name)
        if existing then return existing end
        local line = Instance.new("Frame")
        line.Name = name
        line.BackgroundColor3 = tracerConfig.Color
        line.BackgroundTransparency = tracerConfig.Transparency
        line.BorderSizePixel = 0
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.Visible = false
        line.ZIndex = 5
        line.Parent = tracerFolder
        local stroke = Instance.new("UIStroke")
        stroke.Name = "Stroke"
        stroke.Color = tracerConfig.Color
        stroke.Thickness = 0
        stroke.Transparency = tracerConfig.Transparency
        stroke.Parent = line
        return line
    end
    local function ClampToViewport(pos, viewport)
        local x = math.clamp(pos.X, 0, viewport.X)
        local y = math.clamp(pos.Y, 0, viewport.Y)
        return Vector2.new(x, y)
    end
    local function UpdateTracer()
        if not tracersOn or not tracerFolder then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local viewport = cam.ViewportSize
        local startPos
        if tracerConfig.StartFromTop then
            startPos = Vector2.new(viewport.X / 2, 0)
        else
            startPos = Vector2.new(viewport.X / 2, viewport.Y / 2)
        end
        local myChar = lp.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local activeNames = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then
                activeNames[plr.Name] = true
                local line = tracerFolder:FindFirstChild(plr.Name)
                if not line then line = CreateTracerLine(plr.Name) end
                if line then
                    local worldPos = GetTracerTargetPosition(plr)
                    local shouldShow = worldPos ~= nil
                    if shouldShow and myHrp and tracerConfig.MaxDistance > 0 then
                        local dist = (myHrp.Position - worldPos).Magnitude
                        if dist > tracerConfig.MaxDistance then shouldShow = false end
                    end
                    if shouldShow then
                        local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
                        if screenPos.Z <= 0 then shouldShow = false end
                        if shouldShow then
                            local endPos
                            if onScreen then
                                endPos = Vector2.new(screenPos.X, screenPos.Y)
                            elseif tracerConfig.ShowOffscreen then
                                endPos = ClampToViewport(Vector2.new(screenPos.X, screenPos.Y), viewport)
                            else
                                shouldShow = false
                            end
                            if shouldShow then
                                local delta = endPos - startPos
                                local length = delta.Magnitude
                                if length > 1 then
                                    local midPos = (startPos + endPos) / 2
                                    local angle = math.deg(math.atan2(delta.Y, delta.X))
                                    line.Position = UDim2.new(0, midPos.X, 0, midPos.Y)
                                    line.Size = UDim2.new(0, length, 0, tracerConfig.Thickness)
                                    line.Rotation = angle
                                    line.Visible = true
                                else
                                    line.Visible = false
                                end
                            end
                        end
                    end
                    if not shouldShow and line then line.Visible = false end
                end
            end
        end
        for _, child in ipairs(tracerFolder:GetChildren()) do
            if not activeNames[child.Name] then child:Destroy() end
        end
    end
    local function ToggleTracer(state)
        tracersOn = state
        if tracerConn then tracerConn:Disconnect() tracerConn = nil end
        if tracerAddConn then tracerAddConn:Disconnect() tracerAddConn = nil end
        if tracerRemoveConn then tracerRemoveConn:Disconnect() tracerRemoveConn = nil end
        if not state then
            if tracerGui then tracerGui:Destroy() tracerGui = nil end
            tracerFolder = nil
            return
        end
        if tracerGui then tracerGui:Destroy() end
        tracerGui = Instance.new("ScreenGui")
        tracerGui.Name = "TracerGui"
        tracerGui.ResetOnSpawn = false
        tracerGui.IgnoreGuiInset = true
        tracerGui.Parent = lp.PlayerGui
        tracerFolder = Instance.new("Folder")
        tracerFolder.Name = "Tracers"
        tracerFolder.Parent = tracerGui
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then CreateTracerLine(plr.Name) end
        end
        tracerAddConn = Players.PlayerAdded:Connect(function(plr)
            if tracersOn and plr ~= lp then CreateTracerLine(plr.Name) end
        end)
        tracerRemoveConn = Players.PlayerRemoving:Connect(function(plr)
            if tracerFolder then
                local line = tracerFolder:FindFirstChild(plr.Name)
                if line then line:Destroy() end
            end
        end)
        tracerConn = RunService.RenderStepped:Connect(UpdateTracer)
    end
    Tab2:AddSwitch("天线透视", function(state) ToggleTracer(state) end)

    local espOn = false
    local espGui = nil
    local espFolder = nil
    local espConn = nil
    local function CreateESPForPlayer(plr)
        if not espFolder then return end
        if espFolder:FindFirstChild(plr.Name) then return end
        local box = Instance.new("Frame")
        box.Name = plr.Name
        box.BackgroundTransparency = 1
        box.BorderSizePixel = 0
        box.Visible = false
        box.Parent = espFolder
        local stroke = Instance.new("UIStroke")
        stroke.Name = "Stroke"
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Thickness = 1.5
        stroke.Parent = box
        local info = Instance.new("TextLabel")
        info.Name = "Info"
        info.BackgroundTransparency = 1
        info.TextColor3 = Color3.fromRGB(255, 255, 255)
        info.TextStrokeTransparency = 0
        info.Font = Enum.Font.SourceSansBold
        info.TextSize = 12
        info.TextXAlignment = Enum.TextXAlignment.Center
        info.Parent = box
        info.AnchorPoint = Vector2.new(0.5, 1)
        info.Position = UDim2.new(0.5, 0, 0, -3)
        info.Size = UDim2.new(0, 200, 0, 40)
    end
    local function ToggleESP(state)
        espOn = state
        if espConn then espConn:Disconnect() espConn = nil end
        if not state then
            if espGui then espGui:Destroy() espGui = nil end
            espFolder = nil
            return
        end
        if espGui then espGui:Destroy() end
        espGui = Instance.new("ScreenGui")
        espGui.Name = "EspGui"
        espGui.ResetOnSpawn = false
        espGui.IgnoreGuiInset = true
        espGui.Parent = lp.PlayerGui
        espFolder = Instance.new("Folder")
        espFolder.Name = "Boxes"
        espFolder.Parent = espGui
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp then CreateESPForPlayer(plr) end
        end
        Players.PlayerAdded:Connect(function(plr)
            if espOn and plr ~= lp then CreateESPForPlayer(plr) end
        end)
        Players.PlayerRemoving:Connect(function(plr)
            if espFolder then
                local box = espFolder:FindFirstChild(plr.Name)
                if box then box:Destroy() end
            end
        end)
        espConn = RunService.RenderStepped:Connect(function()
            if not espOn or not espFolder then return end
            local cam = workspace.CurrentCamera
            local char = lp.Character
            if not char then return end
            local myHrp = char:FindFirstChild("HumanoidRootPart")
            if not myHrp then return end
            local aliveNames = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp then
                    aliveNames[plr.Name] = true
                    local box = espFolder:FindFirstChild(plr.Name)
                    if not box then
                        CreateESPForPlayer(plr)
                        box = espFolder:FindFirstChild(plr.Name)
                    end
                    if box then
                        local pChar = plr.Character
                        local valid = false
                        if pChar and pChar.Parent then
                            local hrp = pChar:FindFirstChild("HumanoidRootPart")
                            local hum = pChar:FindFirstChildOfClass("Humanoid")
                            local head = pChar:FindFirstChild("Head")
                            if hrp and hum and head and hum.Health > 0 then
                                local headPos, onScreen1 = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                                local footPos, onScreen2 = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                                if (onScreen1 or onScreen2) and headPos.Z > 0 then
                                    local height = math.abs(headPos.Y - footPos.Y)
                                    local width = height * 0.6
                                    if height > 0 and height < 2000 then
                                        local topLeftX = headPos.X - width / 2
                                        local topLeftY = headPos.Y
                                        box.Position = UDim2.new(0, topLeftX, 0, topLeftY)
                                        box.Size = UDim2.new(0, width, 0, height)
                                        local dist = math.floor((myHrp.Position - hrp.Position).Magnitude)
                                        local hp = math.floor(hum.Health)
                                        local maxHp = math.floor(hum.MaxHealth)
                                        local info = box:FindFirstChild("Info")
                                        if info then
                                            info.Text = string.format("%s\n%d/%d\n距离:%d", plr.Name, hp, maxHp, dist)
                                        end
                                        box.Visible = true
                                        valid = true
                                    end
                                end
                            end
                        end
                        if not valid then box.Visible = false end
                    end
                end
            end
            for _, child in ipairs(espFolder:GetChildren()) do
                if not aliveNames[child.Name] then child:Destroy() end
            end
        end)
    end
    Tab2:AddSwitch("ESP透视", function(state) ToggleESP(state) end)    local Tab3 = Window:CreateTab("飞行")
    Tab3:AddSwitch("恐飞行",function(state) ToggleKongFly(state) end)
    Tab3:AddSwitch("柳叶飞行",function(state)
        if state then
            loadstring(game:HttpGet("https://raw.githubusercontent.com/krlpl/er/refs/heads/main/GB%C3%BD%C3%BD%C3%BD%C3%BD-obfuscated.lua"))()
        end
    end)
    Tab3:AddSwitch("坐标飞",function(state)
        if state then
            local TweenService = game:GetService("TweenService")
            local camera = workspace.CurrentCamera
            local pgui = lp:WaitForChild("PlayerGui")
            local mt = getrawmetatable(game)
            local old = mt.__namecall
            setreadonly(mt, false)
            mt.__namecall = newcclosure(function(self, ...)
                if getnamecallmethod() == "FireServer" and tostring(self) == "ForceSelfDamage" then return nil end
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
            Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
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
                if input == dragInput and dragging then
                    local delta = input.Position - dragStart
                    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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
                    local moveVec = ControlModule:GetMoveVector()
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
                if isFlying then startFly() else
                    if flightConnection then flightConnection:Disconnect() flightConnection = nil end
                    local char = lp.Character
                    if char then
                        local hum = char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.AutoRotate = true end
                        local animate = char:FindFirstChild("Animate")
                        if animCache and not animate then animCache.Parent = char animCache = nil end
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
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.AutoRotate = true end
                    local animate = char:FindFirstChild("Animate")
                    if animCache and not animate then animCache.Parent = char end
                end
                ScreenGui:Destroy()
            end)
            topBtn("-", -60, Color3.fromRGB(70, 70, 70), function()
                local isCollapsed = MainFrame.Size.Y.Offset < 140
                local targetH = isCollapsed and 140 or 35
                TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 180, 0, targetH)}):Play()
                Toggle.Visible, SpeedInput.Visible = isCollapsed, isCollapsed
            end)
            MainFrame.Size = UDim2.new(0, 0, 0, 0)
            MainFrame:TweenSize(UDim2.new(0, 180, 0, 140), "Out", "Back", 0.5)
        end
    end)

    local Tab4 = Window:CreateTab("自瞄")
    local AimbotEnabled = false
    local FovRadius = 0
    local AimbotPercent = 0
    local AimbotTargetPart = "Head"
    local AimbotWallCheck = false
    local AimbotCrosshairMode = false
    local AimbotLoopConn = nil
    local fovGui, fovCircleFrame = nil, nil
    local function CreateFovGui()
        if fovGui then return end
        fovGui = Instance.new("ScreenGui")
        fovGui.Name = "AimFovCircleGui"
        fovGui.IgnoreGuiInset = true
        fovGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        fovGui.Parent = CoreGui
        fovCircleFrame = Instance.new("Frame")
        fovCircleFrame.Name = "FOVCircle"
        fovCircleFrame.AnchorPoint = Vector2.new(0.5,0.5)
        fovCircleFrame.Position = UDim2.new(0.5,0,0.5,0)
        fovCircleFrame.BackgroundTransparency = 1
        fovCircleFrame.BorderSizePixel = 0
        fovCircleFrame.Visible = false
        fovCircleFrame.ZIndex = 99
        fovCircleFrame.Parent = fovGui
        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1,0)
        uiCorner.Parent = fovCircleFrame
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Color = Color3.new(1,1,1)
        uiStroke.Thickness = 2
        uiStroke.Transparency = 0.7
        uiStroke.Parent = fovCircleFrame
        task.spawn(function()
            local hue = 0
            while task.wait(0.03) do
                if not fovCircleFrame or not uiStroke:IsDescendantOf(game) then break end
                hue = hue + 0.01
                if hue > 1 then hue = 0 end
                uiStroke.Color = Color3.fromHSV(hue,1,1)
            end
        end)
    end
    CreateFovGui()
    local function UpdateFovCircleSize(radius)
        if not fovCircleFrame then return end
        fovCircleFrame.Size = UDim2.new(0, radius*2, 0, radius*2)
    end
    Tab4:AddSwitch("自瞄",function(state)
        AimbotEnabled = state
        if AimbotLoopConn then AimbotLoopConn:Disconnect() AimbotLoopConn = nil end
        if state then
            AimbotLoopConn = RunService.RenderStepped:Connect(function()
                if not AimbotEnabled then return end
                local cam = workspace.CurrentCamera
                local localChar = lp.Character
                if not localChar then return end
                local localHrp = localChar:FindFirstChild("HumanoidRootPart")
                if not localHrp then return end
                local closestPart = nil
                local minScreenDist = math.huge
                for _,plr in ipairs(Players:GetPlayers()) do
                    if plr ~= lp then
                        local char = plr.Character
                        if char then
                            local targetPart = char:FindFirstChild(AimbotTargetPart)
                            if targetPart then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    local screenPos, onScreen = cam:WorldToViewportPoint(targetPart.Position)
                                    if onScreen then
                                        local screenDist = ((screenPos.X - cam.ViewportSize.X/2)^2 + (screenPos.Y - cam.ViewportSize.Y/2)^2)^0.5
                                        local inRange = true
                                        if not AimbotCrosshairMode then
                                            inRange = (screenDist < FovRadius)
                                        end
                                        if inRange and screenDist < minScreenDist then
                                            local canAim = true
                                            if AimbotWallCheck then
                                                local rp = RaycastParams.new()
                                                rp.FilterType = Enum.RaycastFilterType.Exclude
                                                rp.IgnoreWater = true
                                                rp.FilterDescendantsInstances = {localChar, char}
                                                local ray = workspace:Raycast(cam.CFrame.Position, targetPart.Position - cam.CFrame.Position, rp)
                                                if ray ~= nil then canAim = false end
                                            end
                                            if canAim then
                                                minScreenDist = screenDist
                                                closestPart = targetPart
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
                if closestPart then
                    local targetCF = CFrame.new(cam.CFrame.Position, closestPart.Position)
                    cam.CFrame = cam.CFrame:Lerp(targetCF, AimbotPercent / 100)
                end
            end)
        end
    end)
    Tab4:AddSlider("FOV圈大小",0,400,0,function(val)
        FovRadius = val
        UpdateFovCircleSize(val)
    end)
    Tab4:AddSlider("自瞄吸附强度",0,100,0,function(val) AimbotPercent = val end)
    Tab4:AddSwitch("显示FOV彩虹圈",function(state)
        if fovCircleFrame then fovCircleFrame.Visible = state end
    end)
    Tab4:AddSwitch("墙体检测",function(state) AimbotWallCheck = state end)
    Tab4:AddSwitch("漏哪打哪(准星最近)",function(state) AimbotCrosshairMode = state end)
    Tab4:AddSwitch("锁头部",function(state)
        if state then AimbotTargetPart = "Head" end
    end)
    Tab4:AddSwitch("锁躯干",function(state)
        if state then AimbotTargetPart = "UpperTorso" end
    end)

    -- ==================== 范围 Tab5 ====================
    local Tab5 = Window:CreateTab("范围")
    local HitboxEnabled = false
    local HitboxSize = 10
    local HitboxConn = nil
    local originalSizes = {}

    local colorList = {
        Color3.fromRGB(0, 100, 255),
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(255, 128, 0),
    }
    local colorIndex = 1
    local hitboxColor = colorList[colorIndex]
    local hitboxColorDepth = 0.5
    local rainbowOn = false
    local rainbowConn = nil

    local function ApplyHitbox()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    if not originalSizes[hrp] then
                        originalSizes[hrp] = {Size = hrp.Size, Transparency = hrp.Transparency, Color = hrp.Color, Material = hrp.Material}
                    end
                    hrp.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    hrp.Color = hitboxColor
                    hrp.Transparency = 1 - hitboxColorDepth
                    hrp.Material = Enum.Material.ForceField
                    hrp.CanCollide = false
                end
            end
        end
    end

    local function RestoreHitbox()
        for hrp, data in pairs(originalSizes) do
            pcall(function()
                if hrp and hrp.Parent then
                    hrp.Size = data.Size
                    hrp.Transparency = data.Transparency
                    hrp.Color = data.Color
                    hrp.Material = data.Material
                end
            end)
        end
        originalSizes = {}
    end

    Tab5:AddSwitch("范围(碰撞箱)", function(state)
        HitboxEnabled = state
        if HitboxConn then HitboxConn:Disconnect() HitboxConn = nil end
        if state then
            HitboxConn = RunService.Heartbeat:Connect(function()
                if not HitboxEnabled then return end
                ApplyHitbox()
            end)
        else
            RestoreHitbox()
        end
    end)

    Tab5:AddSlider("范围大小", 1, 200, 10, function(val)
        HitboxSize = val
    end)

    Tab5:AddButton("切换颜色", function()
        colorIndex = colorIndex + 1
        if colorIndex > #colorList then colorIndex = 1 end
        hitboxColor = colorList[colorIndex]
    end)

    Tab5:AddButton("彩虹循环(点击开关)", function()
        rainbowOn = not rainbowOn
        if rainbowConn then task.cancel(rainbowConn) rainbowConn = nil end
        if rainbowOn then
            rainbowConn = task.spawn(function()
                local hue = 0
                while rainbowOn do
                    hue = (hue + 0.01) % 1
                    hitboxColor = Color3.fromHSV(hue, 1, 1)
                    task.wait(0.05)
                end
            end)
        end
    end)

    Tab5:AddSlider("颜色深度(越大越不透明)", 0, 100, 50, function(val)
        hitboxColorDepth = val / 100
    end)

    -- ==================== FE Tab6 ====================
    local Tab6 = Window:CreateTab("FE")

    Tab6:AddSwitch("机器人跳舞", function(state)
        if state then
            local AnimationId = "248263260"
            local Anim = Instance.new("Animation")
            Anim.AnimationId = "rbxassetid://"..AnimationId
            local k = game.Players.LocalPlayer.Character.Humanoid:LoadAnimation(Anim)
            k:Play()
            k:AdjustSpeed(1)
        end
    end)

    Tab6:AddSwitch("酷小孩", function(state)
        if state then
            loadstring(game:GetObjects("rbxassetid://8127297852")[1].Source)()
        end
    end)

    Tab6:AddSwitch("挥拳动作", function(state)
        if state then
            local char = lp.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://218504594"
                local track = hum:LoadAnimation(anim)
                track.Looped = true
                track:Play()
                _G._punchTrack = track
            end
        else
            if _G._punchTrack then _G._punchTrack:Stop() _G._punchTrack = nil end
        end
    end)

    Tab6:AddSwitch("滑稽舞步", function(state)
        if state then
            local char = lp.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://507771019"
                local track = hum:LoadAnimation(anim)
                track.Looped = true
                track:Play()
                _G._funnyTrack = track
            end
        else
            if _G._funnyTrack then _G._funnyTrack:Stop() _G._funnyTrack = nil end
        end
    end)

    Tab6:AddSwitch("迪斯科舞", function(state)
        if state then
            local char = lp.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://507771955"
                local track = hum:LoadAnimation(anim)
                track.Looped = true
                track:Play()
                _G._discoTrack = track
            end
        else
            if _G._discoTrack then _G._discoTrack:Stop() _G._discoTrack = nil end
        end
    end)

    Tab6:AddButton("停止所有动作", function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        for _, t in ipairs(hum:GetPlayingAnimationTracks()) do
            t:Stop()
        end
    end)

    Tab6:AddButton("🤸 倒立行走", function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.HipHeight = -2.5
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    Tab6:AddButton("🕺 复位姿态", function()
        local char = lp.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.HipHeight = 0 end
    end)

    local selfHighlight = nil
    Tab6:AddSwitch("人物发光", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            if selfHighlight then selfHighlight:Destroy() end
            selfHighlight = Instance.new("Highlight")
            selfHighlight.Name = "SelfHighlight"
            selfHighlight.FillColor = Color3.fromRGB(0, 170, 255)
            selfHighlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            selfHighlight.FillTransparency = 0.5
            selfHighlight.OutlineTransparency = 0
            selfHighlight.Adornee = char
            selfHighlight.Parent = char
        else
            if selfHighlight then selfHighlight:Destroy() selfHighlight = nil end
        end
    end)

    local rainbowHighlight = nil
    Tab6:AddSwitch("彩虹发光", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            if rainbowHighlight then rainbowHighlight:Destroy() end
            rainbowHighlight = Instance.new("Highlight")
            rainbowHighlight.OutlineColor = Color3.new(1,1,1)
            rainbowHighlight.FillTransparency = 0.4
            rainbowHighlight.Adornee = char
            rainbowHighlight.Parent = char
            task.spawn(function()
                local hue = 0
                while rainbowHighlight and rainbowHighlight.Parent do
                    hue = (hue + 0.01) % 1
                    rainbowHighlight.FillColor = Color3.fromHSV(hue, 1, 1)
                    task.wait(0.05)
                end
            end)
        else
            if rainbowHighlight then rainbowHighlight:Destroy() rainbowHighlight = nil end
        end
    end)

    local selfGlow = nil
    Tab6:AddSwitch("人物泛光", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            if selfGlow then selfGlow:Destroy() end
            selfGlow = Instance.new("PointLight")
            selfGlow.Brightness = 3
            selfGlow.Range = 15
            selfGlow.Color = Color3.fromRGB(255, 255, 255)
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then selfGlow.Parent = hrp end
        else
            if selfGlow then selfGlow:Destroy() selfGlow = nil end
        end
    end)

    local selfTrail = nil
    Tab6:AddSwitch("人物拖尾", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if selfTrail then selfTrail:Destroy() end
            local a0 = Instance.new("Attachment", hrp)
            local a1 = Instance.new("Attachment", hrp)
            a0.Position = Vector3.new(0, 1, 0)
            a1.Position = Vector3.new(0, -1, 0)
            selfTrail = Instance.new("Trail")
            selfTrail.Attachment0 = a0
            selfTrail.Attachment1 = a1
            selfTrail.Lifetime = 0.5
            selfTrail.Color = ColorSequence.new(Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 0, 255))
            selfTrail.Parent = hrp
            _G._trailAttachments = {a0, a1}
        else
            if selfTrail then selfTrail:Destroy() selfTrail = nil end
            if _G._trailAttachments then
                for _, a in ipairs(_G._trailAttachments) do a:Destroy() end
                _G._trailAttachments = nil
            end
        end
    end)

    local particleEmitter = nil
    Tab6:AddSwitch("粒子环绕", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if particleEmitter then particleEmitter:Destroy() end
            local att = Instance.new("Attachment", hrp)
            particleEmitter = Instance.new("ParticleEmitter")
            particleEmitter.Texture = "rbxassetid://243660364"
            particleEmitter.Rate = 50
            particleEmitter.Lifetime = NumberRange.new(1, 2)
            particleEmitter.Speed = NumberRange.new(2, 4)
            particleEmitter.SpreadAngle = Vector2.new(360, 360)
            particleEmitter.Size = NumberSequence.new(0.5)
            particleEmitter.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 0, 255))
            particleEmitter.Parent = att
            _G._particleAtt = att
        else
            if particleEmitter then particleEmitter:Destroy() particleEmitter = nil end
            if _G._particleAtt then _G._particleAtt:Destroy() _G._particleAtt = nil end
        end
    end)

    local fireEffect = nil
    Tab6:AddSwitch("火焰特效", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if fireEffect then fireEffect:Destroy() end
            fireEffect = Instance.new("Fire")
            fireEffect.Size = 5
            fireEffect.Heat = 10
            fireEffect.Color = Color3.fromRGB(255, 100, 0)
            fireEffect.SecondaryColor = Color3.fromRGB(255, 200, 0)
            fireEffect.Parent = hrp
        else
            if fireEffect then fireEffect:Destroy() fireEffect = nil end
        end
    end)

    local smokeEffect = nil
    Tab6:AddSwitch("烟雾特效", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if smokeEffect then smokeEffect:Destroy() end
            smokeEffect = Instance.new("Smoke")
            smokeEffect.Size = 5
            smokeEffect.RiseVelocity = 3
            smokeEffect.Color = Color3.fromRGB(200, 200, 200)
            smokeEffect.Parent = hrp
        else
            if smokeEffect then smokeEffect:Destroy() smokeEffect = nil end
        end
    end)

    local sparklesEffect = nil
    Tab6:AddSwitch("闪光粒子", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if sparklesEffect then sparklesEffect:Destroy() end
            sparklesEffect = Instance.new("Sparkles")
            sparklesEffect.SparkleColor = Color3.fromRGB(255, 255, 0)
            sparklesEffect.Parent = hrp
        else
            if sparklesEffect then sparklesEffect:Destroy() sparklesEffect = nil end
        end
    end)

    Tab6:AddSlider("人物透明度", 0, 100, 0, function(val)
        local char = lp.Character
        if not char then return end
        local transparency = val / 100
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.Transparency = transparency
            end
        end
    end)

    Tab6:AddSlider("人物泛光强度", 0, 20, 3, function(val)
        if selfGlow then selfGlow.Brightness = val end
    end)

    Tab6:AddSlider("拖尾长度", 1, 50, 5, function(val)
        if selfTrail then selfTrail.Lifetime = val / 10 end
    end)

    local headAccessory = nil
    Tab6:AddSwitch("头顶火焰冠", function(state)
        local char = lp.Character
        if state then
            if not char then return end
            local head = char:FindFirstChild("Head")
            if not head then return end
            if headAccessory then headAccessory:Destroy() end
            headAccessory = Instance.new("Fire")
            headAccessory.Size = 3
            headAccessory.Heat = 5
            headAccessory.Parent = head
        else
            if headAccessory then headAccessory:Destroy() headAccessory = nil end
        end
    end)

    Tab6:AddButton("视角拉近", function()
        workspace.CurrentCamera.FieldOfView = 30
    end)

    Tab6:AddButton("视角恢复正常", function()
        workspace.CurrentCamera.FieldOfView = 70
    end)

    Tab6:AddButton("视角拉远", function()
        workspace.CurrentCamera.FieldOfView = 120
    end)

    -- ==================== FPS Tab7 ====================
    local Tab7 = Window:CreateTab("fps")

    local fpsShowOn = false
    local fpsShowGui, fpsShowLabel, fpsShowConn = nil, nil, nil

    local function ToggleFpsShow(state)
        fpsShowOn = state
        if state then
            if fpsShowGui then fpsShowGui:Destroy() end
            fpsShowGui = Instance.new("ScreenGui")
            fpsShowGui.Name = "FpsDisplayTab7"
            fpsShowGui.ResetOnSpawn = false
            fpsShowGui.Parent = lp.PlayerGui

            fpsShowLabel = Instance.new("TextLabel")
            fpsShowLabel.Size = UDim2.new(0, 170, 0, 44)
            fpsShowLabel.Position = UDim2.new(0.5, -85, 0, 0)
            fpsShowLabel.BackgroundTransparency = 0.3
            fpsShowLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            fpsShowLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            fpsShowLabel.Font = Enum.Font.SourceSansBold
            fpsShowLabel.TextSize = 18
            fpsShowLabel.Text = "FPS: --"
            fpsShowLabel.Parent = fpsShowGui
            Instance.new("UICorner", fpsShowLabel).CornerRadius = UDim.new(0, 8)

            fpsShowConn = task.spawn(function()
                local last, frames = os.clock(), 0
                while fpsShowOn do
                    frames += 1
                    local now = os.clock()
                    if now - last >= 0.5 then
                        local fps = math.floor(frames / (now - last))
                        if fpsShowLabel then fpsShowLabel.Text = "FPS: "..tostring(fps) end
                        frames, last = 0, os.clock()
                    end
                    task.wait()
                end
            end)
        else
            if fpsShowConn then pcall(function() task.cancel(fpsShowConn) end) end
            if fpsShowGui then fpsShowGui:Destroy() fpsShowGui = nil end
        end
    end

    local function DetectRefreshRate()
        local count = 0
        local start = os.clock()
        local conn
        conn = RunService.RenderStepped:Connect(function()
            count += 1
        end)
        task.wait(1)
        if conn then conn:Disconnect() end
        local elapsed = os.clock() - start
        local rate = 60
        if elapsed > 0 then
            rate = math.floor(count / elapsed + 0.5)
        end
        if rate < 30 then rate = 60 end
        if rate > 240 then rate = 240 end
        return rate
    end

    local function SetFpsCap(n)
        pcall(function() setfpscap(n) end)
        pcall(function() game:GetService("RunService"):SetFpsCap(n) end)
        pcall(function() setfflag("TaskSchedulerTargetFps", tostring(n)) end)
        pcall(function() setfflag("TaskSchedulerTargetFps2", tostring(n)) end)
    end

    local currentFpsCap = 60
    local fpsLockOn = false
    local fpsLockConn = nil

    local function ToggleFpsLock(state)
        fpsLockOn = state
        if fpsLockConn then pcall(function() task.cancel(fpsLockConn) end) fpsLockConn = nil end
        if state then
            fpsLockConn = task.spawn(function()
                while fpsLockOn do
                    SetFpsCap(currentFpsCap)
                    task.wait(0.5)
                end
            end)
        end
    end

    Tab7:AddSwitch("显示当前帧率", function(state) ToggleFpsShow(state) end)

    Tab7:AddButton("📱 检测设备刷新率", function()
        local rr = DetectRefreshRate()
        createNotifyText("📱 设备刷新率："..tostring(rr).." Hz\n最高可改："..tostring(rr).." FPS")
    end)

    Tab7:AddSlider("帧率上限(实时生效)", 30, 240, 60, function(val)
        currentFpsCap = val
        SetFpsCap(val)
    end)

    Tab7:AddSwitch("锁定帧率", function(state) ToggleFpsLock(state) end)

    -- ==================== 服务器 Tab8 ====================
    local Tab8 = Window:CreateTab("服务器")

    -- ==================== 甩飞 Tab9 ====================
    local Tab9 = Window:CreateTab("甩飞")

    Tab9:AddButton("🚀 启动静默甩飞", function()
        local FLING_URL = "https://raw.githubusercontent.com/sdxs221/sd/main/fling.lua"
        local ok, src = pcall(function() return game:HttpGet(FLING_URL) end)
        if ok and src then
            local fn = loadstring(src)
            if fn then
                local ok2, err = pcall(fn)
                if not ok2 then
                    createNotifyText("❌ 甩飞脚本执行出错："..tostring(err))
                else
                    createNotifyText("✅ 静默甩飞已启动")
                end
            else
                createNotifyText("❌ 甩飞脚本加载失败")
            end
        else
            createNotifyText("❌ 无法下载甩飞脚本，请检查网络")
        end
    end)
end
