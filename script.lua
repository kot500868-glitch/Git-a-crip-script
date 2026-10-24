local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local SPEED = 40
local ARRIVAL_RADIUS = 5

local points = {
    Vector3.new(302, 1, -243),
    Vector3.new(338, 20, -1218),
    Vector3.new(210, 23, -9447),
    Vector3.new(137, 25, 9947)
}

local running = false

local gui = Instance.new("ScreenGui")
gui.Name = "WaypointGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.fromOffset(160, 45)
button.Position = UDim2.fromOffset(20, 20)
button.Text = "START ROUTE"
button.Parent = gui

local function getCharacter()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")

    return character, humanoid, root
end

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

    humanoid:ChangeState(Enum.HumanoidStateType.Physics)

    while running do
        local direction = target - root.Position
        local distance = direction.Magnitude

        if distance <= ARRIVAL_RADIUS then
            break
        end

        velocity.VectorVelocity = direction.Unit * SPEED
        orientation.CFrame = CFrame.lookAt(root.Position, target)

        RunService.Heartbeat:Wait()
    end

    velocity:Destroy()
    orientation:Destroy()
    attachment:Destroy()

    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
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

                flyTo(point)
                task.wait(1)
            end

            running = false
            button.Text = "START ROUTE"
        end)
    else
        button.Text = "START ROUTE"
    end
end)
