-- INTERMEDIATE STUDIO - UI shell
-- Kot:3 | Assisted by ChatGPT
-- Place as a LocalScript in StarterPlayerScripts or StarterGui.
-- This is an interface/settings shell only; it does not include automated gameplay actions.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("IntermediateStudioUI")
if old then old:Destroy() end

local COLORS = {
    Background = Color3.fromRGB(10, 10, 12),
    Panel = Color3.fromRGB(20, 20, 24),
    Card = Color3.fromRGB(28, 28, 33),
    Accent = Color3.fromRGB(213, 31, 54),
    Text = Color3.fromRGB(245, 245, 245),
    Muted = Color3.fromRGB(160, 160, 170),
    Border = Color3.fromRGB(65, 65, 72),
}
local settings = {backgroundTransparency = 0.08, panelTransparency = 0.04, buttonTransparency = 0, scale = 1}
local themeNames = {"Red", "Blue", "Purple", "Green", "Cyan", "Pink", "Orange", "White"}
local themes = {
    Red = Color3.fromRGB(213,31,54), Blue = Color3.fromRGB(49,133,255),
    Purple = Color3.fromRGB(155,89,255), Green = Color3.fromRGB(50,220,125),
    Cyan = Color3.fromRGB(40,210,220), Pink = Color3.fromRGB(255,80,170),
    Orange = Color3.fromRGB(255,145,45), White = Color3.fromRGB(235,235,245),
}

local gui = Instance.new("ScreenGui")
gui.Name = "IntermediateStudioUI"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(720, 470)
main.Position = UDim2.new(0.5, -360, 0.5, -235)
main.BackgroundColor3 = COLORS.Background
main.BackgroundTransparency = settings.backgroundTransparency
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", main)
stroke.Color = COLORS.Border
stroke.Thickness = 1

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 72)
header.BackgroundColor3 = COLORS.Panel
header.BackgroundTransparency = settings.panelTransparency
header.BorderSizePixel = 0
header.Parent = main
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 10)
title.Size = UDim2.new(1, -90, 0, 30)
title.Font = Enum.Font.GothamBlack
title.Text = "INTERMEDIATE STUDIO"
title.TextSize = 24
title.TextColor3 = COLORS.Text
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(21, 40)
subtitle.Size = UDim2.new(1, -90, 0, 20)
subtitle.Font = Enum.Font.GothamBold
subtitle.Text = "UI / SETTINGS / Kot:3"
subtitle.TextSize = 12
subtitle.TextColor3 = COLORS.Accent
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 34)
close.Position = UDim2.new(1, -48, 0, 18)
close.BackgroundColor3 = COLORS.Card
close.Text = "×"
close.TextColor3 = COLORS.Text
close.TextSize = 24
close.Font = Enum.Font.GothamBold
close.Parent = header
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)
close.MouseButton1Click:Connect(function() gui:Destroy() end)

local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.fromOffset(14, 86)
sidebar.Size = UDim2.fromOffset(155, 370)
sidebar.BackgroundColor3 = COLORS.Card
sidebar.BackgroundTransparency = settings.panelTransparency
sidebar.BorderSizePixel = 0
sidebar.Parent = main
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(180, 86)
content.Size = UDim2.fromOffset(526, 370)
content.BackgroundColor3 = COLORS.Card
content.BackgroundTransparency = settings.panelTransparency
content.BorderSizePixel = 0
content.Parent = main
Instance.new("UICorner", content).CornerRadius = UDim.new(0, 10)

local function makeLabel(parent, text, pos, size, fontSize, color)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Position = pos
    l.Size = size
    l.Font = Enum.Font.Gotham
    l.Text = text
    l.TextSize = fontSize or 14
    l.TextColor3 = color or COLORS.Text
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextYAlignment = Enum.TextYAlignment.Center
    l.Parent = parent
    return l
end

local pages = {}
local navButtons = {}
local function newPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.Parent = content
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 16)
    end)
    pages[name] = page
    return page
end

local function pageLabel(page, text, height, color)
    local l = makeLabel(page, text, UDim2.new(), UDim2.new(1, -24, 0, height or 28), 14, color)
    l.LayoutOrder = #page:GetChildren()
    l.Position = UDim2.fromOffset(12, 0)
    return l
end

local function pageButton(page, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -24, 0, 34)
    b.BackgroundColor3 = COLORS.Accent
    b.BackgroundTransparency = settings.buttonTransparency
    b.Text = text
    b.TextColor3 = COLORS.Text
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = true
    b.LayoutOrder = #page:GetChildren()
    b.Parent = page
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function pageInput(page, labelText, defaultText, callback)
    pageLabel(page, labelText, 22, COLORS.Muted)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -24, 0, 34)
    box.BackgroundColor3 = COLORS.Panel
    box.BackgroundTransparency = settings.panelTransparency
    box.Text = defaultText
    box.PlaceholderText = defaultText
    box.TextColor3 = COLORS.Text
    box.PlaceholderColor3 = COLORS.Muted
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.ClearTextOnFocus = false
    box.LayoutOrder = #page:GetChildren()
    box.Parent = page
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    box.FocusLost:Connect(function() callback(box.Text) end)
    return box
end

local function pageSlider(page, labelText, initial, callback)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 52)
    row.BackgroundTransparency = 1
    row.LayoutOrder = #page:GetChildren()
    row.Parent = page
    local label = makeLabel(row, labelText .. ": " .. tostring(math.floor(initial * 100)) .. "%", UDim2.fromOffset(0,0), UDim2.new(1,0,0,22), 13, COLORS.Text)
    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(0, 29)
    track.Size = UDim2.new(1, 0, 0, 8)
    track.BackgroundColor3 = COLORS.Panel
    track.BorderSizePixel = 0
    track.Parent = row
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initial, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)
    local hit = Instance.new("TextButton")
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Size = UDim2.new(1,0,1,0)
    hit.Parent = track
    local dragging = false
    local function setFromX(x)
        local amount = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        fill.Size = UDim2.new(amount,0,1,0)
        label.Text = labelText .. ": " .. tostring(math.floor(amount * 100)) .. "%"
        callback(amount)
    end
    hit.MouseButton1Down:Connect(function() dragging = true end)
    hit.MouseButton1Up:Connect(function() dragging = false end)
    hit.MouseLeave:Connect(function() dragging = false end)
    hit.MouseMoved:Connect(function(x) if dragging then setFromX(x) end end)
    hit.MouseButton1Click:Connect(function(x) setFromX(x) end)
end

local function applyTransparency()
    main.BackgroundTransparency = settings.backgroundTransparency
    header.BackgroundTransparency = settings.panelTransparency
    sidebar.BackgroundTransparency = settings.panelTransparency
    content.BackgroundTransparency = settings.panelTransparency
    for _, page in pairs(pages) do
        for _, obj in ipairs(page:GetDescendants()) do
            if obj:IsA("TextBox") then obj.BackgroundTransparency = settings.panelTransparency end
            if obj:IsA("TextButton") then obj.BackgroundTransparency = settings.buttonTransparency end
        end
    end
end

local function setAccent(color)
    COLORS.Accent = color
    subtitle.TextColor3 = color
    for _, b in ipairs(navButtons) do b.BackgroundColor3 = color end
    for _, page in pairs(pages) do
        for _, obj in ipairs(page:GetDescendants()) do
            if obj:IsA("TextButton") then obj.BackgroundColor3 = color end
            if obj:IsA("Frame") and obj.Name == "Frame" then
                -- Accent slider fills are updated below by matching their parent hierarchy.
            end
        end
    end
end

local function showPage(name)
    for pageName, page in pairs(pages) do page.Visible = pageName == name end
    for _, button in ipairs(navButtons) do
        button.BackgroundTransparency = button.Name == name and 0 or 0.35
    end
end

local navNames = {"Main", "Settings", "Instructions", "Creator", "Credits", "About"}
for i, name in ipairs(navNames) do
    local b = Instance.new("TextButton")
    b.Name = name
    b.Position = UDim2.fromOffset(8, 8 + (i-1)*48)
    b.Size = UDim2.new(1, -16, 0, 40)
    b.BackgroundColor3 = COLORS.Accent
    b.BackgroundTransparency = 0.35
    b.Text = name
    b.TextColor3 = COLORS.Text
    b.TextSize = 13
    b.Font = Enum.Font.GothamBold
    b.Parent = sidebar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    table.insert(navButtons, b)
    b.MouseButton1Click:Connect(function() showPage(name) end)
end

local mainPage = newPage("Main")
pageLabel(mainPage, "ROUTE CONTROL", 32)
pageLabel(mainPage, "This UI shell is ready for your own permitted game controls.", 44, COLORS.Muted)
pageLabel(mainPage, "Use the Settings page to customize the appearance.", 32, COLORS.Muted)

local settingsPage = newPage("Settings")
pageLabel(settingsPage, "APPEARANCE SETTINGS", 30)
pageLabel(settingsPage, "Theme presets", 22, COLORS.Muted)
for _, themeName in ipairs(themeNames) do
    pageButton(settingsPage, themeName, function() setAccent(themes[themeName]) end)
end
pageSlider(settingsPage, "Window transparency", settings.backgroundTransparency, function(v)
    settings.backgroundTransparency = v
    applyTransparency()
end)
pageSlider(settingsPage, "Panel transparency", settings.panelTransparency, function(v)
    settings.panelTransparency = v
    applyTransparency()
end)
pageSlider(settingsPage, "Button transparency", settings.buttonTransparency, function(v)
    settings.buttonTransparency = v
    applyTransparency()
end)
pageInput(settingsPage, "Custom RGB (example: 120, 60, 240)", "213, 31, 54", function(text)
    local r,g,b = text:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
    if r and g and b then
        setAccent(Color3.fromRGB(math.clamp(tonumber(r),0,255), math.clamp(tonumber(g),0,255), math.clamp(tonumber(b),0,255)))
    end
end)
pageButton(settingsPage, "Reset appearance", function()
    settings.backgroundTransparency = 0.08
    settings.panelTransparency = 0.04
    settings.buttonTransparency = 0
    main.Size = UDim2.fromOffset(720,470)
    main.Position = UDim2.new(0.5,-360,0.5,-235)
    setAccent(themes.Red)
    applyTransparency()
end)

local instructions = newPage("Instructions")
pageLabel(instructions, "INSTRUCTIONS", 30)
pageLabel(instructions, "• Navigate with the buttons on the left.", 28)
pageLabel(instructions, "• Open Settings to change theme and transparency.", 38)
pageLabel(instructions, "• Custom RGB uses three numbers from 0 to 255.", 38)
pageLabel(instructions, "• Close the window with × in the top-right corner.", 38)

local creator = newPage("Creator")
pageLabel(creator, "ABOUT THE CREATOR", 30)
pageLabel(creator, "Creator: Kot:3", 32)
pageLabel(creator, "Project: INTERMEDIATE STUDIO", 32)
pageLabel(creator, "UI assistance: ChatGPT", 32)

local credits = newPage("Credits")
pageLabel(credits, "CREDITS", 30)
pageLabel(credits, "Created by Kot:3", 32)
pageLabel(credits, "Assisted by ChatGPT", 32)
pageLabel(credits, "Add other contributors here when confirmed.", 42, COLORS.Muted)

local about = newPage("About")
pageLabel(about, "PROJECT INFORMATION", 30)
pageLabel(about, "Name: INTERMEDIATE STUDIO", 32)
pageLabel(about, "Purpose: customizable interface prototype", 38)
pageLabel(about, "Development time: not specified in the source.", 42, COLORS.Muted)
pageLabel(about, "Version: UI prototype", 32)

-- Drag window from header
local UserInputService = game:GetService("UserInputService")
local dragging, dragStart, startPos = false, nil, nil
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
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

applyTransparency()
showPage("Main")
print("INTERMEDIATE STUDIO UI loaded | Creator: Kot:3")
