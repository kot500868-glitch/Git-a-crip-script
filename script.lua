local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "FarmGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 45)
button.Position = UDim2.new(0, 20, 0, 20)
button.Text = "START FARM"
button.Parent = gui

-- Точки маршрута в твоей игре
local points = {
    Vector3.new(302, 1, -243),
    Vector3.new(338, 20, -1218),
    Vector3.new(210, 23, -9447),
    Vector3.new(137, 25, 9947)
}

local farming = false
local noclipConnection
local flyConnection

local function getCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

local function startNoClip()
    noclipConnection = RunService.Stepped:Connect(function()
        local character = player.Character

        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function stopNoClip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function flyTo(targetPosition, speed)
    local character, humanoid, root = getCharacter()

    humanoid.PlatformStand = true

    while farming and (root.Position - targetPosition).Magnitude > 5 do
        local direction = targetPosition - root.Position
        local distance = direction.Magnitude

        if distance > 0 then
            local step = math.min(speed * RunService.Heartbeat:Wait(), distance)
            root.CFrame = root.CFrame + direction.Unit * step
        end
    end

    humanoid.PlatformStand = false
end

button.MouseButton1Click:Connect(function()
    if farming then
        farming = false
        stopNoClip()
        button.Text = "START FARM"
        return
    end

    farming = true
    button.Text = "STOP FARM"

    startNoClip()

    task.spawn(function()
        for _, point in ipairs(points) do
            if not farming then
                break
            end

            flyTo(point, 80)

            -- Здесь можно добавить логику твоей игры,
            -- которая выполняется после прибытия к точке.
            task.wait(1)
        end

        farming = false
        stopNoClip()
        button.Text = "START FARM"
    end)
end)
