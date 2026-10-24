local Players = game:GetService("Players")

local player = Players.LocalPlayer

local points = {
    {position = Vector3.new(302, 1, -243), interact = true},
    {position = Vector3.new(338, 22, -1218), interact = true},
    {position = Vector3.new(221, 25, -9447), interact = true},
    {position = Vector3.new(215, 25, -1210), interact = false},
    {position = Vector3.new(137, 30, 9949), interact = true},
}

local running = false
local TELEPORT_DELAY = 10

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
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

local function teleportTo(point, index)
    if not running then
        return
    end

    local character, humanoid, root = getCharacter()

    button.Text = "POINT " .. index .. "/" .. #points

    character:PivotTo(CFrame.new(point.position))

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero

    task.wait(0.5)

    if not running then
        return
    end

    if point.interact then
        print("Точка " .. index .. ": требуется взаимодействие")
        -- Здесь вызывается серверная логика заказа.
    else
        print("Точка " .. index .. ": взаимодействие пропущено")
    end
end

local function waitDelay(seconds)
    local startTime = os.clock()

    while running and os.clock() - startTime < seconds do
        task.wait(0.1)
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
