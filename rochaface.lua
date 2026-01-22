-- HigorGUI v2.0 - GUI tipo Minecraft Client (módulos flutuantes)
local HigorGUI = {}
HigorGUI.__index = HigorGUI

local UserInputService = game:GetService("UserInputService")

function HigorGUI.new(config)
    local self = setmetatable({}, HigorGUI)
    
    self.Title = config.Title or "HigorGUI"
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.G
    self.Enabled = true
    
    self.Windows = {}
    self.DraggingWindow = nil
    self.DragOffset = nil
    
    self:CreateMainUI()
    self:SetupInput()
    
    return self
end

function HigorGUI:CreateMainUI()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HigorGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    self.ScreenGui = screenGui
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
    
    -- Título (draggable)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 25)
    titleBar.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = windowFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Text = title:upper()
    titleText.Size = UDim2.new(1, -30, 1, 0)
    titleText.BackgroundTransparency = 1
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 12
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -25, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = titleBar
    
    closeBtn.MouseButton1Click:Connect(function()
        windowFrame.Visible = false
    end)
    
    -- Conteúdo
    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "Content"
    contentFrame.Size = UDim2.new(1, 0, 1, -25)
    contentFrame.Position = UDim2.new(0, 0, 0, 25)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = windowFrame
    
    -- Tornar draggable
    self:MakeDraggable(windowFrame, titleBar)
    
    local windowData = {
        Frame = windowFrame,
        TitleBar = titleBar,
        Content = contentFrame,
        Modules = {}
    }
    
    table.insert(self.Windows, windowData)
    return windowData
end

function HigorGUI:AddToggle(window, name, default, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name
    toggleFrame.Size = UDim2.new(1, -4, 0, 22)
    toggleFrame.Position = UDim2.new(0, 2, 0, (#window.Modules) * 24)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    toggleFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
    toggleFrame.BorderSizePixel = 1
    toggleFrame.Parent = window.Content
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle Button
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
    
    table.insert(window.Modules, toggleFrame)
    
    -- Ajustar altura da janela
    local newHeight = 25 + (#window.Modules * 24)
    window.Frame.Size = UDim2.new(0, window.Frame.Size.X.Offset, 0, newHeight)
end

function HigorGUI:AddButton(window, name, callback)
    local btnFrame = Instance.new("Frame")
    btnFrame.Name = name
    btnFrame.Size = UDim2.new(1, -4, 0, 22)
    btnFrame.Position = UDim2.new(0, 2, 0, (#window.Modules) * 24)
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
    
    table.insert(window.Modules, btnFrame)
    
    local newHeight = 25 + (#window.Modules * 24)
    window.Frame.Size = UDim2.new(0, window.Frame.Size.X.Offset, 0, newHeight)
end

function HigorGUI:MakeDraggable(frame, titleBar)
    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DraggingWindow = frame
            self.DragOffset = frame.Position - UDim2.new(0, input.Position.X, 0, input.Position.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DraggingWindow = nil
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.DraggingWindow and input.UserInputType == Enum.UserInputType.Mouse then
            self.DraggingWindow.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y) + self.DragOffset
        end
    end)
end

function HigorGUI:SetupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.ToggleKey then
            for _, window in ipairs(self.Windows) do
                window.Frame.Visible = not window.Frame.Visible
            end
            self.Enabled = self.Windows[1].Frame.Visible
        end
    end)
end

return HigorGUI
