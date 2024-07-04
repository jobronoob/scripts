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
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0.5, -100, 0.5, -75)
Frame.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Frame.Visible = false  -- По умолчанию скрываем панель
Frame.Parent = TeleportGui

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
