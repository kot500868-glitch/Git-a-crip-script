--========================================================
-- KOT:3 ROUTE MENU — INTERFACE
-- LocalScript | StarterPlayerScripts
--========================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--========================================================
-- CONFIG
--========================================================

local CONFIG = {
    Creator = "Kot:3",
    AssistedBy = "ChatGPT",
    Version = "1.0",

    OpenKey = Enum.KeyCode.RightShift,

    Width = 560,
    Height = 390,

    Transparency = 0,
    TextSize = 13,
}

--========================================================
-- COLORS
--========================================================

local COLORS = {
    Background = Color3.fromRGB(22, 24, 31),
    Header = Color3.fromRGB(32, 35, 45),
    Sidebar = Color3.fromRGB(27, 29, 38),
    Element = Color3.fromRGB(42, 46, 59),
    Accent = Color3.fromRGB(90, 125, 190),
    Green = Color3.fromRGB(50, 145, 90),
    Red = Color3.fromRGB(160, 65, 65),
    Text = Color3.fromRGB(240, 240, 245),
    Muted = Color3.fromRGB(155, 160, 175),
}

--========================================================
-- GUI
--========================================================

local gui = Instance.new("ScreenGui")
gui.Name = "Kot3RouteMenu"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
main.Position = UDim2.new(0.5, -CONFIG.Width / 2, 0.5, -CONFIG.Height / 2)
main.BackgroundColor3 = COLORS.Background
main.BackgroundTransparency = CONFIG.Transparency
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

--========================================================
-- HELPERS
--========================================================

local function corner(object, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = object
    return c
end

local function label(parent, text, size, position, textSize)
    local object = Instance.new("TextLabel")
    object.Size = size
    object.Position = position
    object.BackgroundTransparency = 1
    object.Text = text
    object.TextColor3 = COLORS.Text
    object.Font = Enum.Font.Gotham
    object.TextSize = textSize or CONFIG.TextSize
    object.TextWrapped = true
    object.TextXAlignment = Enum.TextXAlignment.Left
    object.Parent = parent

    return object
end

local function button(parent, text, size, position, color)
    local object = Instance.new("TextButton")
    object.Size = size
    object.Position = position
    object.BackgroundColor3 = color or COLORS.Element
    object.Text = text
    object.TextColor3 = COLORS.Text
    object.Font = Enum.Font.GothamSemibold
    object.TextSize = CONFIG.TextSize
    object.AutoButtonColor = true
    object.Parent = parent

    corner(object, 6)

    return object
end

local function textbox(parent, placeholder, size, position, value)
    local object = Instance.new("TextBox")
    object.Size = size
    object.Position = position
    object.BackgroundColor3 = COLORS.Element
    object.TextColor3 = COLORS.Text
    object.PlaceholderColor3 = COLORS.Muted
    object.PlaceholderText = placeholder
    object.Text = tostring(value or "")
    object.Font = Enum.Font.Gotham
    object.TextSize = CONFIG.TextSize
    object.ClearTextOnFocus = false
    object.Parent = parent

    corner(object, 6)

    return object
end

--========================================================
-- HEADER
--========================================================

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = COLORS.Header
header.BorderSizePixel = 0
header.Parent = main

corner(header, 10)
label(
    header,
    "KOT:3  |  ROUTE MENU",
    UDim2.new(1, -120, 1, 0),
    UDim2.fromOffset(14, 0),
    15
)

local minimizeButton = button(
    header,
    "—",
    UDim2.fromOffset(30, 28),
    UDim2.new(1, -75, 0, 7)
)

local closeButton = button(
    header,
    "×",
    UDim2.fromOffset(30, 28),
    UDim2.new(1, -38, 0, 7),
    COLORS.Red
)

--========================================================
-- DRAG WINDOW
--========================================================

local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

--========================================================
-- SIDEBAR
--========================================================

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 135, 1, -42)
sidebar.Position = UDim2.fromOffset(0, 42)
sidebar.BackgroundColor3 = COLORS.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.Padding = UDim.new(0, 5)
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 10)
sidebarPadding.PaddingLeft = UDim.new(0, 8)
sidebarPadding.PaddingRight = UDim.new(0, 8)
sidebarPadding.Parent = sidebar

--========================================================
-- PAGE CONTAINER
--========================================================

local pageContainer = Instance.new("Frame")
pageContainer.Size = UDim2.new(1, -145, 1, -52)
pageContainer.Position = UDim2.fromOffset(140, 47)
pageContainer.BackgroundTransparency = 1
pageContainer.Parent = main

local pages = {}
local pageButtons = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.fromOffset(0, 0)
    page.Visible = false
    page.Parent = pageContainer

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.fromOffset(
            0,
            layout.AbsoluteContentSize.Y + 10
        )
    end)

    pages[name] = page

    local tab = button(
        sidebar,
        name,
        UDim2.new(1, 0, 0, 30),
        UDim2.new(),
        COLORS.Element
    )

    pageButtons[name] = tab

    return page
end

local function showPage(name)
    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end

    for pageName, tab in pairs(pageButtons) do
        tab.BackgroundColor3 =
            pageName == name and COLORS.Accent or COLORS.Element
    end
end

--========================================================
-- PAGE ELEMENTS
--========================================================

local function pageLabel(parent, text)
    return label(
        parent,
        text,
        UDim2.new(1, -12, 0, 28),
        UDim2.new(),
        14
    )
end
local function pageButton(parent, text, color, callback)
    local object = button(
        parent,
        text,
        UDim2.new(1, -12, 0, 32),
        UDim2.new(),
        color
    )

    object.MouseButton1Click:Connect(callback)

    return object
end

local function pageTextBox(parent, placeholder, value, callback)
    local object = textbox(
        parent,
        placeholder,
        UDim2.new(1, -12, 0, 30),
        UDim2.new(),
        value
    )

    object.FocusLost:Connect(function()
        callback(object.Text)
    end)

    return object
end

--========================================================
-- HOME PAGE
--========================================================

local homePage = createPage("Главная")

pageLabel(homePage, "Добро пожаловать в Kot:3 Route Menu")

local status = pageLabel(homePage, "Статус: остановлен")

pageButton(homePage, "Запустить маршрут", COLORS.Green, function()
    if typeof(runRoute) == "function" then
        runRoute()
        status.Text = "Статус: запущен"
    else
        status.Text = "Функция runRoute не подключена"
    end
end)

pageButton(homePage, "Остановить маршрут", COLORS.Red, function()
    if typeof(stopRoute) == "function" then
        stopRoute()
        status.Text = "Статус: остановлен"
    else
        status.Text = "Функция stopRoute не подключена"
    end
end)

--========================================================
-- ROUTE PAGE
--========================================================

local routePage = createPage("Маршрут")

pageLabel(routePage, "Настройки маршрута")

pageButton(routePage, "Добавить текущую позицию", COLORS.Green, function()
    if typeof(getCurrentPosition) ~= "function" then
        return
    end

    local position = getCurrentPosition()

    if position and typeof(route) == "table" then
        table.insert(route, position)
    end
end)

pageButton(routePage, "Удалить последнюю точку", COLORS.Red, function()
    if typeof(route) == "table" and #route > 0 then
        table.remove(route, #route)
    end
end)

pageButton(routePage, "Очистить маршрут", COLORS.Red, function()
    if typeof(route) == "table" then
        table.clear(route)
    end
end)

--========================================================
-- AUTO E PAGE
--========================================================

local autoPage = createPage("Авто-E")

pageLabel(autoPage, "Настройки взаимодействия")

pageLabel(autoPage, "Авто-взаимодействие можно подключить к механике ProximityPrompt твоей игры.")

--========================================================
-- SETTINGS PAGE
--========================================================

local settingsPage = createPage("Настройки")

pageLabel(settingsPage, "Настройки маршрута")

pageTextBox(settingsPage, "Задержка между точками", "3", function(value)
    local delayValue = tonumber(value)

    if delayValue and typeof(SETTINGS) == "table" then
        SETTINGS.Delay = math.clamp(delayValue, 0, 120)
    end
end)

--========================================================
-- INTERFACE PAGE
--========================================================

local interfacePage = createPage("Интерфейс")

pageLabel(interfacePage, "Настройки интерфейса")

pageButton(interfacePage, "Скрыть / показать меню", COLORS.Accent, function()
    main.Visible = not main.Visible
end)

pageButton(interfacePage, "Изменить прозрачность", COLORS.Element, function()
    CONFIG.Transparency = CONFIG.Transparency == 0 and 0.35 or 0
    main.BackgroundTransparency = CONFIG.Transparency
end)

--========================================================
-- SIZE PAGE
--========================================================

local sizePage = createPage("Размер")

pageLabel(sizePage, "Размер окна")

pageTextBox(sizePage, "Ширина", CONFIG.Width, function(value)
    local width = tonumber(value)

    if width then
        CONFIG.Width = math.clamp(width, 400, 900)
        main.Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
    end
end)

pageTextBox(sizePage, "Высота", CONFIG.Height, function(value)
    local height = tonumber(value)
if height then
        CONFIG.Height = math.clamp(height, 300, 700)
        main.Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
    end
end)

pageButton(sizePage, "Стандартный размер", COLORS.Element, function()
    CONFIG.Width = 560
    CONFIG.Height = 390
    main.Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height)
end)

--========================================================
-- INSTRUCTIONS PAGE
--========================================================

local instructionPage = createPage("Инструкция")

pageLabel(instructionPage, "Как пользоваться")

pageLabel(instructionPage, "1. Открой страницу «Маршрут».")

pageLabel(instructionPage, "2. Добавь нужные позиции персонажа.")

pageLabel(instructionPage, "3. Настрой задержку на странице «Настройки».")

pageLabel(instructionPage, "4. Запусти маршрут на главной странице.")

pageLabel(instructionPage, "5. Для остановки нажми кнопку остановки.")

pageLabel(instructionPage, "6. В «Размер» можно изменить размер меню.")

pageLabel(instructionPage, "7. В «Интерфейс» находятся параметры внешнего вида.")

--========================================================
-- INFORMATION PAGE
--========================================================

local infoPage = createPage("Информация")

pageLabel(infoPage, "Kot:3 Route Menu")

pageLabel(infoPage, "Создатель скрипта: " .. CONFIG.Creator)

pageLabel(infoPage, "Помогал: " .. CONFIG.AssistedBy)

pageLabel(infoPage, "Версия: " .. CONFIG.Version)

pageLabel(infoPage, "Назначение: настройка маршрутов в собственной Roblox-игре.")

--========================================================
-- TAB CONNECTIONS
--========================================================

for name, tab in pairs(pageButtons) do
    tab.MouseButton1Click:Connect(function()
        showPage(name)
    end)
end

--========================================================
-- MINIMIZE / CLOSE
--========================================================

local minimized = false

minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized

    pageContainer.Visible = not minimized
    sidebar.Visible = not minimized

    main.Size = minimized
        and UDim2.fromOffset(CONFIG.Width, 42)
        or UDim2.fromOffset(CONFIG.Width, CONFIG.Height)

    minimizeButton.Text = minimized and "+" or "—"
end)

closeButton.MouseButton1Click:Connect(function()
    gui.Enabled = false
end)

--========================================================
-- OPEN KEY
--========================================================

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == CONFIG.OpenKey then
        gui.Enabled = not gui.Enabled
    end
end)

--========================================================
-- INIT
--========================================================

showPage("Главная")

print("Kot:3 Route Menu loaded")
print("RightShift - Show / Hide")
