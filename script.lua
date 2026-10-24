--[[
    KOT:3 | CUSTOM ROUTE UI
    LocalScript
    Помести в StarterPlayer > StarterPlayerScripts

    Интерфейс:
    - Фоновая картинка
    - Настройка прозрачности окна
    - Настройка прозрачности картинки
    - Настройка цвета
    - Кнопки Start / Stop
    - Перетаскивание окна
    - Открытие/закрытие меню клавишей F6
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- НАСТРОЙКИ
local BACKGROUND_IMAGE = "rbxassetid://1111733160486"

local WINDOW_COLOR = Color3.fromRGB(35, 35, 45)
local ACCENT_COLOR = Color3.fromRGB(120, 80, 255)

local WINDOW_TRANSPARENCY = 0.15
local IMAGE_TRANSPARENCY = 0.25

local WINDOW_SIZE = UDim2.new(0, 420, 0, 340)

-- Удаляем старый интерфейс при повторном запуске
local oldGui = playerGui:FindFirstChild("KotCustomRouteUI")
if oldGui then
    oldGui:Destroy()
end

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KotCustomRouteUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

-- Главное окно
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = WINDOW_SIZE
main.Position = UDim2.new(0.5, -210, 0.5, -170)
main.BackgroundColor3 = WINDOW_COLOR
main.BackgroundTransparency = WINDOW_TRANSPARENCY
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = ACCENT_COLOR
stroke.Thickness = 2
stroke.Parent = main

-- Фоновая картинка
local background = Instance.new("ImageLabel")
background.Name = "Background"
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundTransparency = 1
background.Image = BACKGROUND_IMAGE
background.ImageTransparency = IMAGE_TRANSPARENCY
background.ScaleType = Enum.ScaleType.Crop
background.ZIndex = 0
background.Parent = main

local backgroundCorner = Instance.new("UICorner")
backgroundCorner.CornerRadius = UDim.new(0, 12)
backgroundCorner.Parent = background

-- Затемнение фона для читаемости
local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.BackgroundColor3 = WINDOW_COLOR
overlay.BackgroundTransparency = 0.35
overlay.BorderSizePixel = 0
overlay.ZIndex = 1
overlay.Parent = main

local overlayCorner = Instance.new("UICorner")
overlayCorner.CornerRadius = UDim.new(0, 12)
overlayCorner.Parent = overlay

-- Заголовок
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -60, 0, 40)
title.Position = UDim2.new(0, 15, 0, 5)
title.BackgroundTransparency = 1
title.Text = "KOT:3  |  CUSTOM ROUTE"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.ZIndex = 2
title.Parent = main

-- Кнопка закрытия
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 32, 0, 32)
closeButton.Position = UDim2.new(1, -42, 0, 8)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 60, 70)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 15
closeButton.ZIndex = 3
closeButton.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Разделитель
local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -24, 0, 2)
divider.Position = UDim2.new(0, 12, 0, 48)
divider.BackgroundColor3 = ACCENT_COLOR
divider.BorderSizePixel = 0
divider.ZIndex = 2
divider.Parent = main

-- Статус
local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -30, 0, 28)
status.Position = UDim2.new(0, 15, 0, 58)
status.BackgroundTransparency = 1
status.Text = "Status: Stopped"
status.TextColor3 = Color3.fromRGB(230, 230, 230)
status.Font = Enum.Font.Gotham
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.ZIndex = 2
status.Parent = main
-- Создание кнопок
local function createButton(name, text, position, color)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0, 180, 0, 36)
    button.Position = position
    button.BackgroundColor3 = color
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.ZIndex = 2
    button.Parent = main

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    return button
end

local startButton = createButton(
    "StartButton",
    "START",
    UDim2.new(0, 15, 0, 95),
    ACCENT_COLOR
)

local stopButton = createButton(
    "StopButton",
    "STOP",
    UDim2.new(0, 225, 0, 95),
    Color3.fromRGB(190, 55, 65)
)

-- Настройки
local settingsTitle = Instance.new("TextLabel")
settingsTitle.Size = UDim2.new(1, -30, 0, 25)
settingsTitle.Position = UDim2.new(0, 15, 0, 145)
settingsTitle.BackgroundTransparency = 1
settingsTitle.Text = "SETTINGS"
settingsTitle.TextColor3 = Color3.new(1, 1, 1)
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextSize = 14
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.ZIndex = 2
settingsTitle.Parent = main

-- Слайдер прозрачности окна
local function createSlider(labelText, yPosition, defaultValue, callback)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 0, 20)
    label.Position = UDim2.new(0, 15, 0, yPosition)
    label.BackgroundTransparency = 1
    label.Text = labelText .. ": " .. tostring(defaultValue)
    label.TextColor3 = Color3.new(1, 1, 1)
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 2
    label.Parent = main

    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(1, -30, 0, 8)
    sliderBack.Position = UDim2.new(0, 15, 0, yPosition + 22)
    sliderBack.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    sliderBack.BorderSizePixel = 0
    sliderBack.ZIndex = 2
    sliderBack.Parent = main

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBack

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(defaultValue, 0, 1, 0)
    fill.BackgroundColor3 = ACCENT_COLOR
    fill.BorderSizePixel = 0
    fill.ZIndex = 3
    fill.Parent = sliderBack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill

    local dragging = false

    local function updateSlider(input)
        local relativeX = input.Position.X - sliderBack.AbsolutePosition.X
        local value = math.clamp(
            relativeX / sliderBack.AbsoluteSize.X,
            0,
            1
        )

        fill.Size = UDim2.new(value, 0, 1, 0)
        label.Text = labelText .. ": " .. string.format("%.2f", value)

        callback(value)
    end

    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            updateSlider(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging then
            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then

                updateSlider(input)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = false
        end
    end)
end

-- Прозрачность окна
createSlider("Window Transparency", 175, WINDOW_TRANSPARENCY, function(value)
    main.BackgroundTransparency = value
end)
-- Прозрачность изображения
createSlider("Image Transparency", 220, IMAGE_TRANSPARENCY, function(value)
    background.ImageTransparency = value
end)

-- Выбор цвета
local colorTitle = Instance.new("TextLabel")
colorTitle.Size = UDim2.new(1, -30, 0, 20)
colorTitle.Position = UDim2.new(0, 15, 0, 265)
colorTitle.BackgroundTransparency = 1
colorTitle.Text = "THEME COLOR"
colorTitle.TextColor3 = Color3.new(1, 1, 1)
colorTitle.Font = Enum.Font.Gotham
colorTitle.TextSize = 12
colorTitle.TextXAlignment = Enum.TextXAlignment.Left
colorTitle.ZIndex = 2
colorTitle.Parent = main

local colors = {
    Color3.fromRGB(120, 80, 255),
    Color3.fromRGB(0, 170, 255),
    Color3.fromRGB(0, 200, 130),
    Color3.fromRGB(255, 100, 120),
    Color3.fromRGB(255, 170, 0),
    Color3.fromRGB(240, 240, 240),
}

for i, color in ipairs(colors) do
    local colorButton = Instance.new("TextButton")
    colorButton.Name = "Color" .. i
    colorButton.Size = UDim2.new(0, 38, 0, 25)
    colorButton.Position = UDim2.new(0, 15 + ((i - 1) * 48), 0, 290)
    colorButton.BackgroundColor3 = color
    colorButton.Text = ""
    colorButton.BorderSizePixel = 0
    colorButton.ZIndex = 3
    colorButton.Parent = main

    local colorCorner = Instance.new("UICorner")
    colorCorner.CornerRadius = UDim.new(0, 6)
    colorCorner.Parent = colorButton

    colorButton.MouseButton1Click:Connect(function()
        ACCENT_COLOR = color
        stroke.Color = color
        divider.BackgroundColor3 = color
        startButton.BackgroundColor3 = color

        for _, child in ipairs(main:GetDescendants()) do
            if child:IsA("Frame") and child.Parent
                and child.Parent.Name == "SliderBack" then
                child.BackgroundColor3 = color
            end
        end
    end)
end

-- Перетаскивание окна
local draggingWindow = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingWindow = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingWindow then
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            local delta = input.Position - dragStart

            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        draggingWindow = false
    end
end)

-- Кнопки управления
local running = false

startButton.MouseButton1Click:Connect(function()
    running = true
    status.Text = "Status: Running"
    status.TextColor3 = Color3.fromRGB(100, 255, 150)

    -- Добавь сюда логику маршрута для своего Roblox-проекта.
end)

stopButton.MouseButton1Click:Connect(function()
    running = false
    status.Text = "Status: Stopped"
    status.TextColor3 = Color3.fromRGB(230, 230, 230)

    -- Здесь останови логику маршрута своего проекта.
end)

-- Закрытие и открытие
closeButton.MouseButton1Click:Connect(function()
    main.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.F6 then
        main.Visible = not main.Visible
    end
end)

print("KOT:3 Custom Route UI loaded!")
