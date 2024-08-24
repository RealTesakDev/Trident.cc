-- Initialize ESP settings
if (not _G.Flags) then
    _G.Flags = {
        ESP = {
            NotVisibleColor = Color3.fromRGB(255, 0, 0),
            VisibleColor = Color3.fromRGB(0, 255, 0),
            DistanceLimit = 15000,
            Box = true,
            Name = true,
            Weapon = true,
            Distance = true,
            VisibleCheck = true,
            Sleepers = false,
        },
        HitboxExpander = {
            Size = 7,
            Enabled = true,
            Transparency = 0.7,
            Part = "Head",
        },
    }
end

if (not _G.Loaded) then
    _G.Loaded = true
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Items = ReplicatedStorage:WaitForChild("HandModels")
    local CoreGui = game:GetService("CoreGui")
    local CurrentCamera = workspace.CurrentCamera
    local IgnoreFolder = workspace:WaitForChild("Ignore")
    local OriginalSizes = {}
    local WeaponInfo = {}

    local SleepAnimationId = "rbxassetid://13280887764"

    -- Store original sizes for hitbox expansion
    for i, v in pairs(ReplicatedStorage.Shared.entities.Player.Model:GetChildren()) do
        if v:IsA("BasePart") then
            OriginalSizes[v.Name] = v.Size
        end
    end

    -- Initialize weapon attributes
    for i, v in pairs(Items:GetChildren()) do
        v:SetAttribute("RealName", v.Name)
    end

    -- Check if a player is sleeping
    function IsSleeping(Player)
        local Animations = Player.AnimationController:GetPlayingAnimationTracks()
        for i, v in pairs(Animations) do
            if (v.IsPlaying and v.Animation.AnimationId == SleepAnimationId) then
                return true
            end
        end
        return false
    end

    -- Create ESP elements
    function CreateESP()
        local BillboardGui = Instance.new("BillboardGui")
        local Box = Instance.new("Frame")
        local PlayerName = Instance.new("TextLabel")
        local PlayerWeapon = Instance.new("TextLabel")
        local PlayerDistance = Instance.new("TextLabel")
        local UIStroke = Instance.new("UIStroke")

        -- Configure BillboardGui properties
        BillboardGui.Parent = CoreGui
        BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        BillboardGui.Active = true
        BillboardGui.AlwaysOnTop = true
        BillboardGui.LightInfluence = 1.0
        BillboardGui.Size = UDim2.new(500, 0, 800, 0)

        -- Configure Box properties
        Box.Name = "Box"
        Box.Parent = BillboardGui
        Box.AnchorPoint = Vector2.new(0.5, 0.5)
        Box.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Box.BackgroundTransparency = 1.0
        Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Box.BorderSizePixel = 0
        Box.Position = UDim2.new(0.5, 0, 0.5, 0)
        Box.Size = UDim2.new(0.009, 0, 0.009, 0)

        -- Configure UIStroke properties
        UIStroke.Name = "UIStroke"
        UIStroke.Parent = Box
        UIStroke.Thickness = 1
        UIStroke.Color = Color3.fromRGB(0, 255, 0)
        UIStroke.LineJoinMode = Enum.LineJoinMode.Miter

        -- Configure PlayerName properties
        PlayerName.Name = "PlayerName"
        PlayerName.Parent = BillboardGui
        PlayerName.AnchorPoint = Vector2.new(0.5, 1)
        PlayerName.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PlayerName.BackgroundTransparency = 1.01
        PlayerName.BorderColor3 = Color3.fromRGB(0, 0, 0)
        PlayerName.BorderSizePixel = 0
        PlayerName.Position = UDim2.new(0.5, 0, 0.4955, 0)
        PlayerName.Size = UDim2.new(0, 100, 0, 10)
        PlayerName.Font = Enum.Font.SourceSans
        PlayerName.Text = "Player"
        PlayerName.TextColor3 = Color3.fromRGB(0, 255, 8)
        PlayerName.TextSize = 14.0
        PlayerName.TextYAlignment = Enum.TextYAlignment.Bottom

        -- Configure PlayerWeapon properties
        PlayerWeapon.Name = "PlayerWeapon"
        PlayerWeapon.Parent = BillboardGui
        PlayerWeapon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PlayerWeapon.BackgroundTransparency = 1.01
        PlayerWeapon.BorderColor3 = Color3.fromRGB(0, 0, 0)
        PlayerWeapon.BorderSizePixel = 0
        PlayerWeapon.Position = UDim2.new(0.5045, 0, 0.4955, 0)
        PlayerWeapon.Size = UDim2.new(0, 100, 0, 10)
        PlayerWeapon.Font = Enum.Font.SourceSans
        PlayerWeapon.Text = "Weapon"
        PlayerWeapon.TextColor3 = Color3.fromRGB(0, 255, 8)
        PlayerWeapon.TextSize = 14.0
        PlayerWeapon.TextXAlignment = Enum.TextXAlignment.Left
        PlayerWeapon.TextYAlignment = Enum.TextYAlignment.Bottom
        PlayerWeapon.Visible = false

        -- Configure PlayerDistance properties
        PlayerDistance.Name = "PlayerDistance"
        PlayerDistance.Parent = BillboardGui
        PlayerDistance.AnchorPoint = Vector2.new(0.5, 0)
        PlayerDistance.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        PlayerDistance.BackgroundTransparency = 1.01
        PlayerDistance.BorderColor3 = Color3.fromRGB(0, 0, 0)
        PlayerDistance.BorderSizePixel = 0
        PlayerDistance.Position = UDim2.new(0.5, 0, 0.505, 5)
        PlayerDistance.Size = UDim2.new(0, 100, 0, 10)
        PlayerDistance.Font = Enum.Font.SourceSans
        PlayerDistance.Text = "500"
        PlayerDistance.TextColor3 = Color3.fromRGB(0, 255, 8)
        PlayerDistance.TextSize = 14.0
        PlayerDistance.TextYAlignment = Enum.TextYAlignment.Bottom

        return BillboardGui
    end

    -- Get weapon name from player model
    function PlayerWeapon(Player)
        local Model = Player:FindFirstChildOfClass("Model")
        return Model and Model:GetAttribute("RealName") or "None"
    end

    -- Check if the model is a player
    function IsPlayer(Model)
        return Model.ClassName == "Model" and Model:FindFirstChild("Torso") and Model.PrimaryPart ~= nil
    end

    -- Set color for ESP elements
    function SetColor(Billboard, Color)
        Billboard.PlayerName.TextColor3 = Color
        Billboard.PlayerDistance.TextColor3 = Color
        Billboard.PlayerWeapon.TextColor3 = Color
        Billboard.Box.UIStroke.Color = Color
    end

    -- Expand hitbox of a player
    function HitboxExpander(Model, Size, Hitbox)
        if (Hitbox.Enabled) then
            local Part = Model[Hitbox.Part]
            Part.Size = Vector3.new(Size, Size, Size)
            Part.Transparency = Hitbox.Transparency
            Part.CanCollide = false
        else
            local Part = Model[Hitbox.Part]
            Part.Size = OriginalSizes[Hitbox.Part]
            Part.Transparency = 0
            Part.CanCollide = true
        end
    end

    local HasESP = {}

    -- Main loop for ESP updates
    RunService.Heartbeat:Connect(function()
        local ESP = _G.Flags.ESP
        local Hitbox = _G.Flags.HitboxExpander
        for i, v in pairs(workspace:GetChildren()) do
            if (HasESP[v] or IsPlayer(v)) then
                if (HasESP[v] == nil) then
                    local Billboard = CreateESP()
                    HasESP[v] = Billboard
                    Billboard.Adornee = v.PrimaryPart
                elseif (HasESP[v] ~= nil) then
                    local Billboard = HasESP[v]
                    Billboard.Adornee = v.PrimaryPart

                    -- Hide ESP if player is sleeping and Sleepers is false
                    if (IsSleeping(v) and not ESP.Sleepers) then
                        Billboard.Enabled = false
                        continue
                    else
                        Billboard.Enabled = true
                    end

                    -- Set player name, distance, and weapon
                    Billboard.PlayerName.Text = v.Name
                    Billboard.PlayerDistance.Text = tostring(math.floor((CurrentCamera.CFrame.p - v.PrimaryPart.Position).Magnitude)) .. "m"
                    Billboard.PlayerWeapon.Text = PlayerWeapon(v)

                    -- Update hitbox if enabled
                    if (Hitbox.Enabled) then
                        HitboxExpander(v, Hitbox.Size, Hitbox)
                    end

                    -- Visibility and color update based on visibility check
                    if (ESP.VisibleCheck and v.PrimaryPart ~= nil) then
                        local Vector, OnScreen = CurrentCamera:WorldToViewportPoint(v.PrimaryPart.Position)
                        if (OnScreen) then
                            SetColor(Billboard, ESP.VisibleColor)
                        else
                            SetColor(Billboard, ESP.NotVisibleColor)
                        end
                    else
                        SetColor(Billboard, ESP.VisibleColor)
                    end
                end
            end
        end
    end)
end
