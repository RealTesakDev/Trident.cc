local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Variables for tracking next action
local nextActionTime = 0
local currentDelay = 0

-- Action simulation functions
local function simulateJump()
    if humanoid and humanoid.Health > 0 then
        humanoid.Jump = true
        return "Jump"
    end
end

local function simulateMovement()
    local movements = {
        Vector3.new(0, 0, 0.1),
        Vector3.new(0, 0, -0.1),
        Vector3.new(0.1, 0, 0),
        Vector3.new(-0.1, 0, 0)
    }
    
    local randomMove = movements[math.random(1, #movements)]
    humanoid:Move(randomMove)
    return "Movement"
end

local function simulateMouseClick()
    VirtualUser:Button1Down(Vector2.new(0, 0))
    wait(0.1)
    VirtualUser:Button1Up(Vector2.new(0, 0))
    return "Mouse Click"
end

-- Main presence simulation loop
local function simulatePresence()
    local actionChoice = math.random(1, 4)
    local actionName = "None"
    
    if actionChoice == 1 then
        actionName = simulateJump()
    elseif actionChoice == 2 then
        actionName = simulateMovement()
    elseif actionChoice == 3 then
        actionName = simulateMouseClick()
    else
        VirtualUser:MoveMouse(Vector2.new(math.random(-10, 10), math.random(-10, 10)))
        actionName = "Camera Move"
    end
    
    -- Set next action time
    currentDelay = math.random(2, 5)
    nextActionTime = tick() + currentDelay
    
    return actionName
end

-- Handle character respawning
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
end)

-- Create UI
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
local statusLabel = Instance.new("TextLabel")
local timeLabel = Instance.new("TextLabel")
local nextActionLabel = Instance.new("TextLabel")
local lastActionLabel = Instance.new("TextLabel")
local queueLabel = Instance.new("TextLabel")

frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.5, -100, 0, 10)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.5

statusLabel.Size = UDim2.new(1, 0, 0.2, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Text = "Presence Script Active"
statusLabel.Parent = frame

timeLabel.Size = UDim2.new(1, 0, 0.2, 0)
timeLabel.Position = UDim2.new(0, 0, 0.2, 0)
timeLabel.BackgroundTransparency = 1
timeLabel.TextColor3 = Color3.new(1, 1, 1)
timeLabel.Text = "Time Running: 0s"
timeLabel.Parent = frame

nextActionLabel.Size = UDim2.new(1, 0, 0.2, 0)
nextActionLabel.Position = UDim2.new(0, 0, 0.4, 0)
nextActionLabel.BackgroundTransparency = 1
nextActionLabel.TextColor3 = Color3.new(1, 1, 1)
nextActionLabel.Text = "Next Action: 0.0s"
nextActionLabel.Parent = frame

lastActionLabel.Size = UDim2.new(1, 0, 0.2, 0)
lastActionLabel.Position = UDim2.new(0, 0, 0.6, 0)
lastActionLabel.BackgroundTransparency = 1
lastActionLabel.TextColor3 = Color3.new(1, 1, 1)
lastActionLabel.Text = "Last Action: None"
lastActionLabel.Parent = frame

queueLabel.Size = UDim2.new(1, 0, 0.2, 0)
queueLabel.Position = UDim2.new(0, 0, 0.8, 0)
queueLabel.BackgroundTransparency = 1
queueLabel.TextColor3 = Color3.new(1, 1, 1)
queueLabel.Text = "Auto-Queue: Ready"
queueLabel.Parent = frame

frame.Parent = screenGui
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Re-queue on teleport events
game:GetService("Players").PlayerRemoving:Connect(function(plr)
    if plr == player then
        if queue_on_teleport then
            queue_on_teleport(scriptString)
        end
    end
end)

-- Start time tracking
local startTime = tick()
nextActionTime = tick() + math.random(2, 5)

-- Main update loop
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    local timeRunning = math.floor(currentTime - startTime)
    local timeUntilNext = nextActionTime - currentTime
    
    -- Update UI
    timeLabel.Text = string.format("Time Running: %ds", timeRunning)
    nextActionLabel.Text = string.format("Next Action: %.1fs", math.max(0, timeUntilNext))
    
    -- Perform next action if it's time
    if currentTime >= nextActionTime then
        local actionPerformed = simulatePresence()
        lastActionLabel.Text = string.format("Last Action: %s", actionPerformed)
    end
end)
