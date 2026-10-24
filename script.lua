local player = game.Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "MyScript"
gui.Parent = player.PlayerGui

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 150, 0, 50)
button.Position = UDim2.new(0.5, -75, 0.5, -25)
button.Text = "Start"
button.Parent = gui

button.MouseButton1Click:Connect(function()
    print("Скрипт запущен!")
end)
