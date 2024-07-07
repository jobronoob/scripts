local Players = game:GetService("Players")
local player = Players.LocalPlayer

local currentIndexTankCrate = 1
local tankCrates = nil  -- Переменная для хранения списка Tank Crate

-- Функция для обновления списка Tank Crate
local function updateTankCratesList()
    local gameSystems = game.Workspace:WaitForChild("Game Systems")
    local crateWorkspace = gameSystems:WaitForChild("Crate Workspace")

    -- Получаем все объекты "Tank Crate"
    tankCrates = crateWorkspace:GetChildren()
end

-- Функция для телепортации к следующему Tank Crate
local function teleportToNextTankCrate()
    if not tankCrates or currentIndexTankCrate > #tankCrates then
        updateTankCratesList()
    end

    -- Проверяем, есть ли еще Tank Crate для телепортации
    if tankCrates and currentIndexTankCrate <= #tankCrates then
        local tankCrate = tankCrates[currentIndexTankCrate]
        if tankCrate:IsA("BasePart") then
            local character = player.Character or player.CharacterAdded:Wait()
            local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            humanoidRootPart.CFrame = tankCrate.CFrame
        end
        currentIndexTankCrate = currentIndexTankCrate + 1
    else
        warn("Все объекты 'Tank Crate' были проверены.")
        currentIndexTankCrate = 1  -- Сбрасываем для возможности повторного прохождения
    end
end

local function teleportToCrateCollector()
    local teamName = player.Team.Name
    local tycoons = game.Workspace:FindFirstChild("Tycoon"):FindFirstChild("Tycoons")
    if tycoons then
        local teamTycoon = tycoons:FindFirstChild(teamName)
        if teamTycoon then
            local essentials = teamTycoon:FindFirstChild("Essentials")
            if essentials then
                local oilCollector = essentials:FindFirstChild("Oil Collector")
                if oilCollector then
                    local cratePromptPart = oilCollector:FindFirstChild("CratePromptPart")
                    if cratePromptPart and cratePromptPart:IsA("BasePart") then
                        local character = player.Character or player.CharacterAdded:Wait()
                        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
                        humanoidRootPart.CFrame = cratePromptPart.CFrame
                    else
                        warn("Объект 'CratePromptPart' не найден или не является частью.")
                    end
                else
                    warn("Объект 'Oil Collector' не найден.")
                end
            else
                warn("Объект 'Essentials' не найден.")
            end
        else
            warn("Объект '" .. teamName .. "' не найден.")
        end
    else
        warn("Объект 'Tycoons' не найден.")
    end
end


-- Вызываем функцию обновления списка Tank Crate в начале
updateTankCratesList()

-- Создаем GUI элементы
local TeleportGui = Instance.new("ScreenGui")
TeleportGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 200)
Frame.Position = UDim2.new(0.5, 500, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Frame.Visible = true  -- По умолчанию показываем панель
Frame.Parent = TeleportGui

-- Создаем кнопку для телепортации ко всем Tank Crate
local teleportButton = Instance.new("TextButton")
teleportButton.Size = UDim2.new(0, 180, 0, 40)
teleportButton.Position = UDim2.new(0.5, 0, 0, 100)
teleportButton.AnchorPoint = Vector2.new(0.5, 0)
teleportButton.Text = "Телепорт к точке"
teleportButton.Parent = Frame

-- Функция для телепортации игрока
local function teleportToCapturePoint()
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local capturePoint = game.Workspace.Beams.CapturePoint1
    
    if character and capturePoint then
        character:MoveTo(capturePoint.Position)
    end
end

-- Привязываем функцию телепортации к кнопке
teleportButton.MouseButton1Click:Connect(teleportToCapturePoint)

-- Создаем кнопку для телепортации ко всем Tank Crate
local teleportButtonTank = Instance.new("TextButton")
teleportButtonTank.Size = UDim2.new(0, 180, 0, 40)
teleportButtonTank.Position = UDim2.new(0.5, 0, 0, 5)
teleportButtonTank.AnchorPoint = Vector2.new(0.5, 0)
teleportButtonTank.Text = "Телепорт к Crate"
teleportButtonTank.Parent = Frame

-- Создаем кнопку для телепортации к Crate Collector
local teleportButtonCollector = Instance.new("TextButton")
teleportButtonCollector.Size = UDim2.new(0, 180, 0, 40)
teleportButtonCollector.Position = UDim2.new(0.5, 0, 0, 50)
teleportButtonCollector.AnchorPoint = Vector2.new(0.5, 0)
teleportButtonCollector.Text = "Телепорт к Crate Collector"
teleportButtonCollector.Parent = Frame

-- Функция для переключения видимости панели по нажатию клавиши Home
local function togglePanelVisibility()
    Frame.Visible = not Frame.Visible
end

-- Обработчик события нажатия клавиши Home
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Home then
        togglePanelVisibility()
    end
end)

teleportButtonTank.MouseButton1Click:Connect(teleportToNextTankCrate)
teleportButtonCollector.MouseButton1Click:Connect(teleportToCrateCollector)


-- Создаем ScreenGui для панели
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Создаем фрейм (панель)
local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0.2, 0, 0.1, 0)  -- Размер фрейма (примерно 20% от экрана по ширине и 10% по высоте)
Frame.Position = UDim2.new(0.5, 0, 0.8, 0)  -- Позиция фрейма (по центру нижней части экрана)
Frame.AnchorPoint = Vector2.new(0.5, 0.5)  -- Центрируем фрейм
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)  -- Цвет фона фрейма
Frame.BorderSizePixel = 2  -- Толщина границы фрейма
Frame.BorderColor3 = Color3.fromRGB(0, 0, 0)  -- Цвет границы фрейма
Frame.Parent = ScreenGui

-- Создаем кнопку внутри фрейма
local ToggleButton = Instance.new("TextButton")
ToggleButton.Text = "AutoPlay: OFF"
ToggleButton.Size = UDim2.new(0.8, 0, 0.8, 0)  -- Размер кнопки (80% от фрейма по ширине и высоте)
ToggleButton.Position = UDim2.new(0.1, 0, 0.1, 0)  -- Позиция кнопки внутри фрейма (10% от фрейма)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)  -- Цвет фона кнопки
ToggleButton.BorderSizePixel = 2  -- Толщина границы кнопки
ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)  -- Цвет границы кнопки
ToggleButton.Parent = Frame

-- Создаем кнопку для игнорирования
local IgnoreButton = Instance.new("TextButton")
IgnoreButton.Text = "IgnoreButton: OFF"
IgnoreButton.Size = UDim2.new(0.8, 0, 0.8, 0)  -- Размер кнопки (80% от фрейма по ширине и высоте)
IgnoreButton.Position = UDim2.new(0.1, 0, 1, 0)  -- Позиция кнопки внутри фрейма (30% от фрейма)
IgnoreButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)  -- Цвет фона кнопки
IgnoreButton.BorderSizePixel = 2  -- Толщина границы кнопки
IgnoreButton.BorderColor3 = Color3.fromRGB(0, 0, 0)  -- Цвет границы кнопки
IgnoreButton.Parent = Frame

-- Функция для проверки, нужно ли игнорировать кнопку
local function shouldIgnoreButton(buttonName)
    local partsToIgnore = {
        "Javelin Giver",
        "AWP Giver",
        "Auto Collect Gamepass",
        "2x Cash Gamepass",
        "2x Health Armor",
        "Speedy Oil Extractor",
        "FAMAS Group Gun",
        "GTE Shirt",
        "10k Shield Health Gamepass",
        "Speedy Humvee",
        "PL-01",
        "ADATS",
        "T-72",
        "T-90",
        "MAUS",
        "M3 Bradley",
        "AbramsX",
        "T-14 Armata",
        "Leopard 2A7",
        "BTR-80",
        "M35 Truck",
        "VCAC Mephisto",
        "Barrett M82 Giver",
        "M14 Rifle Giver",
        "M1918 BAR Giver",
        "Vietnam Clothing",
        "Vietnam Armor",
        "M1903 Springfield Giver",
        "M1918 BAR Giver",
        "Boxer CRV Giver",
        "Camo Customizer Giver",
        "Remington ACR Giver",
        "USP 45 Giver",
        "Saiga-12k Giver",
        "Desert Eagle Giver",
        "Tactical JLTV Giver",
        "WW2 US Army Pack Giver",
        "Mi24 Helicopter",
        "Explosive Sniper Giver",
        "FAL Heavy Giver",
        "Boxer CRV",
        "JLTV",
        "M1117 Guardian",
        "M142 HIMARS",
        "Pantsir S1",
        "A-10 Air Strike Giver",
        "Gunship",
        "Lazar 3 APC",
        "Barrett M82",
        "KA-52 Alligator",
        "Mi24 Hind",
        "UH-60 Black Hawk",
        "KA-52 Alligator",
        "Eurocopter Tiger",
        "AH-64 Apache",
        "Boxer CRV",
        "MiG-29 Fulcrum",
        "F-4 Phantom",
        "F-35 Lightning",
        "WW2 US Army Pack",
        "F-14 Tomcat",
        "F-16 Falcon",
        "A-10 Warthog",
        "Ju 87 Stuka",
        "Destroyer Drone",
        "JLTV",
        "KSG 12 Giver",
        "PP19 Bizon Giver",
        'Fairmile',
        'USS Douglas',
        'PG-02',
        "LAV-AD",
        "Super Stallion",
    }

    -- Проверяем наличие кнопки в списке игнорируемых
    for _, name in ipairs(partsToIgnore) do
        if buttonName == name then
            return true
        end
    end

    return false
end

-- Функция для включения/выключения AutoPlay
local function toggleAutoPlay()
    getgenv().AutoPlay = not getgenv().AutoPlay
    ToggleButton.Text = getgenv().AutoPlay and "AutoPlay: ON" or "AutoPlay: OFF"
    
    if getgenv().AutoPlay then
        task.spawn(function()
            while getgenv().AutoPlay do
                task.wait()
                
                -- Получаем игрока, который активировал автоплей
                local player = game.Players.LocalPlayer
                if not player then
                    return
                end
                
                -- Получаем название команды игрока
                local playerTeam = player.Team
                if not playerTeam then
                    warn("Игрок не состоит в команде.")
                    return
                end
                
                local teamName = playerTeam.Name
                
                -- Находим тайкун для указанной команды
                local tycoon = game.Workspace.Tycoon.Tycoons:FindFirstChild(teamName)
                if not tycoon then
                    warn("Тайкун для команды " .. teamName .. " не найден.")
                    return
                end
                
                -- Получаем объекты для телепортации (UnpurchasedButtons)
                local unpurchasedButtons = tycoon:FindFirstChild("UnpurchasedButtons")
                if not unpurchasedButtons then
                    warn("Объекты UnpurchasedButtons не найдены для команды " .. teamName)
                    return
                end
                
                -- Получаем список частей, к которым можно телепортироваться
                local partsToTeleportTo = {}
                for _, model in pairs(unpurchasedButtons:GetChildren()) do
                    if model:IsA("Model") then
                        local part = model:FindFirstChild("Part")
                        if part then
                            local buttonName = part.Parent.Name
                            if not shouldIgnoreButton(buttonName) then
                                table.insert(partsToTeleportTo, part)
                            end
                        end
                    end
                end
                
                -- Если есть части для телепортации, выбираем случайную часть и телепортируемся к ней
                if #partsToTeleportTo > 0 then
                    local randomPart = partsToTeleportTo[math.random(1, #partsToTeleportTo)]
                    local newPosition = randomPart.CFrame.Position + Vector3.new(0, 5, 0)
                    
                    -- Добавляем задержку перед телепортацией
                    task.wait(0.15)
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(newPosition)
                    
                    -- Добавляем задержку после телепортации
                    task.wait(0.15)
                else
                    warn("Нет доступных объектов для телепортации.")
                end
                
                -- Дополнительные задержки между действиями, как указано в настройках
                task.wait(tonumber(getgenv().WaitBeforeCollect))
            end
        end)
    end
end

-- Привязываем функции к событию нажатия соответствующих кнопок
ToggleButton.MouseButton1Click:Connect(toggleAutoPlay)

-- Функция для включения/выключения IgnoreButton
local function toggleIgnoreButton()
    getgenv().IgnoreButton = not getgenv().IgnoreButton
    IgnoreButton.Text = getgenv().IgnoreButton and "IgnoreButton: ON" or "IgnoreButton: OFF"
end

IgnoreButton.MouseButton1Click:Connect(toggleIgnoreButton)
