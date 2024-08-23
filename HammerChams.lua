local RunService = game:GetService("RunService")

-- Function to create a highlight for a part and change its material
local function enhancePart(part)
    -- Create highlight
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.new(1, 1, 0)  -- Yellow fill
    highlight.OutlineColor = Color3.new(1, 0, 0)  -- Red outline
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Adornee = part
    highlight.Parent = part

    -- Change material
    part.Material = Enum.Material.Neon  -- Change to Neon material
    part.Color = Color3.new(0, 1, 1)  -- Cyan color

    return highlight
end

-- Function to recursively enhance all BaseParts in a model
local function enhanceModel(model)
    for _, child in pairs(model:GetDescendants()) do
        if child:IsA("BasePart") and not child:FindFirstChild("Highlight") then
            enhancePart(child)
        end
    end
end

-- Function to update enhancements
local function updateEnhancements()
    local ignoreFolder = workspace:FindFirstChild("Ignore")
    if ignoreFolder then
        for _, item in pairs(ignoreFolder:GetChildren()) do
            if item:IsA("BasePart") and not item:FindFirstChild("Highlight") then
                enhancePart(item)
            elseif item:IsA("Model") then
                enhanceModel(item)
            end
        end
    end
end

-- Run the update function every frame
RunService.Heartbeat:Connect(updateEnhancements)

-- Initial run to enhance existing objects
updateEnhancements()

-- Listen for new objects added to the Ignore folder
if workspace:FindFirstChild("Ignore") then
    workspace.Ignore.ChildAdded:Connect(function(child)
        wait()  -- Wait a frame to ensure the object is fully loaded
        if child:IsA("BasePart") then
            enhancePart(child)
        elseif child:IsA("Model") then
            enhanceModel(child)
        end
    end)
end

print("Enhancement script for workspace.Ignore is running")
