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
        "F-35 Lightning toputtenga",
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
