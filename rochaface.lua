-- HigorGUI Simple - GUI funcional para Roblox
local HigorGUI = {}
HigorGUI.__index = HigorGUI

function HigorGUI.new(config)
    local self = setmetatable({}, HigorGUI)
    
    self.Title = config.Title or "HigorGUI"
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.G
    
    self.Windows = {}
    self.SavedPositions = {}
    self.DraggingWindow = nil
    self.GUIActive = false
    
    self:Init()
    
    return self
end

function HigorGUI:Init()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    self.ScreenGui = Instance.new("ScreenGui")
    self.ScreenGui.Name = "HigorGUI"
    self.ScreenGui.ResetOnSpawn = false
    self.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.ScreenGui.Parent = playerGui
    
    self:SetupInput()
end

function HigorGUI:CreateWindow(title, x, y, width, height)
    local windowFrame = Instance.new("Frame")
    windowFrame.Name = title
    windowFrame.Size = UDim2.new(0, width, 0, height)
    windowFrame.Position = UDim2.new(0, x, 0, y)
    windowFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    windowFrame.BorderColor3 = Color3.fromRGB(157, 78, 221)
    windowFrame.BorderSizePixel = 2
    windowFrame.Parent = self.ScreenGui
    
    self.SavedPositions[title] = {x = x, y = y}
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = windowFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = title:upper()
    titleText.Size = UDim2.new(1, 0, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 12
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Center
    titleText.Parent = titleBar
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -25)
    contentFrame.Position = UDim2.new(0, 0, 0, 25)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = windowFrame
    
    self:MakeDraggable(windowFrame, titleBar)
    
    local windowData = {
        Frame = windowFrame,
        TitleBar = titleBar,
        Content = contentFrame,
        Modules = {},
        Title = title,
        ModuleCount = 0
    }
    
    table.insert(self.Windows, windowData)
    return windowData
end

function HigorGUI:AddToggle(window, name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name
    toggleFrame.Size = UDim2.new(1, -4, 0, 22)
    toggleFrame.Position = UDim2.new(0, 2, 0, window.ModuleCount * 24)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    toggleFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
    toggleFrame.BorderSizePixel = 1
    toggleFrame.Parent = window.Content
    
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "Toggle"
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.Size = UDim2.new(0.45, -2, 1, -2)
    toggleBtn.Position = UDim2.new(0.55, 2, 0, 1)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 50, 50)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 9
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = toggleFrame
    
    local state = default
    
    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        toggleBtn.Text = state and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 50, 50)
        if callback then callback(state) end
    end)
    
    toggleBtn.MouseEnter:Connect(function()
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 120) or Color3.fromRGB(220, 70, 70)
    end)
    
    toggleBtn.MouseLeave:Connect(function()
        toggleBtn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(200, 50, 50)
    end)
    
    window.ModuleCount = window.ModuleCount + 1
    local newHeight = 25 + (window.ModuleCount * 24)
    window.Frame.Size = UDim2.new(0, window.Frame.Size.X.Offset, 0, newHeight)
    
    table.insert(window.Modules, toggleFrame)
end

function HigorGUI:AddButton(window, name, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Name = name
    btnFrame.Size = UDim2.new(1, -4, 0, 22)
    btnFrame.Position = UDim2.new(0, 2, 0, window.ModuleCount * 24)
    btnFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btnFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
    btnFrame.BorderSizePixel = 1
    btnFrame.Parent = window.Content
    
    local btn = Instance.new("TextButton")
    btn.Text = name
    btn.Size = UDim2.new(1, -2, 1, -2)
    btn.Position = UDim2.new(0, 1, 0, 1)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.BorderSizePixel = 0
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 10
    btn.Font = Enum.Font.Gotham
    btn.Parent = btnFrame
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    end)
    
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
        if callback then callback() end
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    
    window.ModuleCount = window.ModuleCount + 1
    local newHeight = 25 + (window.ModuleCount * 24)
    window.Frame.Size = UDim2.new(0, window.Frame.Size.X.Offset, 0, newHeight)
    
    table.insert(window.Modules, btnFrame)
end

function HigorGUI:MakeDraggable(frame, titleBar)
    local dragging = false
    local dragOffset = nil
    local self = self
    local UIS = game:GetService("UserInputService")
    local mouse = game.Players.LocalPlayer:GetMouse()
    
    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragOffset = frame.Position - UDim2.new(0, mouse.X, 0, mouse.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if dragging then
                self.SavedPositions[frame.Name] = {
                    x = frame.Position.X.Offset,
                    y = frame.Position.Y.Offset
                }
            end
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.Mouse then
            frame.Position = UDim2.new(0, mouse.X, 0, mouse.Y) + dragOffset
        end
    end)
end

function HigorGUI:SetupInput()
    game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.ToggleKey then
            self.GUIActive = not self.GUIActive
            
            for _, window in ipairs(self.Windows) do
                window.Frame.Visible = self.GUIActive
                
                if self.GUIActive and self.SavedPositions[window.Title] then
                    local pos = self.SavedPositions[window.Title]
                    window.Frame.Position = UDim2.new(0, pos.x, 0, pos.y)
                end
            end
        end
    end)
end

return HigorGUI
