local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local SPEED = 250
local ARRIVAL_RADIUS = 10

local points = {
    Vector3.new(391, 2, -1106),
    Vector3.new(302, 1, -243),
    Vector3.new(349, 2, -1092),
    Vector3.new(338, 20, -1218),
    Vector3.new(210, 23, -9447),
    Vector3.new(137, 25, 9947)
}

local running = false
local character
local humanoid
local root

local originalCollisions = {}
local noclipConnection

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(160, 45)
button.Position = UDim2.fromOffset(20, 20)
button.Text = "START ROUTE"
button.Parent = gui

-- Получение персонажа
local function getCharacter()
    character = player.Character or player.CharacterAdded:Wait()

    humanoid = character:WaitForChild("Humanoid")
    root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

-- Включение ноуклипа
local function enableNoclip()
    getCharacter()

    originalCollisions = {}

    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            originalCollisions[part] = part.CanCollide
            part.CanCollide = false
        end
    end

    if noclipConnection then
        noclipConnection:Disconnect()
    end

    noclipConnection = RunService.Stepped:Connect(function()
        if not running or not character then
            return
        end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end)
end

-- Выключение ноуклипа
local function disableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end

    for part, canCollide in pairs(originalCollisions) do
        if part and part.Parent then
            part.CanCollide = canCollide
        end
    end

    originalCollisions = {}
end

-- Полёт к точке
local function flyTo(target)
    local character, humanoid, root = getCharacter()

    local attachment = Instance.new("Attachment")
    attachment.Parent = root

    local velocity = Instance.new("LinearVelocity")
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.MaxForce = math.huge
    velocity.Parent = root

    local orientation = Instance.new("AlignOrientation")
    orientation.Attachment0 = attachment
    orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    orientation.Responsiveness = 10
    orientation.Parent = root

    humanoid:ChangeState(
        Enum.HumanoidStateType.Physics
    )

    while running and character.Parent do
        local direction = target - root.Position
        local distance = direction.Magnitude

        if distance <= ARRIVAL_RADIUS then
            break
        end

        velocity.VectorVelocity = direction.Unit * SPEED

        orientation.CFrame = CFrame.lookAt(
            root.Position,
            target
        )

        RunService.Heartbeat:Wait()
    end

    velocity:Destroy()
    orientation:Destroy()
    attachment:Destroy()

    if humanoid and humanoid.Parent then
        humanoid:ChangeState(
            Enum.HumanoidStateType.GettingUp
        )
    end
end

-- Остановка маршрута
local function stopRoute()
    running = false
    button.Text = "START ROUTE"

    disableNoclip()
end

-- Кнопка START / STOP
button.MouseButton1Click:Connect(function()
    if running then
        stopRoute()
        return
    end

    running = true
    button.Text = "STOP ROUTE"

    task.spawn(function()
        enableNoclip()

        for _, point in ipairs(points) do
            if not running then
                break
            end

            flyTo(point)

            if running then
                task.wait(1)
            end
        end

        stopRoute()
    end)
end)
-- Сброс при смерти персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter

    if running then
        stopRoute()
    end
end)
