local Players = game:GetService("Players")

local player = Players.LocalPlayer
local farming = false

-- Создание интерфейса
local gui = Instance.new("ScreenGui")
gui.Name = "FarmGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 160, 0, 50)
button.Position = UDim2.new(0.5, -80, 0.5, -25)
button.Text = "START FARM"
button.BackgroundColor3 = Color3.fromRGB(40, 170, 80)
button.TextColor3 = Color3.new(1, 1, 1)
button.Parent = gui

-- Пример маршрута
local route = {
    Vector3.new(302, 1, -243),
    Vector3.new(338, 20, -1218),
    Vector3.new(210, 23, -9447),
    Vector3.new(137, 25, 9947)
}

local function startFarm()
    if farming then
        return
    end

    farming = true
    button.Text = "FARMING..."

    while farming do
        local character = player.Character
            or player.CharacterAdded:Wait()

        local humanoid = character:WaitForChild("Humanoid")

        for _, position in ipairs(route) do
            if not farming then
                break
            end

            humanoid:MoveTo(position)
            humanoid.MoveToFinished:Wait()
        end

        task.wait(2)
    end

    button.Text = "START FARM"
end

button.MouseButton1Click:Connect(function()
    if farming then
        farming = false
        button.Text = "START FARM"
    else
        task.spawn(startFarm)
    end
end)
