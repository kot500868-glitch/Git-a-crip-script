local Players = game:GetService("Players")

local player = Players.LocalPlayer

local points = {
    Vector3.new(302, 1, -243),
    Vector3.new(338, 20, -1218),
    Vector3.new(221, 23, -9447),
    Vector3.new(137, 25, 9949),
}

local running = false
local character
local humanoid
local root

local TELEPORT_DELAY = 5
local PROMPT_SEARCH_DISTANCE = 15

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(160, 45)
button.Position = UDim2.fromOffset(20, 20)
button.Text = "START ROUTE"
button.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.TextSize = 16
button.Font = Enum.Font.GothamBold
button.Parent = gui

-- Получение персонажа
local function getCharacter()
    character = player.Character or player.CharacterAdded:Wait()

    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

-- Поиск ближайшего ProximityPrompt
local function findNearestPrompt()
    local _, _, rootPart = getCharacter()

    local nearestPrompt = nil
    local nearestDistance = PROMPT_SEARCH_DISTANCE

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("ProximityPrompt") and object.Enabled then
            local parent = object.Parent
            local part = nil

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

-- Телепорт и взаимодействие
local function teleportTo(target)
    local currentCharacter, currentHumanoid, currentRoot = getCharacter()

    if not running then
        return
    end

    currentCharacter:PivotTo(CFrame.new(target))

    currentRoot.AssemblyLinearVelocity = Vector3.zero
    currentRoot.AssemblyAngularVelocity = Vector3.zero

    task.wait(0.3)

    if not running then
        return
    end

    local prompt = findNearestPrompt()

    if prompt then
        -- Имитация удержания клавиши E для ProximityPrompt
        pcall(function()
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration)
            prompt:InputHoldEnd()
        end)
    end
end

-- Остановка маршрута
local function stopRoute()
    running = false

    button.Text = "START ROUTE"
    button.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
end

-- Задержка с возможностью остановки
local function waitDelay(seconds)
    local startTime = os.clock()

    while running and os.clock() - startTime < seconds do
        task.wait(0.05)
    end
end

-- Кнопка START / STOP
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
            for _, point in ipairs(points) do
                if not running then
                    break
                end

                teleportTo(point)
                waitDelay(TELEPORT_DELAY)
            end
        end

        stopRoute()
    end)
end)

-- Остановка при смерти персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter

    if running then
        stopRoute()
    end
end)
