-- HigorGUI v1.0 - GUI Library para Roblox
-- Layout: Topo com título e configs, centro com 3 colunas movíveis

local HigorGUI = {}
HigorGUI.__index = HigorGUI

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

function HigorGUI.new(config)
    local self = setmetatable({}, HigorGUI)
    
    self.Title = config.Title or "HigorGUI"
    self.ToggleKey = config.ToggleKey or Enum.KeyCode.G
    self.Enabled = true
    self.Dragging = false
    self.DragStart = nil
    self.DragOffset = nil
    
    self.Categories = {}
    self.Modules = {}
    
    self:CreateUI()
    self:SetupInput()
    
    return self
end

function HigorGUI:CreateUI()
    local player = game.Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    -- Main ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "HigorGUI"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    
    -- Main Frame (movível)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 1000, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -500, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    mainFrame.BorderColor3 = Color3.fromRGB(157, 78, 221)
    mainFrame.BorderSizePixel = 2
    mainFrame.Parent = screenGui
    
    -- Tornar movível
    self:MakeDraggable(mainFrame)
    
    -- ===== TOPO =====
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 50)
    topBar.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = self.Title
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Botão Fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 40, 0, 40)
    closeBtn.Position = UDim2.new(1, -45, 0.5, -20)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = topBar
    
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        self.Enabled = false
    end)
    
    -- ===== CONTEÚDO (3 COLUNAS) =====
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.Size = UDim2.new(1, 0, 1, -50)
    contentArea.Position = UDim2.new(0, 0, 0, 50)
    contentArea.BackgroundTransparency = 1
    contentArea.BorderSizePixel = 0
    contentArea.Parent = mainFrame
    
    -- Criar 3 colunas
    local columns = {"Combate", "Movimentos", "Visual"}
    for i, colName in ipairs(columns) do
        local col = self:CreateColumn(contentArea, colName, i - 1)
        self.Categories[colName] = col
    end
    
    -- Coluna Configurações (topo direito)
    local configCol = self:CreateConfigColumn(topBar)
    self.Categories["Configurações"] = configCol
    
    self.ScreenGui = screenGui
    self.MainFrame = mainFrame
end

function HigorGUI:CreateColumn(parent, name, index)
    local col = Instance.new("Frame")
    col.Name = name
    col.Size = UDim2.new(0.333, -2, 1, 0)
    col.Position = UDim2.new(index * 0.333, index * 2, 0, 0)
    col.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    col.BorderSizePixel = 0
    col.Parent = parent
    
    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 35)
    header.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
    header.BorderSizePixel = 0
    header.Parent = col
    
    local headerText = Instance.new("TextLabel")
    headerText.Text = name:upper()
    headerText.Size = UDim2.new(1, 0, 1, 0)
    headerText.BackgroundTransparency = 1
    headerText.TextColor3 = Color3.fromRGB(255, 255, 255)
    headerText.TextSize = 13
    headerText.Font = Enum.Font.GothamBold
    headerText.Parent = header
    
    -- ScrollFrame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "ScrollFrame"
    scroll.Size = UDim2.new(1, 0, 1, -35)
    scroll.Position = UDim2.new(0, 0, 0, 35)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(157, 78, 221)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.Parent = col
    
    -- UIListLayout
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.Parent = scroll
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
    end)
    
    return { Frame = col, ScrollFrame = scroll, Layout = layout }
end

function HigorGUI:CreateConfigColumn(parent)
    local configFrame = Instance.new("Frame")
    configFrame.Name = "ConfigFrame"
    configFrame.Size = UDim2.new(0, 150, 0, 50)
    configFrame.Position = UDim2.new(1, -160, 0, 0)
    configFrame.BackgroundTransparency = 1
    configFrame.BorderSizePixel = 0
    configFrame.Parent = parent
    
    return { Frame = configFrame, ScrollFrame = configFrame }
end

function HigorGUI:AddToggle(category, name, default, callback)
    if not self.Categories[category] then return end
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Name = name
    toggleFrame.Size = UDim2.new(1, -4, 0, 28)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    toggleFrame.BorderColor3 = Color3.fromRGB(100, 100, 120)
    toggleFrame.BorderSizePixel = 1
    toggleFrame.Parent = self.Categories[category].ScrollFrame
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Text = name
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 11
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Toggle Button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.Size = UDim2.new(0.4, -2, 1, -4)
    toggleBtn.Position = UDim2.new(0.6, 2, 0, 2)
    toggleBtn.BackgroundColor3 = default and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(150, 50, 50)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 10
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
    
    return state
end

function HigorGUI:AddButton(category, name, callback)
    if not self.Categories[category] then return end
    
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Text = name
    btn.Size = UDim2.new(1, -4, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    btn.BorderColor3 = Color3.fromRGB(100, 100, 120)
    btn.BorderSizePixel = 1
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.Parent = self.Categories[category].ScrollFrame
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.BorderColor3 = Color3.fromRGB(157, 78, 221)
    end)
    
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
        btn.BorderColor3 = Color3.fromRGB(100, 100, 120)
    end)
    
    btn.MouseButton1Click:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
        if callback then callback() end
        task.wait(0.1)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
end

function HigorGUI:MakeDraggable(frame)
    local titleBar = frame:FindFirstChild("TopBar") or frame
    
    titleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = true
            self.DragStart = input.Position
            self.DragOffset = frame.Position - UDim2.new(0, input.Position.X, 0, input.Position.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if self.Dragging and input.UserInputType == Enum.UserInputType.Mouse then
            frame.Position = UDim2.new(0, input.Position.X, 0, input.Position.Y) + self.DragOffset
        end
    end)
end

function HigorGUI:SetupInput()
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == self.ToggleKey then
            self.MainFrame.Visible = not self.MainFrame.Visible
            self.Enabled = self.MainFrame.Visible
        end
    end)
end

return HigorGUI
