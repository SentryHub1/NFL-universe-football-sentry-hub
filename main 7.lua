--// NFL UNIVERSE COMPLETE HUB //--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

lp.CharacterAdded:Connect(function(c)
    char = c
    hrp = c:WaitForChild("HumanoidRootPart")
    hum = c:WaitForChild("Humanoid")
end)

---------------------------------------------------------------------
-- STATES
---------------------------------------------------------------------

local magnet = false
local autoCatch = false
local ballESP = false
local speed = false
local routeAssist = false
local chaseQB = false
local jumpBoost = false
local autoDive = false
local predictCatch = false
local guardLock = false
local myTarget = nil

---------------------------------------------------------------------
-- GUI
---------------------------------------------------------------------

local gui = Instance.new("ScreenGui", CoreGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,650,0,80)
frame.Position = UDim2.new(0,20,0,150)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0

local function Btn(name,x)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0,100,0,60)
    b.Position = UDim2.new(0,10 + (x*105),0,10)
    b.Text = name..": OFF"
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    return b
end

local bMagnet = Btn("Magnet",0)
local bCatch  = Btn("Catch",1)
local bESP    = Btn("ESP",2)
local bSpeed  = Btn("Speed",3)
local bRoute  = Btn("Route",4)
local bChase  = Btn("Chase",5)
local bJump   = Btn("Jump",6)
local bDive   = Btn("Dive",7)
local bPredict= Btn("Predict",8)
local bLock   = Btn("Guard",9)

local function toggle(state,var,btn)
    _G[var] = not _G[var]
    btn.Text = state..": "..(_G[var] and "ON" or "OFF")
end

bMagnet.MouseButton1Click:Connect(function() toggle("Magnet","magnet",bMagnet) end)
bCatch.MouseButton1Click:Connect(function() toggle("Catch","autoCatch",bCatch) end)
bESP.MouseButton1Click:Connect(function() toggle("ESP","ballESP",bESP) end)
bSpeed.MouseButton1Click:Connect(function() toggle("Speed","speed",bSpeed) end)
bRoute.MouseButton1Click:Connect(function() toggle("Route","routeAssist",bRoute) end)
bChase.MouseButton1Click:Connect(function() toggle("Chase","chaseQB",bChase) end)
bJump.MouseButton1Click:Connect(function() toggle("Jump","jumpBoost",bJump) end)
bDive.MouseButton1Click:Connect(function() toggle("Dive","autoDive",bDive) end)
bPredict.MouseButton1Click:Connect(function() toggle("Predict","predictCatch",bPredict) end)
bLock.MouseButton1Click:Connect(function() toggle("Guard","guardLock",bLock) end)

---------------------------------------------------------------------
-- BALL FINDER (NFL Universe uses Dynamic.FootballMain or Pigskin)
---------------------------------------------------------------------

local function getBall()
    for _,obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n == "footballmain" or n == "pigskin" or n:find("football") or n:find("ball") then
                return obj
            end
        end
    end
end

---------------------------------------------------------------------
-- ESP
---------------------------------------------------------------------

spawn(function()
    while task.wait(0.3) do
        if not ballESP then
            for _,b in pairs(workspace:GetDescendants()) do
                if b:IsA("BillboardGui") and b.Name == "ballESPGUI" then
                    b:Destroy()
                end
            end
        end

        if ballESP then
            local ball = getBall()
            if ball and not ball:FindFirstChild("ballESPGUI") then
                local gui = Instance.new("BillboardGui", ball)
                gui.Name = "ballESPGUI"
                gui.Size = UDim2.new(4,0,4,0)
                gui.AlwaysOnTop = true

                local txt = Instance.new("TextLabel", gui)
                txt.Size = UDim2.new(1,0,1,0)
                txt.BackgroundTransparency = 1
                txt.TextColor3 = Color3.fromRGB(255,0,0)
                txt.Text = "BALL"
                txt.TextScaled = true
            end
        end
    end
end)

---------------------------------------------------------------------
-- MAIN LOOP
---------------------------------------------------------------------

RunService.RenderStepped:Connect(function()
    local ball = getBall()

    -----------------------------------------------------------------
    -- SPEED
    -----------------------------------------------------------------
    if speed then hum.WalkSpeed = 32 else hum.WalkSpeed = 16 end
    if jumpBoost then hum.JumpPower = 60 else hum.JumpPower = 50 end

    -----------------------------------------------------------------
    -- BALL MAGNET
    -----------------------------------------------------------------
    if magnet and ball then
        local d = (ball.Position - hrp.Position).Magnitude
        if d < 200 and d > 5 then
            ball.AssemblyLinearVelocity = (hrp.Position - ball.Position).Unit * 90
        end
    end

    -----------------------------------------------------------------
    -- AUTO CATCH
    -----------------------------------------------------------------
    if autoCatch and ball and (ball.Position - hrp.Position).Magnitude < 12 then
        pcall(function()
            firetouchinterest(hrp, ball, 0)
            firetouchinterest(hrp, ball, 1)
        end)
    end

    -----------------------------------------------------------------
    -- AUTO DIVE
    -----------------------------------------------------------------
    if autoDive and ball then
        if (ball.Position - hrp.Position).Magnitude < 20 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -----------------------------------------------------------------
    -- PREDICT CATCH (best ability for beating bad players)
    -----------------------------------------------------------------
    if predictCatch and ball then
        local d = (ball.Position - hrp.Position).Magnitude
        if d < 35 and d > 10 then
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(ball.Position),0.07)
        end
    end

    -----------------------------------------------------------------
    -- ROUTE ASSIST (swerve / cuts)
    -----------------------------------------------------------------
    if routeAssist then
        if UIS:IsKeyDown(Enum.KeyCode.A) then
            hrp.CFrame *= CFrame.new(-0.85,0,0)
        elseif UIS:IsKeyDown(Enum.KeyCode.D) then
            hrp.CFrame *= CFrame.new(0.85,0,0)
        end
    end

    -----------------------------------------------------------------
    -- CHASE QB (find ball holder)
    -----------------------------------------------------------------
    if chaseQB then
        for _,p in pairs(Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("FootballMain") then
                local qb = p.Character:FindFirstChild("HumanoidRootPart")
                if qb then
                    hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(qb.Position),0.1)
                end
            end
        end
    end

    -----------------------------------------------------------------
    -- DEFENDER GUARD LOCK (sticks to your WR)
    -----------------------------------------------------------------
    if guardLock and myTarget and myTarget.Character then
        local tHRP = myTarget.Character:FindFirstChild("HumanoidRootPart")
        if tHRP then
            local pos = tHRP.Position + (tHRP.CFrame.LookVector * -4)
            hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(pos),0.18)
        end
    end
end)

---------------------------------------------------------------------
-- GUARD TARGET SELECT (press T on player to lock)
---------------------------------------------------------------------

UIS.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.T then
        local mouse = lp:GetMouse()
        local target = mouse.Target
        if target and target.Parent and Players:FindFirstChild(target.Parent.Name) then
            myTarget = Players[target.Parent.Name]
            print("Now guarding:", myTarget.Name)
        end
    end
end)

---------------------------------------------------------------------
-- DELTA ANTIKICK
---------------------------------------------------------------------
pcall(function()
    hookfunction(lp.Kick, function() end)
end)