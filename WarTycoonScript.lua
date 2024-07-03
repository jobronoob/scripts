-- Define variables
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Holding = false
local IsAiming = false
local ClosestPlayer = nil

_G.AimbotEnabled = true
_G.TeamCheck = false -- If set to true then the script would only lock your aim at enemy team members.
_G.AimPart = "Head" -- Where the aimbot script would lock at.
_G.Sensitivity = 0 -- How many seconds it takes for the aimbot script to officially lock onto the target's aimpart.

_G.CircleSides = 64 -- How many sides the FOV circle would have.
_G.CircleColor = Color3.fromRGB(255, 255, 255) -- (RGB) Color that the FOV circle would appear as.
_G.CircleTransparency = 0.7 -- Transparency of the circle.
_G.CircleRadius = 80 -- The radius of the circle / FOV.
_G.CircleFilled = false -- Determines whether or not the circle is filled.
_G.CircleVisible = true -- Determines whether or not the circle is visible.
_G.CircleThickness = 0 -- The thickness of the circle.

local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Filled = _G.CircleFilled
FOVCircle.Color = _G.CircleColor
FOVCircle.Visible = _G.CircleVisible
FOVCircle.Radius = _G.CircleRadius
FOVCircle.Transparency = _G.CircleTransparency
FOVCircle.NumSides = _G.CircleSides
FOVCircle.Thickness = _G.CircleThickness

local function toggleFovCircle()
    _G.CircleVisible = not _G.CircleVisible
end

-- Function to get players in FOV
local function GetPlayersInFOV()
    local PlayersInFOV = {}

    for _, v in next, Players:GetPlayers() do
        if v ~= LocalPlayer then
            if _G.TeamCheck then
                if v.Team ~= LocalPlayer.Team then
                    local Character = v.Character
                    if Character and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                        local HumanoidRoot = Character.HumanoidRootPart
                        local ScreenPoint = Camera:WorldToScreenPoint(HumanoidRoot.Position)

                        -- Calculate direction vector from player to target
                        local Direction = (HumanoidRoot.Position - Camera.CFrame.Position).unit
                        local DotProduct = Camera.CFrame.LookVector:Dot(Direction)

                        -- Ensure player is in front (dot product > 0) and within radius
                        if DotProduct > 0 then
                            local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                            if VectorDistance < _G.CircleRadius then
                                table.insert(PlayersInFOV, v)
                            end
                        end
                    end
                end
            else
                local Character = v.Character
                if Character and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 then
                    local HumanoidRoot = Character.HumanoidRootPart
                    local ScreenPoint = Camera:WorldToScreenPoint(HumanoidRoot.Position)

                    -- Calculate direction vector from player to target
                    local Direction = (HumanoidRoot.Position - Camera.CFrame.Position).unit
                    local DotProduct = Camera.CFrame.LookVector:Dot(Direction)

                    -- Ensure player is in front (dot product > 0) and within radius
                    if DotProduct > 0 then
                        local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                        if VectorDistance < _G.CircleRadius then
                            table.insert(PlayersInFOV, v)
                        end
                    end
                end
            end
        end
    end

    return PlayersInFOV
end


UserInputService.InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.LeftAlt then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.LeftAlt then
        Holding = false
        IsAiming = false  -- Reset aiming state on release
    end
end)

-- RenderStepped function to handle aimbot logic
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Filled = _G.CircleFilled
    FOVCircle.Color = _G.CircleColor
    FOVCircle.Visible = _G.CircleVisible
    FOVCircle.Radius = _G.CircleRadius
    FOVCircle.Transparency = _G.CircleTransparency
    FOVCircle.NumSides = _G.CircleSides
    FOVCircle.Thickness = _G.CircleThickness

    if Holding and _G.AimbotEnabled then
        if not IsAiming then
            local PlayersInFOV = GetPlayersInFOV()
            ClosestPlayer = nil
            local ClosestDistance = math.huge

            -- Find closest player in FOV
            for _, Player in ipairs(PlayersInFOV) do
                local Character = Player.Character
                if Character and Character[_G.AimPart] then
                    local ScreenPoint = Camera:WorldToScreenPoint(Character[_G.AimPart].Position)
                    local VectorDistance = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(ScreenPoint.X, ScreenPoint.Y)).Magnitude

                    if VectorDistance < ClosestDistance then
                        ClosestPlayer = Player
                        ClosestDistance = VectorDistance
                    end
                end
            end

            -- Aim at closest player
            if ClosestPlayer then
                IsAiming = true
                local Character = ClosestPlayer.Character
                if Character and Character[_G.AimPart] then
                    TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Character[_G.AimPart].Position)}):Play()
                end
            end
        else
            -- Continue aiming at current ClosestPlayer
            if ClosestPlayer then
                local Character = ClosestPlayer.Character
                if Character and Character[_G.AimPart] then
                    TweenService:Create(Camera, TweenInfo.new(_G.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFrame.new(Camera.CFrame.Position, Character[_G.AimPart].Position)}):Play()
                end
            end
        end
    else
        IsAiming = false  -- Reset aiming state if not holding
    end
end)

local flySpeed = 100
local flyEnabled = false
local bodyVelocity
local bodyGyro


local ESP_ENABLED = false
local ESP = {}

local function createESP(player)
    if ESP[player] then
        return  -- ESP already created for this player
    end

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255, 255, 255)
    Box.Thickness = 2
    Box.Transparency = 1

    local HealthText = Drawing.new("Text")
    HealthText.Visible = false
    HealthText.Color = Color3.fromRGB(255, 255, 255)
    HealthText.Size = 16
    HealthText.Center = true
    HealthText.Outline = true
    HealthText.OutlineColor = Color3.fromRGB(0, 0, 0)

    local WeaponText = Drawing.new("Text")
    WeaponText.Visible = false
    WeaponText.Color = Color3.fromRGB(255, 255, 255)
    WeaponText.Size = 14
    WeaponText.Center = true
    WeaponText.Outline = true
    WeaponText.OutlineColor = Color3.fromRGB(0, 0, 0)

    local NameText = Drawing.new("Text")
    NameText.Visible = false
    NameText.Color = Color3.fromRGB(255, 255, 255)
    NameText.Size = 18
    NameText.Center = true
    NameText.Outline = true
    NameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    NameText.Text = player.Name

    local ShieldText = Drawing.new("Text")  -- Define ShieldText
    ShieldText.Visible = false  -- Initialize visibility
    ShieldText.Color = Color3.fromRGB(255, 255, 255)
    ShieldText.Size = 14
    ShieldText.Center = true
    ShieldText.Outline = true
    ShieldText.OutlineColor = Color3.fromRGB(0, 0, 0)

    ESP[player] = {
        Box = Box,
        HealthText = HealthText,
        WeaponText = WeaponText,
        NameText = NameText,
        ShieldText = ShieldText,  -- Include ShieldText in ESP table
        LastEquipped = nil,
        TextOffset = Vector2.new(0, 0)
    }

local function updateESP()
    if not ESP[player] then
        return
    end

    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") and player ~= LocalPlayer then
        local RootPart = character.HumanoidRootPart
        local Humanoid = character.Humanoid

        local Vector, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)

        if OnScreen then
            -- Update box size and position
            Box.Size = Vector2.new(2000 / Vector.Z, 2500 / Vector.Z)
            Box.Position = Vector2.new(Vector.X - Box.Size.X / 2, Vector.Y - Box.Size.Y / 2)
            Box.Visible = ESP_ENABLED

            -- Update health text
            local hp = Humanoid.Health
            local maxHp = Humanoid.MaxHealth
            local hpDisplay = string.format("%d / %d", hp, maxHp)

            HealthText.Text = hpDisplay
            HealthText.Position = Vector2.new(Vector.X, Vector.Y + Box.Size.Y / 2 + 20)
            HealthText.Visible = ESP_ENABLED

            -- Check for shield
            local hasShield = false
            for _, part in ipairs(character:GetChildren()) do
                if part.Name == "Shield" then
                    hasShield = true
                    break
                end
            end

            -- Update shield indicator
            if hasShield then
                ShieldText.Text = "Shielded"
                ShieldText.Position = Vector2.new(Vector.X, Vector.Y + Box.Size.Y / 2 + 40)
                ShieldText.Visible = ESP_ENABLED
            else
                ShieldText.Visible = false
            end

            -- Update weapon text
            local currentWeapon = Humanoid.Parent:FindFirstChildOfClass("Tool")
            if currentWeapon then
                WeaponText.Text = currentWeapon.Name
                WeaponText.Position = Vector2.new(Vector.X, Vector.Y + Box.Size.Y / 2 + 60)
                WeaponText.Visible = ESP_ENABLED
                ESP[player].LastEquipped = currentWeapon.Name
            else
                WeaponText.Visible = false
                ESP[player].LastEquipped = nil
            end

            -- Update name text
            NameText.Position = Vector2.new(Vector.X, Vector.Y - Box.Size.Y / 2 - 20)
            NameText.Visible = ESP_ENABLED
        else
            Box.Visible = false
            HealthText.Visible = false
            ShieldText.Visible = false
            WeaponText.Visible = false
            NameText.Visible = false
            ESP[player].LastEquipped = nil
        end
    else
        Box.Visible = false
        HealthText.Visible = false
        ShieldText.Visible = false
        WeaponText.Visible = false
        NameText.Visible = false
        ESP[player].LastEquipped = nil
    end
end


    RunService.RenderStepped:Connect(updateESP)

    local function onCharacterRemoving()
        -- Disconnect RenderStepped listener
        RunService.RenderStepped:Disconnect()
        
        -- Remove drawing objects
        Box:Remove()
        HealthText:Remove()
        WeaponText:Remove()
        NameText:Remove()
        ShieldText:Remove()  -- Remove ShieldText

        -- Remove from ESP table
        ESP[player] = nil
    end

    player.CharacterRemoving:Connect(onCharacterRemoving)
    player.CharacterAdded:Connect(updateESP)

    -- Trigger initial update
    updateESP()
end


local function toggleESP()
    ESP_ENABLED = not ESP_ENABLED

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if ESP_ENABLED then
                createESP(player)
            else
                removeESP(player)
            end
        end
    end
end

-- Создание ESP для каждого игрока при их добавлении
Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

-- Удаление ESP при удалении игрока
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Создание ESP для уже существующих игроков
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createESP(player)
    end
end

local function initialize()
    -- Создание GUI элементов
    local UserInputService = game:GetService("UserInputService")
    local player = Players.LocalPlayer

    local ScreenGui = Instance.new("ScreenGui")
    local Panel = Instance.new("Frame")

    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    Panel.Parent = ScreenGui
    Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Panel.Position = UDim2.new(0.5, -400, 0.5, -150) -- Положение в середине экрана и смещение на половину ширины и высоты
    Panel.Size = UDim2.new(0, 800, 0, 300) -- Размер панели
    Panel.BorderSizePixel = 0
    Panel.BackgroundTransparency = 0.5 -- Example transparency value (adjust as needed)

    local OriginalSize = Panel.Size


    local function togglePanel()
        if Panel.Visible then
            -- Hide the panel smoothly
            Panel.Visible = false
            local endPosition = UDim2.new(-0.5, 0, 0.5, 0)  -- Position the panel off-screen to the left
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            local panelTween = TweenService:Create(Panel, tweenInfo, {Position = endPosition})

            panelTween:Play()

            panelTween.Completed:Connect(function()
                -- Ensure the panel is hidden completely after animation
                Panel.Visible = false
            end)
        else
            -- Show the panel smoothly
            Panel.Visible = true
            Panel.Position = UDim2.new(-0.5, 0, 0.5, 0)  -- Position the panel off-screen to the left
            local endPosition = UDim2.new(0.5, -400, 0.5, -150)  -- Position the panel in the center
            local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

            local panelTween = TweenService:Create(Panel, tweenInfo, {Position = endPosition})

            panelTween:Play()
        end
    end



    local FlyPanel = Instance.new("Frame")
    FlyPanel.Parent = Panel
    FlyPanel.Size = UDim2.new(1, 0, 0.9, 0)
    FlyPanel.Position = UDim2.new(0, 0, 0.1, 0)
    FlyPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    FlyPanel.Visible = true
    FlyPanel.BackgroundTransparency = 0.5

    local WallHackPanel = Instance.new("Frame")
    WallHackPanel.Parent = Panel
    WallHackPanel.Size = UDim2.new(1, 0, 0.9, 0)
    WallHackPanel.Position = UDim2.new(0, 0, 0.1, 0)
    WallHackPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    WallHackPanel.Visible = false
    WallHackPanel.BackgroundTransparency = 0.5


    local AimBotPanel = Instance.new("Frame")
    AimBotPanel.Parent = Panel
    AimBotPanel.Size = UDim2.new(1, 0, 0.9, 0)
    AimBotPanel.Position = UDim2.new(0, 0, 0.1, 0)
    AimBotPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    AimBotPanel.Visible = false
    AimBotPanel.BackgroundTransparency = 0.5


    local SettingsPanel = Instance.new("Frame")
    SettingsPanel.Parent = Panel
    SettingsPanel.Size = UDim2.new(1, 0, 0.9, 0)
    SettingsPanel.Position = UDim2.new(0, 0, 0.1, 0)
    SettingsPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    SettingsPanel.Visible = false
    SettingsPanel.BackgroundTransparency = 0.5

    local TeleportationPanel = Instance.new("Frame")
    TeleportationPanel.Parent = Panel
    TeleportationPanel.Size = UDim2.new(1, 0, 0.9, 0)
    TeleportationPanel.Position = UDim2.new(0, 0, 0.1, 0)
    TeleportationPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    TeleportationPanel.Visible = false
    TeleportationPanel.BackgroundTransparency = 0.5


    local function switchToPanel(panel)
        FlyPanel.Visible = false
        WallHackPanel.Visible = false
        AimBotPanel.Visible = false
        SettingsPanel.Visible = false
        TeleportationPanel.Visible = false
        panel.Visible = true
    end



    local FlyTabButton = Instance.new("TextButton")
    FlyTabButton.Parent = Panel
    FlyTabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    FlyTabButton.Position = UDim2.new(0, 0, 0, 0)
    FlyTabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    FlyTabButton.Text = "Fly"
    FlyTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyTabButton.BorderSizePixel = 0
    FlyTabButton.BackgroundTransparency = 0.5
    FlyTabButton.MouseButton1Click:Connect(function()
        switchToPanel(FlyPanel)
    end)

    local WallHackTabButton = Instance.new("TextButton")
    WallHackTabButton.Parent = Panel
    WallHackTabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    WallHackTabButton.Position = UDim2.new(0.2, 0, 0, 0)
    WallHackTabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    WallHackTabButton.Text = "WallHack"
    WallHackTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    WallHackTabButton.BorderSizePixel = 0
    WallHackTabButton.BackgroundTransparency = 0.5
    WallHackTabButton.MouseButton1Click:Connect(function()
        switchToPanel(WallHackPanel)
    end)


    local AimBotTabButton = Instance.new("TextButton")
    AimBotTabButton.Parent = Panel
    AimBotTabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    AimBotTabButton.Position = UDim2.new(0.8, 0, 0, 0)
    AimBotTabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    AimBotTabButton.Text = "AimBot"
    AimBotTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimBotTabButton.BorderSizePixel = 0
    AimBotTabButton.BackgroundTransparency = 0.5
    AimBotTabButton.MouseButton1Click:Connect(function()
        switchToPanel(AimBotPanel)
    end)

    local SettingsTabButton = Instance.new("TextButton")
    SettingsTabButton.Parent = Panel
    SettingsTabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    SettingsTabButton.Position = UDim2.new(0.4, 0, 0, 0)
    SettingsTabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    SettingsTabButton.Text = "Settings"
    SettingsTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsTabButton.BorderSizePixel = 0
    SettingsTabButton.BackgroundTransparency = 0.5
    SettingsTabButton.MouseButton1Click:Connect(function()
        switchToPanel(SettingsPanel)
    end)

    local TeleportationTabButton = Instance.new("TextButton")
    TeleportationTabButton.Parent = Panel
    TeleportationTabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    TeleportationTabButton.Position = UDim2.new(0.6, 0, 0, 0)
    TeleportationTabButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    TeleportationTabButton.Text = "ClickWarp"
    TeleportationTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportationTabButton.BorderSizePixel = 0
    TeleportationTabButton.BackgroundTransparency = 0.5
    TeleportationTabButton.MouseButton1Click:Connect(function()
        switchToPanel(TeleportationPanel)
    end)

    -- Создание элементов внутри панелей
    local FlyLabel = Instance.new("TextLabel")
    FlyLabel.Size = UDim2.new(0, 200, 0, 50)
    FlyLabel.Position = UDim2.new(0.25, 0, 0.1, 0)
    FlyLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    FlyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyLabel.Text = "Fly:"
    FlyLabel.Parent = FlyPanel
    FlyLabel.BackgroundTransparency = 0.5

    local FlyToggleButton = Instance.new("TextButton")
    FlyToggleButton.Parent = FlyPanel
    FlyToggleButton.Size = UDim2.new(0, 200, 0, 50)
    FlyToggleButton.Position = UDim2.new(0.25, 0, 0.3, 0)
    FlyToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    FlyToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FlyToggleButton.Text = "Активировать"
    FlyToggleButton.BorderSizePixel = 0
    FlyToggleButton.BackgroundTransparency = 0.5

    local NoClipLabel = Instance.new("TextLabel")
    NoClipLabel.Size = UDim2.new(0, 200, 0, 50)
    NoClipLabel.Position = UDim2.new(0.25, 0, 0.5, 0)
    NoClipLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    NoClipLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoClipLabel.Text = "NoClip:"
    NoClipLabel.Parent = FlyPanel
    NoClipLabel.BackgroundTransparency = 0.5

    local NoClipToggleButton = Instance.new("TextButton")
    NoClipToggleButton.Parent = FlyPanel
    NoClipToggleButton.Size = UDim2.new(0, 200, 0, 50)
    NoClipToggleButton.Position = UDim2.new(0.25, 0, 0.7, 0)
    NoClipToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    NoClipToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoClipToggleButton.Text = "Активировать"
    NoClipToggleButton.BorderSizePixel = 0
    NoClipToggleButton.BackgroundTransparency = 0.5

    local WallHackLabel = Instance.new("TextLabel")
    WallHackLabel.Size = UDim2.new(0, 200, 0, 50)
    WallHackLabel.Position = UDim2.new(0.25, 0, 0.1, 0)
    WallHackLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    WallHackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    WallHackLabel.Text = "WallHack:"
    WallHackLabel.Parent = WallHackPanel
    WallHackLabel.BackgroundTransparency = 0.5

    local AimBotLabel = Instance.new("TextLabel")
    AimBotLabel.Size = UDim2.new(0, 200, 0, 50)
    AimBotLabel.Position = UDim2.new(0.25, 0, 0.1, 0)
    AimBotLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    AimBotLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimBotLabel.Text = "AimBot:"
    AimBotLabel.Parent = AimBotPanel
    AimBotLabel.BackgroundTransparency = 0.5

    local AimBotALTLabel = Instance.new("TextLabel")
    AimBotALTLabel.Size = UDim2.new(0, 200, 0, 50)
    AimBotALTLabel.Position = UDim2.new(0.25, 0, 0.5, 0)
    AimBotALTLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    AimBotALTLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimBotALTLabel.Text = "AimBot НА ЛЕВЫЙ АЛЬТ! "
    AimBotALTLabel.Parent = AimBotPanel
    AimBotALTLabel.BackgroundTransparency = 0.5

    local AimBotALT2Label = Instance.new("TextLabel")
    AimBotALT2Label.Size = UDim2.new(0, 200, 0, 50)
    AimBotALT2Label.Position = UDim2.new(0.25, 0, 0.7, 0)
    AimBotALT2Label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    AimBotALT2Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimBotALT2Label.Text = "Нажми два раза и тогда он включится! "
    AimBotALT2Label.Parent = AimBotPanel
    AimBotALT2Label.BackgroundTransparency = 0.5

    local WallHackToggleButton = Instance.new("TextButton")
    WallHackToggleButton.Parent = WallHackPanel
    WallHackToggleButton.Size = UDim2.new(0, 200, 0, 50)
    WallHackToggleButton.Position = UDim2.new(0.25, 0, 0.3, 0)
    WallHackToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    WallHackToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    WallHackToggleButton.Text = "Активировать"
    WallHackToggleButton.BorderSizePixel = 0
    WallHackToggleButton.BackgroundTransparency = 0.5

    local AimbotToggle = Instance.new("TextButton")
    AimbotToggle.Parent = AimBotPanel
    AimbotToggle.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    AimbotToggle.Position = UDim2.new(0.25, 0, 0.3, 0)
    AimbotToggle.Size = UDim2.new(0, 200, 0, 50)
    AimbotToggle.Text = "Aimbot: Off"
    AimbotToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    AimbotToggle.BorderSizePixel = 0
    AimbotToggle.BackgroundTransparency = 0.5
    AimbotToggle.MouseButton1Click:Connect(function()
        _G.AimbotEnabled = not _G.AimbotEnabled
        AimbotToggle.Text = _G.AimbotEnabled and "Aimbot: On" or "Aimbot: Off"
    end)

    local FovCircleToggleButton = Instance.new("TextButton")
    FovCircleToggleButton.Parent = AimBotPanel  -- Replace with your panel
    FovCircleToggleButton.Size = UDim2.new(0, 200, 0, 50)
    FovCircleToggleButton.Position = UDim2.new(0.6, -50, 0.5, 0)
    FovCircleToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    FovCircleToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    FovCircleToggleButton.Text = "Toggle FovCircle"
    FovCircleToggleButton.BorderSizePixel = 0
    FovCircleToggleButton.BackgroundTransparency = 0.5

    FovCircleToggleButton.MouseButton1Click:Connect(function()
        toggleFovCircle()
        FovCircleToggleButton.Text = FovCircle.Visible and "Disable FovCircle" or "Enable FovCircle"
    end)


    local SettingsLabel = Instance.new("TextLabel")
    SettingsLabel.Size = UDim2.new(0, 200, 0, 50)
    SettingsLabel.Position = UDim2.new(0.25, 0, 0.1, 0)
    SettingsLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    SettingsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    SettingsLabel.Text = "Settings:"
    SettingsLabel.Parent = SettingsPanel
    SettingsLabel.BackgroundTransparency = 0.5

    local TeleportationLabel = Instance.new("TextLabel")
    TeleportationLabel.Size = UDim2.new(0, 200, 0, 50)
    TeleportationLabel.Position = UDim2.new(0.25, 0, 0.1, 0)
    TeleportationLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TeleportationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportationLabel.Text = "ClickWarp:"
    TeleportationLabel.Parent = TeleportationPanel
    TeleportationLabel.BackgroundTransparency = 0.5

    local TeleportationToggleButton = Instance.new("TextButton")
    TeleportationToggleButton.Parent = TeleportationPanel
    TeleportationToggleButton.Size = UDim2.new(0, 200, 0, 50)
    TeleportationToggleButton.Position = UDim2.new(0.25, 0, 0.3, 0)
    TeleportationToggleButton.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    TeleportationToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TeleportationToggleButton.Text = "Активировать"
    TeleportationToggleButton.BorderSizePixel = 0
    TeleportationToggleButton.BackgroundTransparency = 0.5

    local WalkspeedLabel = Instance.new("TextLabel")
    WalkspeedLabel.Size = UDim2.new(0, 200, 0, 50)
    WalkspeedLabel.Position = UDim2.new(0.25, 0, 0.3, 0)
    WalkspeedLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    WalkspeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    WalkspeedLabel.Text = "Walkspeed:"
    WalkspeedLabel.Parent = SettingsPanel
    WalkspeedLabel.BackgroundTransparency = 0.5

    local WalkspeedTextBox = Instance.new("TextBox")
    WalkspeedTextBox.Parent = SettingsPanel
    WalkspeedTextBox.Size = UDim2.new(0, 100, 0, 30)
    WalkspeedTextBox.Position = UDim2.new(0.6, -50, 0.3, 0)
    WalkspeedTextBox.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    WalkspeedTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    WalkspeedTextBox.Text = tostring(LocalPlayer.Character.Humanoid.WalkSpeed)
    WalkspeedTextBox.BorderSizePixel = 0
    WalkspeedTextBox.BackgroundTransparency = 0.5

    local JumppowerLabel = Instance.new("TextLabel")
    JumppowerLabel.Size = UDim2.new(0, 200, 0, 50)
    JumppowerLabel.Position = UDim2.new(0.25, 0, 0.5, 0)
    JumppowerLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    JumppowerLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    JumppowerLabel.Text = "Jumppower:"
    JumppowerLabel.Parent = SettingsPanel
    JumppowerLabel.BackgroundTransparency = 0.5

    local JumppowerTextBox = Instance.new("TextBox")
    JumppowerTextBox.Parent = SettingsPanel
    JumppowerTextBox.Size = UDim2.new(0, 100, 0, 30)
    JumppowerTextBox.Position = UDim2.new(0.6, -50, 0.5, 0)
    JumppowerTextBox.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    JumppowerTextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    JumppowerTextBox.Text = tostring(LocalPlayer.Character.Humanoid.JumpPower)
    JumppowerTextBox.BorderSizePixel = 0
    JumppowerTextBox.BackgroundTransparency = 0.5



    local function setWalkspeed(walkspeed)
        LocalPlayer.Character.Humanoid.WalkSpeed = walkspeed
    end

    local function setJumppower(jumppower)
        LocalPlayer.Character.Humanoid.JumpPower = jumppower
    end

    WalkspeedTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newWalkspeed = tonumber(WalkspeedTextBox.Text)
            if newWalkspeed then
                setWalkspeed(newWalkspeed)
            else
                WalkspeedTextBox.Text = tostring(LocalPlayer.Character.Humanoid.WalkSpeed)
            end
        end
    end)

    JumppowerTextBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newJumppower = tonumber(JumppowerTextBox.Text)
            if newJumppower then
                setJumppower(newJumppower)
            else
                JumppowerTextBox.Text = tostring(LocalPlayer.Character.Humanoid.JumpPower)
            end
        end
    end)


    function startFly()
        local character = player.Character
        local torso = character:FindFirstChild("HumanoidRootPart")

        if torso then
            -- Создаем и настраиваем BodyVelocity для движения
            bodyVelocity = Instance.new("BodyVelocity")
            bodyVelocity.Velocity = Vector3.new(0, 0, 0)  -- Начальная скорость (0, 0, 0)
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)  -- Максимальная сила, чтобы игнорировать массу
            bodyVelocity.Parent = torso  -- Ставим BodyVelocity в HumanoidRootPart

            -- Создаем и настраиваем BodyGyro для стабилизации
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)  -- Максимальный крутящий момент для стабилизации
            bodyGyro.P = 9e4  -- Параметр P для BodyGyro
            bodyGyro.Parent = torso  -- Ставим BodyGyro в HumanoidRootPart

            -- Слушаем RenderStepped, чтобы обновлять движение каждый кадр
            game:GetService("RunService").RenderStepped:Connect(function()
                if not flyEnabled then return end  -- Если полет выключен, прерываем выполнение

                local camCF = workspace.CurrentCamera.CFrame
                bodyGyro.CFrame = CFrame.new(bodyGyro.Parent.Position, bodyGyro.Parent.Position + camCF.LookVector)
                local moveDirection = Vector3.new()

                -- Управление направлением движения
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camCF.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camCF.LookVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camCF.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camCF.RightVector
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end

                bodyVelocity.Velocity = moveDirection * flySpeed  -- Устанавливаем скорость движения
            end)
        end
    end



    local noClipEnabled = false
    local teleportationEnabled = false

    -- Функция для включения или выключения полета
    local function toggleFly()
        flyEnabled = not flyEnabled
        
        if flyEnabled then
            startFly()
        else
            stopFly()
        end
    end



    local noClipConnections = {}

    local function setNoClip(enabled)
        local character = LocalPlayer.Character
        if character then
            if enabled then
                -- Enable NoClip
                local connection = RunService.Stepped:Connect(function()
                    for _, child in pairs(character:GetDescendants()) do
                        if child:IsA("BasePart") then
                            child.CanCollide = false
                        end
                    end
                end)
                table.insert(noClipConnections, connection)
            else
                -- Disable NoClip
                for _, child in pairs(character:GetDescendants()) do
                    if child:IsA("BasePart") then
                        child.CanCollide = true
                    end
                end
                -- Disconnect all Stepped connections
                for _, connection in ipairs(noClipConnections) do
                    connection:Disconnect()
                end
                noClipConnections = {}  -- Clear the connections table
            end
        end
    end




    local function teleportPlayer(position)
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.CFrame = CFrame.new(position)
        end
    end

    local function handleTeleportation(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and teleportationEnabled then
            local mouse = LocalPlayer:GetMouse()
            local target = mouse.Hit
            if target then
                teleportPlayer(target.p)
            end
        end
    end

    UserInputService.InputBegan:Connect(handleTeleportation)


    -- Функция для выключения полета
    function stopFly()
        flyEnabled = false
        if bodyVelocity then
            bodyVelocity:Destroy()
            bodyVelocity = nil
        end
        if bodyGyro then
            bodyGyro:Destroy()
            bodyGyro = nil
        end
    end

    FlyToggleButton.MouseButton1Click:Connect(function()
        toggleFly()
        FlyToggleButton.Text = "Деактивировать" or "Активировать"
    end)

    NoClipToggleButton.MouseButton1Click:Connect(function()
        noClipEnabled = not noClipEnabled
        setNoClip(noClipEnabled)
        NoClipToggleButton.Text = noClipEnabled and "Деактивировать" or "Активировать"
    end)

    TeleportationToggleButton.MouseButton1Click:Connect(function()
        teleportationEnabled = not teleportationEnabled
        TeleportationToggleButton.Text = teleportationEnabled and "Деактивировать" or "Активировать"
    end)

    -- Управление отображением GUI
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.Insert then
                togglePanel()
            end
        end
    end)

    WallHackToggleButton.MouseButton1Click:Connect(function()
        toggleESP()
        WallHackToggleButton.Text = ESP_ENABLED and "Деактивировать" or "Активировать"
    end)
end

local function onCharacterAdded(character)
    -- Задержка для обеспечения полной загрузки персонажа
    wait(1)
    initialize()
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Запускаем инициализацию для текущего персонажа
if LocalPlayer.Character then
    onCharacterAdded(LocalPlayer.Character)
end
