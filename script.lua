local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local points = {
    {position = Vector3.new(302, 1, -243), interact = true},
    {position = Vector3.new(338, 22, -1218), interact = true},
    {position = Vector3.new(221, 25, -9447), interact = true},
    {position = Vector3.new(215, 25, -1210), interact = false},
    {position = Vector3.new(137, 30, 9949), interact = true},
}

local running = false
local currentPoint = 0
local TELEPORT_DELAY = 10

local COLORS = {
    Background = Color3.fromRGB(10, 10, 12),
    Panel = Color3.fromRGB(20, 20, 24),
    Card = Color3.fromRGB(28, 28, 33),
    Red = Color3.fromRGB(213, 31, 54),
    RedLight = Color3.fromRGB(245, 55, 75),
    Text = Color3.fromRGB(245, 245, 245),
    Muted = Color3.fromRGB(160, 160, 170),
    Green = Color3.fromRGB(50, 220, 125),
    Border = Color3.fromRGB(65, 65, 72),
}

-- Удаляем старый GUI при повторном запуске
local oldGui = player.PlayerGui:FindFirstChild("IntermediateGui")
if oldGui then
    oldGui:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "IntermediateGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Главное окно
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(720, 470)
main.Position = UDim2.new(0.5, -360, 0.5, -235)
main.BackgroundColor3 = COLORS.Background
main.BorderSizePixel = 0
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

local outline = Instance.new("UIStroke")
outline.Color = COLORS.Border
outline.Thickness = 1
outline.Parent = main

-- Заголовок
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 90)
header.BackgroundColor3 = COLORS.Panel
header.BorderSizePixel = 0
header.Parent = main

Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Position = UDim2.fromOffset(22, 12)
title.Size = UDim2.fromOffset(450, 38)
title.BackgroundTransparency = 1
title.Text = "INTERMEDIATE"
title.TextColor3 = COLORS.Text
title.TextSize = 28
title.Font = Enum.Font.GothamBlack
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Position = UDim2.fromOffset(23, 50)
subtitle.Size = UDim2.fromOffset(450, 24)
subtitle.BackgroundTransparency = 1
subtitle.Text = "STUDIO  /  AUTO ROUTE"
subtitle.TextColor3 = COLORS.Red
subtitle.TextSize = 14
subtitle.Font = Enum.Font.GothamBold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Закрытие
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(36, 36)
closeButton.Position = UDim2.new(1, -50, 0, 20)
closeButton.BackgroundColor3 = COLORS.Card
closeButton.Text = "×"
closeButton.TextColor3 = COLORS.Text
closeButton.TextSize = 25
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = header

Instance.new("UICorner", closeButton).CornerRadius = UDim.new(0, 8)

closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

-- Карточка маршрута
local routeCard = Instance.new("Frame")
routeCard.Position = UDim2.fromOffset(20, 110)
routeCard.Size = UDim2.fromOffset(430, 335)
routeCard.BackgroundColor3 = COLORS.Card
routeCard.BorderSizePixel = 0
routeCard.Parent = main

Instance.new("UICorner", routeCard).CornerRadius = UDim.new(0, 12)

local routeTitle = Instance.new("TextLabel")
routeTitle.Position = UDim2.fromOffset(18, 12)
routeTitle.Size = UDim2.new(1, -36, 0, 30)
routeTitle.BackgroundTransparency = 1
routeTitle.Text = "ROUTE CONTROL"
routeTitle.TextColor3 = COLORS.Text
routeTitle.TextSize = 18
routeTitle.Font = Enum.Font.GothamBold
routeTitle.TextXAlignment = Enum.TextXAlignment.Left
routeTitle.Parent = routeCard

local routeInfo = Instance.new("TextLabel")
routeInfo.Position = UDim2.fromOffset(18, 42)
routeInfo.Size = UDim2.new(1, -36, 0, 24)
routeInfo.BackgroundTransparency = 1
routeInfo.Text = "Маршрут состоит из пяти точек"
routeInfo.TextColor3 = COLORS.Muted
routeInfo.TextSize = 13
routeInfo.Font = Enum.Font.Gotham
routeInfo.TextXAlignment = Enum.TextXAlignment.Left
routeInfo.Parent = routeCard

-- Статус
local status = Instance.new("TextLabel")
status.Position = UDim2.fromOffset(18, 75)
status.Size = UDim2.new(1, -36, 0, 30)
status.BackgroundTransparency = 1
status.Text = "● ROUTE STOPPED"
status.TextColor3 = COLORS.Red
status.TextSize = 15
status.Font = Enum.Font.GothamBold
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = routeCard

-- Кнопка Start
local startButton = Instance.new("TextButton")
startButton.Position = UDim2.fromOffset(18, 120)
startButton.Size = UDim2.fromOffset(185, 48)
startButton.BackgroundColor3 = COLORS.Red
startButton.Text = "▶  START ROUTE"
startButton.TextColor3 = COLORS.Text
startButton.TextSize = 15
startButton.Font = Enum.Font.GothamBold
startButton.Parent = routeCard

Instance.new("UICorner", startButton).CornerRadius = UDim.new(0, 9)

-- Кнопка Stop
local stopButton = Instance.new("TextButton")
stopButton.Position = UDim2.fromOffset(218, 120)
stopButton.Size = UDim2.fromOffset(185, 48)
stopButton.BackgroundColor3 = COLORS.Panel
stopButton.Text = "■  STOP"
stopButton.TextColor3 = COLORS.Text
stopButton.TextSize = 15
stopButton.Font = Enum.Font.GothamBold
stopButton.Parent = routeCard

Instance.new("UICorner", stopButton).CornerRadius = UDim.new(0, 9)

-- Информация о точке
local pointLabel = Instance.new("TextLabel")
pointLabel.Position = UDim2.fromOffset(18, 185)
pointLabel.Size = UDim2.new(1, -36, 0, 30)
pointLabel.BackgroundTransparency = 1
pointLabel.Text = "Ожидание запуска..."
pointLabel.TextColor3 = COLORS.Text
pointLabel.TextSize = 14
pointLabel.Font = Enum.Font.GothamMedium
pointLabel.TextXAlignment = Enum.TextXAlignment.Left
pointLabel.Parent = routeCard

-- Задержка
local delayLabel = Instance.new("TextLabel")
delayLabel.Position = UDim2.fromOffset(18, 235)
delayLabel.Size = UDim2.fromOffset(180, 30)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Задержка: 10 секунд"
delayLabel.TextColor3 = COLORS.Muted
delayLabel.TextSize = 14
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = routeCard

-- Список точек справа
local pointsCard = Instance.new("Frame")
pointsCard.Position = UDim2.fromOffset(465, 110)
pointsCard.Size = UDim2.fromOffset(235, 335)
pointsCard.BackgroundColor3 = COLORS.Card
pointsCard.BorderSizePixel = 0
pointsCard.Parent = main

Instance.new("UICorner", pointsCard).CornerRadius = UDim.new(0, 12)

local pointsTitle = Instance.new("TextLabel")
pointsTitle.Position = UDim2.fromOffset(15, 12)
pointsTitle.Size = UDim2.new(1, -30, 0, 30)
pointsTitle.BackgroundTransparency = 1
pointsTitle.Text = "WAYPOINTS"
pointsTitle.TextColor3 = COLORS.Text
pointsTitle.TextSize = 16
pointsTitle.Font = Enum.Font.GothamBold
pointsTitle.TextXAlignment = Enum.TextXAlignment.Left
pointsTitle.Parent = pointsCard

for index, point in ipairs(points) do
    local row = Instance.new("TextLabel")
    row.Position = UDim2.fromOffset(15, 50 + (index - 1) * 48)
    row.Size = UDim2.new(1, -30, 0, 42)
    row.BackgroundColor3 = COLORS.Panel
    row.Text = "  " .. index .. "   " ..
        (point.interact and "E  •  INTERACT" or "SKIP")
    row.TextColor3 = point.interact and COLORS.Text or COLORS.Muted
    row.TextSize = 12
    row.Font = Enum.Font.GothamBold
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = pointsCard

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 7)
end

-- Перемещение окна за заголовок
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Получение персонажа
local function getCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")

    return character, root
end

-- Телепортация по точке
local function teleportTo(point, index)
    if not running then
        return
    end

    local character, root = getCharacter()

    currentPoint = index
    pointLabel.Text = "Текущая точка: " .. index .. "/" .. #points

    character:PivotTo(CFrame.new(point.position))

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    task.wait(0.5)

    if point.interact then
        print("Точка " .. index .. ": нужно взаимодействовать")
    else
        print("Точка " .. index .. ": взаимодействие пропущено")
    end
end

local function stopRoute()
    running = false
    status.Text = "● ROUTE STOPPED"
    status.TextColor3 = COLORS.Red
    pointLabel.Text = "Ожидание запуска..."
    startButton.Text = "▶  START ROUTE"
end

startButton.MouseButton1Click:Connect(function()
    if running then
        return
    end

    running = true
    status.Text = "● ROUTE ACTIVE"
    status.TextColor3 = COLORS.Green
    startButton.Text = "ROUTE ACTIVE"

    task.spawn(function()
        while running do
            for index, point in ipairs(points) do
                if not running then
                    break
                end

                teleportTo(point, index)

                local startTime = os.clock()
                while running and os.clock() - startTime < TELEPORT_DELAY do
                    task.wait(0.1)
                end
            end
        end

        stopRoute()
    end)
end)

stopButton.MouseButton1Click:Connect(stopRoute)

player.CharacterAdded:Connect(function()
    if running then
        stopRoute()
    end
end)

print("INTERMEDIATE STUDIO menu loaded")
