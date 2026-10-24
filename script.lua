--// Auto Route + Auto E
--// LocalScript в StarterPlayer > StarterPlayerScripts
--// Для собственной Roblox-игры

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CONFIG
--==================================================

local CONFIG = {
    -- Время ожидания на точке перед переходом к следующей
    WaypointDelay = 10,

    -- Пауза после взаимодействия
    InteractionDelay = 0.5,

    -- Радиус поиска ProximityPrompt
    PromptSearchRadius = 12,

    -- Клавиши управления
    StartKey = Enum.KeyCode.F6,
    StopKey = Enum.KeyCode.F7,

    -- Перезапуск маршрута после последней точки
    LoopRoute = true,
}

local WAYPOINTS = {
    {
        Position = Vector3.new(302, 1, -243),
        Interact = true,
    },
    {
        Position = Vector3.new(338, 22, -1218),
        Interact = true,
    },
    {
        Position = Vector3.new(221, 25, -9447),
        Interact = true,
    },
    {
        Position = Vector3.new(215, 25, -1210),
        Interact = false,
    },
    {
        Position = Vector3.new(137, 30, 9949),
        Interact = true,
    },
}

--==================================================
-- STATE
--==================================================

local isRunning = false
local routeThread = nil
local currentWaypoint = 0

--==================================================
-- CHARACTER
--==================================================

local function getCharacter()
    return player.Character
end

local function getHumanoidRootPart()
    local character = getCharacter()
    if not character then
        return nil
    end

    return character:FindFirstChild("HumanoidRootPart")
end

local function getCharacterPivot()
    local character = getCharacter()
    if not character then
        return nil
    end

    return character:GetPivot()
end

local function teleportTo(position)
    local character = getCharacter()

    if not character then
        return false
    end

    local humanoidRootPart = getHumanoidRootPart()

    if not humanoidRootPart then
        return false
    end

    character:PivotTo(CFrame.new(position))
    return true
end

--==================================================
-- PROXIMITY PROMPT
--==================================================

local function getNearestPrompt()
    local rootPart = getHumanoidRootPart()

    if not rootPart then
        return nil
    end

    local nearestPrompt = nil
    local nearestDistance = CONFIG.PromptSearchRadius

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Enabled then
            local parent = object.Parent
            local promptPosition = nil

            if parent and parent:IsA("BasePart") then
                promptPosition = parent.Position
            elseif parent and parent:IsA("Attachment") then
                promptPosition = parent.WorldPosition
            end

            if promptPosition then
                local distance = (rootPart.Position - promptPosition).Magnitude

                if distance <= nearestDistance then
                    nearestDistance = distance
                    nearestPrompt = object
                end
            end
        end
    end

    return nearestPrompt
end

local function interactWithPrompt()
    if not isRunning then
        return false
    end

    local prompt = getNearestPrompt()

    if not prompt then
        return false
    end

    -- Начать удержание ProximityPrompt
    local success = pcall(function()
        prompt:InputHoldBegin()
    end)

    if not success then
        return false
    end

    task.wait(math.max(prompt.HoldDuration, 0.1))

    -- Завершить удержание
    pcall(function()
        prompt:InputHoldEnd()
    end)

    task.wait(CONFIG.InteractionDelay)

    return true
end

--==================================================
-- GUI
--==================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoRouteGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.fromOffset(230, 145)
mainFrame.Position = UDim2.new(0, 20, 0.5, -72)
mainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -12, 0, 30)
title.Position = UDim2.fromOffset(6, 5)
title.BackgroundTransparency = 1
title.Text = "Auto Route"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.fromOffset(10, 37)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Статус: остановлен"
statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13
statusLabel.Parent = mainFrame

local startButton = Instance.new("TextButton")
startButton.Name = "StartButton"
startButton.Size = UDim2.new(1, -20, 0, 32)
startButton.Position = UDim2.fromOffset(10, 68)
startButton.BackgroundColor3 = Color3.fromRGB(45, 145, 85)
startButton.Text = "Запустить маршрут"
startButton.TextColor3 = Color3.fromRGB(255, 255, 255)
startButton.Font = Enum.Font.GothamBold
startButton.TextSize = 13
startButton.Parent = mainFrame

local startCorner = Instance.new("UICorner")
startCorner.CornerRadius = UDim.new(0, 6)
startCorner.Parent = startButton

local stopButton = Instance.new("TextButton")
stopButton.Name = "StopButton"
stopButton.Size = UDim2.new(1, -20, 0, 32)
stopButton.Position = UDim2.fromOffset(10, 106)
stopButton.BackgroundColor3 = Color3.fromRGB(170, 55, 55)
stopButton.Text = "Остановить"
stopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
stopButton.Font = Enum.Font.GothamBold
stopButton.TextSize = 13
stopButton.Parent = mainFrame

local stopCorner = Instance.new("UICorner")
stopCorner.CornerRadius = UDim.new(0, 6)
stopCorner.Parent = stopButton

--==================================================
-- STATUS
--==================================================

local function updateStatus()
    if isRunning then
        statusLabel.Text = "Статус: работает (" .. currentWaypoint .. "/" .. #WAYPOINTS .. ")"
        statusLabel.TextColor3 = Color3.fromRGB(100, 230, 140)
    else
        statusLabel.Text = "Статус: остановлен"
        statusLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    end
end

--==================================================
-- ROUTE
--==================================================

local function runRoute()
    while isRunning do
        for index, waypoint in ipairs(WAYPOINTS) do
            if not isRunning then
                break
            end

            currentWaypoint = index
            updateStatus()

            local teleported = teleportTo(waypoint.Position)

            if not teleported then
                warn("[Auto Route] Не удалось переместить персонажа.")
                task.wait(1)
                continue
            end

            if waypoint.Interact and isRunning then
                interactWithPrompt()
            end

            if not isRunning then
                break
            end

            task.wait(CONFIG.WaypointDelay)
        end

        if not CONFIG.LoopRoute then
            break
        end
    end

    isRunning = false
    currentWaypoint = 0
    updateStatus()
end

--==================================================
-- START / STOP
--==================================================

local function startRoute()
    if isRunning then
        return
    end

    isRunning = true
    currentWaypoint = 0
    updateStatus()

    routeThread = task.spawn(runRoute)
end

local function stopRoute()
    isRunning = false
    currentWaypoint = 0
    updateStatus()
end

--==================================================
-- BUTTONS
--==================================================

startButton.MouseButton1Click:Connect(function()
    startRoute()
end)

stopButton.MouseButton1Click:Connect(function()
    stopRoute()
end)

--==================================================
-- KEYBINDS
--==================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == CONFIG.StartKey then
        startRoute()
    elseif input.KeyCode == CONFIG.StopKey then
        stopRoute()
    end
end)

--==================================================
-- RESPAWN HANDLING
--==================================================

player.CharacterAdded:Connect(function()
    task.wait(1)

    if isRunning then
        updateStatus()
    end
end)

--==================================================
-- INIT
--==================================================

updateStatus()

print("[Auto Route] Загружен.")
print("[Auto Route] F6 — запуск, F7 — остановка.")
