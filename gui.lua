-- Manus GUI Library V1
-- Uma biblioteca modular para criação de cheats estilo Minecraft no Roblox

local Library = {}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Configurações Internas
Library.OpenKey = Enum.KeyCode.Insert
Library.RemoveKey = Enum.KeyCode.K
Library.Categories = {}
Library.SettingsOpen = false

-- Criar ScreenGui Principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ManusGuiLib"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function() ScreenGui.Parent = CoreGui end)
if not success then ScreenGui.Parent = player:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui

-- Funções Utilitárias Internas
local function makeDraggable(frame, dragHandle)
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 400, 0, 40)
TopBar.Position = UDim2.new(0.5, -200, 0, 20)
TopBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 6)

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.8, -10, 0.7, 0)
SearchBox.Position = UDim2.new(0.05, 0, 0.15, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SearchBox.PlaceholderText = "Pesquisar módulos..."
SearchBox.Text = ""
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.Font = Enum.Font.SourceSans
SearchBox.TextSize = 16
SearchBox.Parent = TopBar

local SettingsBtn = Instance.new("TextButton")
SettingsBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
SettingsBtn.Position = UDim2.new(0.87, 0, 0.15, 0)
SettingsBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsBtn.Text = "⚙️"
SettingsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsBtn.TextSize = 20
SettingsBtn.Parent = TopBar

-- Tela de Configurações (Keybinds)
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 350, 0, 300)
SettingsFrame.Position = UDim2.new(0.5, -175, 0.5, -150)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame
Instance.new("UICorner", SettingsFrame)

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, 0, 0, 40)
SettingsTitle.Text = "Configurações & Keybinds"
SettingsTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SettingsTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SettingsTitle.Font = Enum.Font.SourceSansBold
SettingsTitle.TextSize = 20
SettingsTitle.Parent = SettingsFrame

local CloseSettings = Instance.new("TextButton")
CloseSettings.Size = UDim2.new(0, 40, 0, 40)
CloseSettings.Position = UDim2.new(1, -40, 0, 0)
CloseSettings.Text = "X"
CloseSettings.TextColor3 = Color3.fromRGB(255, 50, 50)
CloseSettings.BackgroundTransparency = 1
CloseSettings.TextSize = 20
CloseSettings.Parent = SettingsFrame

local KeybindContainer = Instance.new("ScrollingFrame")
KeybindContainer.Size = UDim2.new(1, 0, 1, -40)
KeybindContainer.Position = UDim2.new(0, 0, 0, 40)
KeybindContainer.BackgroundTransparency = 1
KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
KeybindContainer.ScrollBarThickness = 2
KeybindContainer.Parent = SettingsFrame

local KeybindList = Instance.new("UIListLayout")
KeybindList.Padding = UDim.new(0, 5)
KeybindList.HorizontalAlignment = Enum.HorizontalAlignment.Center
KeybindList.Parent = KeybindContainer

-- Função para adicionar Keybind na Settings
function Library:AddKeybind(label, defaultKey, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0.9, 0, 0, 35)
    Frame.BackgroundTransparency = 1
    Frame.Parent = KeybindContainer
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(0.6, 0, 1, 0)
    TextLabel.Text = label
    TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    TextLabel.Font = Enum.Font.SourceSans
    TextLabel.TextSize = 16
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.BackgroundTransparency = 1
    TextLabel.Parent = Frame
    
    local BindBtn = Instance.new("TextButton")
    BindBtn.Size = UDim2.new(0.35, 0, 0.8, 0)
    BindBtn.Position = UDim2.new(0.65, 0, 0.1, 0)
    BindBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    BindBtn.Text = defaultKey.Name
    BindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BindBtn.Font = Enum.Font.SourceSansBold
    BindBtn.Parent = Frame
    
    local binding = false
    BindBtn.MouseButton1Click:Connect(function()
        binding = true
        BindBtn.Text = "..."
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            binding = false
            BindBtn.Text = input.KeyCode.Name
            callback(input.KeyCode)
        end
    end)
    
    KeybindContainer.CanvasSize = UDim2.new(0, 0, 0, KeybindList.AbsoluteContentSize.Y + 10)
end

-- Lógica de Settings
SettingsBtn.MouseButton1Click:Connect(function()
    Library.SettingsOpen = not Library.SettingsOpen
    SettingsFrame.Visible = Library.SettingsOpen
    for _, cat in pairs(Library.Categories) do
        cat.Visible = not Library.SettingsOpen
    end
end)

CloseSettings.MouseButton1Click:Connect(function()
    Library.SettingsOpen = false
    SettingsFrame.Visible = false
    for _, cat in pairs(Library.Categories) do
        cat.Visible = true
    end
end)

-- Função para criar Categoria
function Library:CreateCategory(name, position)
    local CategoryFrame = Instance.new("Frame")
    CategoryFrame.Name = name
    CategoryFrame.Size = UDim2.new(0, 150, 0, 30)
    CategoryFrame.Position = position
    CategoryFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    CategoryFrame.BorderSizePixel = 0
    CategoryFrame.Active = true
    CategoryFrame.Parent = MainFrame
    
    local Title = Instance.new("TextButton")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 18
    Title.BackgroundTransparency = 1
    Title.AutoButtonColor = false
    Title.Parent = CategoryFrame
    
    local OptionsFrame = Instance.new("Frame")
    OptionsFrame.Name = "Options"
    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
    OptionsFrame.Position = UDim2.new(0, 0, 1, 0)
    OptionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    OptionsFrame.BorderSizePixel = 0
    OptionsFrame.ClipsDescendants = true
    OptionsFrame.Parent = CategoryFrame
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = OptionsFrame
    
    makeDraggable(CategoryFrame, Title)
    
    local categoryObj = { Frame = CategoryFrame, Options = OptionsFrame, Expanded = true }
    table.insert(Library.Categories, CategoryFrame)
    
    Title.MouseButton2Click:Connect(function()
        categoryObj.Expanded = not categoryObj.Expanded
        OptionsFrame.Visible = categoryObj.Expanded
    end)
    
    -- Função para adicionar Módulo
    function categoryObj:AddModule(moduleName, config)
        config = config or {}
        local moduleObj = { Enabled = false }
        
        local ModuleContainer = Instance.new("Frame")
        ModuleContainer.Size = UDim2.new(1, 0, 0, 25)
        ModuleContainer.BackgroundTransparency = 1
        ModuleContainer.Parent = OptionsFrame
        
        local ModuleBtn = Instance.new("TextButton")
        ModuleBtn.Size = UDim2.new(1, 0, 0, 25)
        ModuleBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        ModuleBtn.BorderSizePixel = 0
        ModuleBtn.Text = "  " .. moduleName
        ModuleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        ModuleBtn.Font = Enum.Font.SourceSans
        ModuleBtn.TextSize = 16
        ModuleBtn.TextXAlignment = Enum.TextXAlignment.Left
        ModuleBtn.Parent = ModuleContainer
        
        local SubFrame = Instance.new("Frame")
        SubFrame.Size = UDim2.new(1, 0, 0, 0)
        SubFrame.Position = UDim2.new(0, 0, 0, 25)
        SubFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        SubFrame.BorderSizePixel = 0
        SubFrame.Visible = false
        SubFrame.ClipsDescendants = true
        SubFrame.Parent = ModuleContainer
        Instance.new("UIListLayout", SubFrame)
        
        -- Lógica de Ativação
        ModuleBtn.MouseButton1Click:Connect(function()
            moduleObj.Enabled = not moduleObj.Enabled
            ModuleBtn.TextColor3 = moduleObj.Enabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(200, 200, 200)
            if config.callback then config.callback(moduleObj.Enabled) end
        end)
        
        -- Lógica de Sub-opções (Botão Direito)
        ModuleBtn.MouseButton2Click:Connect(function()
            SubFrame.Visible = not SubFrame.Visible
            local subHeight = SubFrame.Visible and (#SubFrame:GetChildren() - 1) * 20 or 0
            SubFrame.Size = UDim2.new(1, 0, 0, subHeight)
            ModuleContainer.Size = UDim2.new(1, 0, 0, 25 + subHeight)
            
            -- Recalcular altura da categoria
            local total = 0
            for _, v in pairs(OptionsFrame:GetChildren()) do
                if v:IsA("Frame") then total = total + v.Size.Y.Offset end
            end
            OptionsFrame.Size = UDim2.new(1, 0, 0, total)
        end)
        
        -- Função para adicionar Sub-opções (Sliders, Toggles, etc futuramente)
        function moduleObj:AddSubAction(name, type)
            local SubBtn = Instance.new("TextButton")
            SubBtn.Size = UDim2.new(1, 0, 0, 20)
            SubBtn.BackgroundTransparency = 1
            SubBtn.Text = "    > " .. name .. (type and " ["..type.."]" or "")
            SubBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
            SubBtn.Font = Enum.Font.SourceSans
            SubBtn.TextSize = 12
            SubBtn.TextXAlignment = Enum.TextXAlignment.Left
            SubBtn.Parent = SubFrame
            return SubBtn
        end
        
        -- Adicionar Keybind automático se solicitado
        if config.hasKeybind then
            Library:AddKeybind("Módulo: " .. moduleName, config.defaultKey or Enum.KeyCode.Unknown, function(key)
                print("Keybind para " .. moduleName .. " alterado para: " .. key.Name)
            end)
        end
        
        OptionsFrame.Size = UDim2.new(1, 0, 0, (#OptionsFrame:GetChildren() - 1) * 25)
        return moduleObj
    end
    
    return categoryObj
end

-- Atalhos Globais
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Library.OpenKey then
            MainFrame.Visible = not MainFrame.Visible
            local ModalBtn = Instance.new("TextButton", MainFrame)
            ModalBtn.Size = UDim2.new(0,0,0,0)
            ModalBtn.Modal = MainFrame.Visible
            ModalBtn:Destroy()
        elseif input.KeyCode == Library.RemoveKey then
            ScreenGui:Destroy()
        end
    end
end)

-- Adicionar Keybinds iniciais na Settings
Library:AddKeybind("Abrir/Fechar Menu", Library.OpenKey, function(key) Library.OpenKey = key end)
Library:AddKeybind("Remover Script", Library.RemoveKey, function(key) Library.RemoveKey = key end)

return Library
