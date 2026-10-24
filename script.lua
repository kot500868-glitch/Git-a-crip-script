--[[
    INTERMEDIATE STUDIO
    AUTO ROUTE + AUTO E

    Author: Kot:3
    Assisted by: ChatGPT

    Controls:
    F6 - Auto E ON
    F7 - Auto E OFF
    Start - Start route
    Stop - Stop route
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- CONFIGURATION
--------------------------------------------------

local TELEPORT_DELAY = 10
local INTERACTION_DELAY = 0.5

local points = {
    {position = Vector3.new(302, 1, -243), interact = true},
    {position = Vector3.new(338, 22, -1218), interact = true},
    {position = Vector3.new(221, 25, -9447), interact = true},
    {position = Vector3.new(215, 25, -1210), interact = false},
    {position = Vector3.new(137, 30, 9949), interact = true},
}

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

local running = false
local autoE = false
local currentPoint = 0

--------------------------------------------------
-- CHARACTER HELPERS
--------------------------------------------------

local function getCharacter()
    local character = player.Character

    if not character then
        character = player.CharacterAdded:Wait()
    end

    return character
end

local function getRoot()
    local character = getCharacter()
    return character:WaitForChild("HumanoidRootPart")
end

local function getHumanoid()
    local character = getCharacter()
    return character:WaitForChild("Humanoid")
end

--------------------------------------------------
-- CLEANUP OLD GUI
--------------------------------------------------

local oldGui = playerGui:FindFirstChild("IntermediateGui")

if oldGui then
    oldGui:Destroy()
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "IntermediateGui"
gui.ResetOnSpawn = false
gui.Enabled = true
gui.Parent = playerGui

--------------------------------------------------
-- MAIN WINDOW
--------------------------------------------------

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(720, 470)
main.Position = UDim2.new(0.5, -360, 0.5, -235)
main.BackgroundColor3 = COLORS.Background
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = main

local outline = Instance.new("UIStroke")
outline.Color = COLORS.Border
outline.Thickness = 1
outline.Parent = main

--------------------------------------------------
-- HEADER
--------------------------------------------------

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 90)
header.BackgroundColor3 = COLORS.Panel
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

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
subtitle.Text = "STUDIO / AUTO ROUTE / Kot:3"
subtitle.TextColor3 = COLORS.Red
subtitle.TextSize = 14
subtitle.Font = Enum.Font.GothamBold
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header
--------------------------------------------------
-- BUTTON HELPER
--------------------------------------------------

local function createButton(parent, name, text, position, size, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = color
    button.Text = text
    button.TextColor3 = COLORS.Text
    button.TextSize = 14
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = button

    return button
end

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local closeButton = createButton(
    header,
    "CloseButton",
    "×",
    UDim2.new(1, -50, 0, 20),
    UDim2.fromOffset(36, 36),
    COLORS.Card
)

closeButton.TextSize = 25

closeButton.MouseButton1Click:Connect(function()
    running = false
    gui:Destroy()
end)

--------------------------------------------------
-- ROUTE CARD
--------------------------------------------------

local routeCard = Instance.new("Frame")
routeCard.Name = "RouteCard"
routeCard.Position = UDim2.fromOffset(20, 110)
routeCard.Size = UDim2.fromOffset(430, 335)
routeCard.BackgroundColor3 = COLORS.Card
routeCard.BorderSizePixel = 0
routeCard.Parent = main

local routeCorner = Instance.new("UICorner")
routeCorner.CornerRadius = UDim.new(0, 12)
routeCorner.Parent = routeCard

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

--------------------------------------------------
-- STATUS
--------------------------------------------------

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

--------------------------------------------------
-- START / STOP BUTTONS
--------------------------------------------------

local startButton = createButton(
    routeCard,
    "StartButton",
    "START ROUTE",
    UDim2.fromOffset(18, 120),
    UDim2.fromOffset(185, 48),
    COLORS.Red
)

local stopButton = createButton(
    routeCard,
    "StopButton",
    "STOP",
    UDim2.fromOffset(218, 120),
    UDim2.fromOffset(185, 48),
    COLORS.Panel
)

--------------------------------------------------
-- CURRENT POINT
--------------------------------------------------

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

--------------------------------------------------
-- DELAY LABEL
--------------------------------------------------

local delayLabel = Instance.new("TextLabel")
delayLabel.Position = UDim2.fromOffset(18, 235)
delayLabel.Size = UDim2.fromOffset(180, 30)
delayLabel.BackgroundTransparency = 1
delayLabel.Text = "Задержка: " .. TELEPORT_DELAY .. " секунд"
delayLabel.TextColor3 = COLORS.Muted
delayLabel.TextSize = 14
delayLabel.Font = Enum.Font.Gotham
delayLabel.TextXAlignment = Enum.TextXAlignment.Left
delayLabel.Parent = routeCard

--------------------------------------------------
-- AUTO E STATUS
--------------------------------------------------

local autoELabel = Instance.new("TextLabel")
autoELabel.Position = UDim2.fromOffset(18, 275)
autoELabel.Size = UDim2.new(1, -36, 0, 30)
autoELabel.BackgroundTransparency = 1
autoELabel.Text = "AUTO E: OFF | F6 ON / F7 OFF"
autoELabel.TextColor3 = COLORS.Muted
autoELabel.TextSize = 13
autoELabel.Font = Enum.Font.GothamBold
autoELabel.TextXAlignment = Enum.TextXAlignment.Left
autoELabel.Parent = routeCard

--------------------------------------------------
-- WAYPOINTS CARD
--------------------------------------------------

local pointsCard = Instance.new("Frame")
pointsCard.Name = "PointsCard"
pointsCard.Position = UDim2.fromOffset(465, 110)
pointsCard.Size = UDim2.fromOffset(235, 335)
pointsCard.BackgroundColor3 = COLORS.Card
pointsCard.BorderSizePixel = 0
pointsCard.Parent = main

local pointsCorner = Instance.new("UICorner")
pointsCorner.CornerRadius = UDim.new(0, 12)
pointsCorner.Parent = pointsCard

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

--------------------------------------------------
-- WAYPOINT LIST
--------------------------------------------------

for index, point in ipairs(points) do
    local row = Instance.new("TextLabel")

    row.Position = UDim2.fromOffset(
        15,
        50 + (index - 1) * 48
    )

    row.Size = UDim2.new(1, -30, 0, 42)
    row.BackgroundColor3 = COLORS.Panel

    if point.interact then
        row.Text = "  " .. index .. "   E  •  INTERACT"
        row.TextColor3 = COLORS.Text
    else
        row.Text = "  " .. index .. "   SKIP"
        row.TextColor3 = COLORS.Muted
    end

    row.TextSize = 12
    row.Font = Enum.Font.GothamBold
    row.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = pointsCard

    local rowCorner = Instance.new("UICorner")
    rowCorner.CornerRadius = UDim.new(0, 7)
    rowCorner.Parent = row
end

--------------------------------------------------
-- DRAG WINDOW
--------------------------------------------------

local dragging = false
local dragStart = nil
local startPos = nil

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging
        and input.UserInputType == Enum.UserInputType.MouseMovement then

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

--------------------------------------------------
-- AUTO E CONTROL
--------------------------------------------------

local function setAutoE(enabled)
    autoE = enabled
 if autoE then
        autoELabel.Text = "AUTO E: ON | F7 TO STOP"
        autoELabel.TextColor3 = COLORS.Green
        print("AUTO E: ON")
    else
        autoELabel.Text = "AUTO E: OFF | F6 TO START"
        autoELabel.TextColor3 = COLORS.Muted
        print("AUTO E: OFF")
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F6 then
        setAutoE(true)
    elseif input.KeyCode == Enum.KeyCode.F7 then
        setAutoE(false)
    end
end)

--------------------------------------------------
-- PROXIMITY PROMPT INTERACTION
--------------------------------------------------

local function interactWithPrompt()
    if not autoE then
        return
    end

    local root = getRoot()
    local nearestPrompt = nil
    local nearestDistance = math.huge

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Enabled then
            local parent = object.Parent
            local promptPosition = nil

            if parent:IsA("BasePart") then
                promptPosition = parent.Position
            elseif parent:IsA("Attachment") then
                promptPosition = parent.WorldPosition
            end

            if promptPosition then
                local distance = (root.Position - promptPosition).Magnitude

                if distance <= object.MaxActivationDistance
                    and distance < nearestDistance then

                    nearestPrompt = object
                    nearestDistance = distance
                end
            end
        end
    end

    if nearestPrompt then
        local holdTime = math.max(
            nearestPrompt.HoldDuration,
            INTERACTION_DELAY
        )

        nearestPrompt:InputHoldBegin()
        task.wait(holdTime)
        nearestPrompt:InputHoldEnd()
    end
end

--------------------------------------------------
-- TELEPORT TO POINT
--------------------------------------------------

local function teleportTo(point, index)
    if not running then
        return
    end

    local character = getCharacter()
    local root = getRoot()

    currentPoint = index

    pointLabel.Text = "Текущая точка: " .. index .. "/" .. #points

    character:PivotTo(CFrame.new(point.position))

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    task.wait(INTERACTION_DELAY)

    if point.interact and autoE then
        interactWithPrompt()
    end
end

--------------------------------------------------
-- STOP ROUTE
--------------------------------------------------

local function stopRoute()
    running = false

    status.Text = "● ROUTE STOPPED"
    status.TextColor3 = COLORS.Red

    pointLabel.Text = "Ожидание запуска..."
    startButton.Text = "START ROUTE"
end

--------------------------------------------------
-- START ROUTE
--------------------------------------------------

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

                while running
                    and os.clock() - startTime < TELEPORT_DELAY do

                    task.wait(0.1)
                end
            end
        end

        stopRoute()
    end)
end)

--------------------------------------------------
-- STOP BUTTON
--------------------------------------------------

stopButton.MouseButton1Click:Connect(function()
    stopRoute()
end)

--------------------------------------------------
-- RESPAWN HANDLING
--------------------------------------------------
player.CharacterAdded:Connect(function()
    if running then
        stopRoute()
    end
end)

--------------------------------------------------
-- FINAL
--------------------------------------------------

print("INTERMEDIATE STUDIO loaded")
print("Author: Kot:3")
print("Assisted by: ChatGPT")
print("F6 = Auto E ON")
print("F7 = Auto E OFF")
