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

local TELEPORT_DELAY = 1

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
button.Parent = gui

-- Получение персонажа
local function getCharacter()
    character = player.Character or player.CharacterAdded:Wait()

    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

-- Телепорт к точке
local function teleportTo(target)
    local character, humanoid, root = getCharacter()

    if not running then
        return
    end

    root.CFrame = CFrame.new(target)

    -- Останавливаем движение
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
end

-- Остановка маршрута
local function stopRoute()
    running = false

    button.Text = "START ROUTE"
    button.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
end

-- START / STOP
button.MouseButton1Click:Connect(function()
    if running then
        stopRoute()
        return
    end

    running = true

    button.Text = "STOP ROUTE"
    button.BackgroundColor3 = Color3.fromRGB(200, 60, 60)

    task.spawn(function()
        for _, point in ipairs(points) do
            if not running then
                break
            end

            teleportTo(point)

            task.wait(TELEPORT_DELAY)
        end

        stopRoute()
    end)
end)

-- Остановка при смерти
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter

    if running then
        stopRoute()
    end
end)
