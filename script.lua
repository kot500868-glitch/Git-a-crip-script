local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local SPEED = 20       -- скорость полёта
local ARRIVAL_RADIUS = 5

local points = {
    Vector3.new(302, 1, -243),
    Vector3.new(338, 20, -1218),
    Vector3.new(210, 23, -9447),
    Vector3.new(137, 25, 9947)
}

local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(160, 45)
button.Position = UDim2.fromOffset(20, 20)
button.Text = "START ROUTE"
button.Parent = gui

local running = false
local movementConnection

local function getRoot()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

local function moveToPoint(target)
    local root = getRoot()

    while running do
        local delta = target - root.Position
        local distance = delta.Magnitude

        if distance <= ARRIVAL_RADIUS then
            return true
        end

        local dt = RunService.Heartbeat:Wait()
        local step = math.min(SPEED * dt, distance)

        root.CFrame = root.CFrame + delta.Unit * step
    end

    return false
end

button.MouseButton1Click:Connect(function()
    running = not running

    if running then
        button.Text = "STOP ROUTE"

        task.spawn(function()
            for _, point in ipairs(points) do
                if not running then
                    break
                end

                local arrived = moveToPoint(point)

                if not arrived then
                    break
                end

                task.wait(1)
            end

            running = false
            button.Text = "START ROUTE"
        end)
    else
        button.Text = "START ROUTE"
    end
end)
