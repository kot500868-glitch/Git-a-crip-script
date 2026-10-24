local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer

local points = {
    {position = Vector3.new(302, 1, -243), interact = true},
    {position = Vector3.new(338, 22, -1218), interact = true},
    {position = Vector3.new(221, 25, -9447), interact = true},
    {position = Vector3.new(215, 25, -1210), interact = false},
    {position = Vector3.new(137, 30, 9949), interact = true},
}

local running = false
local character
local humanoid
local root

local TELEPORT_DELAY = 10
local INTERACTION_INTERVAL = 2
local PROMPT_SEARCH_DISTANCE = 15

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(200, 45)
button.Position = UDim2.fromOffset(20, 20)
button.Text = "START ROUTE"
button.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
button.TextColor3 = Color3.new(1, 1, 1)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.Parent = gui

local function getCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

local function findNearestPrompt()
    local _, _, rootPart = getCharacter()

    local nearestPrompt
    local nearestDistance = PROMPT_SEARCH_DISTANCE

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Enabled then
            local parent = object.Parent
            local part

            if parent:IsA("BasePart") then
                part = parent
            elseif parent:IsA("Attachment") then
                part = parent.Parent
            end

            if part and part:IsA("BasePart") then
                local distance = (rootPart.Position - part.Position).Magnitude

                if distance <= nearestDistance then
                    nearestDistance = distance
                    nearestPrompt = object
                end
            end
        end
    end

    return nearestPrompt
end

local function teleportTo(point, index)
    local currentCharacter, currentHumanoid, currentRoot = getCharacter()

    if not running then
        return
    end

    button.Text = "POINT " .. index .. "/" .. #points

    currentCharacter:PivotTo(CFrame.new(point.position))

    currentRoot.AssemblyLinearVelocity = Vector3.zero
    currentRoot.AssemblyAngularVelocity = Vector3.zero

    task.wait(0.5)

    if not running then
        return
    end

    if not point.interact then
        print("Точка " .. index .. ": взаимодействие отключено")
        return
    end

    local prompt = findNearestPrompt()

    if prompt then
        print("Найден ProximityPrompt:", prompt:GetFullName())

        -- Взаимодействие с заказом должно обрабатываться
        -- серверным скриптом через ProximityPrompt.Triggered.
    else
        print("На точке " .. index .. " ProximityPrompt не найден")
    end
end

local function waitDelay(seconds)
    local startTime = os.clock()

    while running and os.clock() - startTime < seconds do
        task.wait(0.05)
    end
end

local function stopRoute()
    running = false

    button.Text = "START ROUTE"
    button.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
end

button.MouseButton1Click:Connect(function()
    if running then
        stopRoute()
        return
    end

    running = true

    button.Text = "STOP ROUTE"
    button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

    task.spawn(function()
        while running do
            for index, point in ipairs(points) do
                if not running then
                    break
                end

                teleportTo(point, index)
                waitDelay(TELEPORT_DELAY)
            end
        end

        stopRoute()
    end)
end)

player.CharacterAdded:Connect(function()
    if running then
        stopRoute()
    end
end)
