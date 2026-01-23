-- Minecraft Style GUI for Roblox Exploits
-- By: Neospeed1kk
local MinecraftGUI = {}

-- Configurações
local config = {
    SaveFile = "minecraft_gui_config.json",
    ToggleKey = Enum.KeyCode.Insert,
    DestroyKey = Enum.KeyCode.K,
    Version = "1.0.0"
}

-- Variáveis globais
local gui, mainFrame, categoriesFrame, modulesFrame
local draggedWindow, dragOffset, isDragging = nil, nil, false
local savedPositions = {}
local modules = {}
local categories = {}

-- Cores estilo Minecraft
local colors = {
    background = Color3.fromRGB(25, 25, 25),
    background2 = Color3.fromRGB(35, 35, 35),
    border = Color3.fromRGB(15, 15, 15),
    text = Color3.fromRGB(240, 240, 240),
    accent = Color3.fromRGB(85, 180, 85),
    button = Color3.fromRGB(50, 50, 50),
    buttonHover = Color3.fromRGB(70, 70, 70),
    moduleOn = Color3.fromRGB(85, 180, 85),
    moduleOff = Color3.fromRGB(180, 85, 85)
}

-- Serviços
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local HttpS = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Funções utilitárias
local function createLabel(parent, text, size, position)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = colors.text
    label.TextSize = size
    label.Font = Enum.Font.Gotham
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local function createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = colors.button
    button.BorderColor3 = colors.border
    button.BorderSizePixel = 1
    button.Text = text
    button.TextColor3 = colors.text
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.Size = UDim2.new(1, -10, 0, 30)
    button.Position = UDim2.new(0, 5, 0, 0)
    button.AutoButtonColor = false
    button.Parent = parent
    
    local hoverTween = TS:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = colors.buttonHover})
    local normalTween = TS:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = colors.button})
    
    button.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        normalTween:Play()
    end)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- Função para salvar configurações
local function saveConfig()
    local data = {
        windows = savedPositions,
        modules = {}
    }
    
    for name, module in pairs(modules) do
        data.modules[name] = {
            enabled = module.enabled,
            category = module.category
        }
    end
    
    if writefile then
        writefile(config.SaveFile, HttpS:JSONEncode(data))
    end
end

-- Função para carregar configurações
local function loadConfig()
    if readfile and isfile(config.SaveFile) then
        local success, data = pcall(function()
            return HttpS:JSONDecode(readfile(config.SaveFile))
        end)
        
        if success and data then
            return data
        end
    end
    return {}
end

-- Função para criar a GUI
function MinecraftGUI:Initialize()
    if gui then return end
    
    -- Carregar configurações salvas
    local savedData = loadConfig()
    savedPositions = savedData.windows or {}
    
    -- Criar GUI principal
    gui = Instance.new("ScreenGui")
    gui.Name = "MinecraftGUI_" .. math.random(10000, 99999)
    gui.DisplayOrder = 999
    gui.ResetOnSpawn = false
    
    if syn and syn.protect_gui then
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Frame principal (janela arrastável)
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.BackgroundColor3 = colors.background
    mainFrame.BorderColor3 = colors.border
    mainFrame.BorderSizePixel = 1
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = gui
    
    -- Carregar posição salva
    if savedPositions.MainWindow then
        mainFrame.Position = UDim2.new(
            0, savedPositions.MainWindow.x,
            0, savedPositions.MainWindow.y
        )
    end
    
    -- Barra de título (para arrastar)
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.BackgroundColor3 = colors.background2
    titleBar.BorderSizePixel = 0
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.Parent = mainFrame
    
    local titleText = Instance.new("TextLabel")
    titleText.Name = "Title"
    titleText.BackgroundTransparency = 1
    titleText.Text = "Minecraft GUI v" .. config.Version
    titleText.TextColor3 = colors.accent
    titleText.TextSize = 16
    titleText.Font = Enum.Font.GothamBold
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.BackgroundColor3 = colors.button
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = colors.text
    closeButton.TextSize = 14
    closeButton.Font = Enum.Font.GothamBold
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -30, 0, 0)
    closeButton.Parent = titleBar
    
    closeButton.MouseButton1Click:Connect(function()
        mainFrame.Visible = not mainFrame.Visible
    end)
    
    -- Container para categorias e módulos
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 1, -30)
    container.Position = UDim2.new(0, 0, 0, 30)
    container.Parent = mainFrame
    
    -- Categorias (sidebar esquerda)
    categoriesFrame = Instance.new("ScrollingFrame")
    categoriesFrame.Name = "Categories"
    categoriesFrame.BackgroundColor3 = colors.background2
    categoriesFrame.BorderSizePixel = 0
    categoriesFrame.Size = UDim2.new(0, 120, 1, 0)
    categoriesFrame.Position = UDim2.new(0, 0, 0, 0)
    categoriesFrame.ScrollBarThickness = 3
    categoriesFrame.ScrollBarImageColor3 = colors.accent
    categoriesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    categoriesFrame.Parent = container
    
    local categoriesLayout = Instance.new("UIListLayout")
    categoriesLayout.Padding = UDim.new(0, 5)
    categoriesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    categoriesLayout.Parent = categoriesFrame
    
    -- Área de módulos (direita)
    modulesFrame = Instance.new("ScrollingFrame")
    modulesFrame.Name = "Modules"
    modulesFrame.BackgroundTransparency = 1
    modulesFrame.BorderSizePixel = 0
    modulesFrame.Size = UDim2.new(1, -125, 1, 0)
    modulesFrame.Position = UDim2.new(0, 125, 0, 0)
    modulesFrame.ScrollBarThickness = 3
    modulesFrame.ScrollBarImageColor3 = colors.accent
    modulesFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    modulesFrame.Parent = container
    
    local modulesLayout = Instance.new("UIListLayout")
    modulesLayout.Padding = UDim.new(0, 10)
    modulesLayout.SortOrder = Enum.SortOrder.LayoutOrder
    modulesLayout.Parent = modulesFrame
    
    -- Sistema de arrastar
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            draggedWindow = mainFrame
            dragOffset = mainFrame.AbsolutePosition - input.Position
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
            draggedWindow = nil
            
            -- Salvar posição
            savedPositions.MainWindow = {
                x = mainFrame.AbsolutePosition.X,
                y = mainFrame.AbsolutePosition.Y
            }
            saveConfig()
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if isDragging and draggedWindow and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newPosition = UDim2.new(
                0, input.Position.X + dragOffset.X,
                0, input.Position.Y + dragOffset.Y
            )
            draggedWindow.Position = newPosition
        end
    end)
    
    -- Criar categorias padrão
    self:CreateCategory("Combate")
    self:CreateCategory("Visual")
    self:CreateCategory("Movimentos")
    
    -- Selecionar primeira categoria por padrão
    self:SelectCategory("Combate")
    
    -- Configurar teclas
    self:SetupKeybinds()
    
    return self
end

-- Função para criar categoria
function MinecraftGUI:CreateCategory(name)
    local categoryButton = Instance.new("TextButton")
    categoryButton.Name = name
    categoryButton.BackgroundColor3 = colors.button
    categoryButton.BorderColor3 = colors.border
    categoryButton.BorderSizePixel = 1
    categoryButton.Text = name
    categoryButton.TextColor3 = colors.text
    categoryButton.TextSize = 14
    categoryButton.Font = Enum.Font.Gotham
    categoryButton.Size = UDim2.new(1, -10, 0, 35)
    categoryButton.Position = UDim2.new(0, 5, 0, 0)
    categoryButton.AutoButtonColor = false
    categoryButton.Parent = categoriesFrame
    
    local hoverTween = TS:Create(categoryButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.buttonHover})
    local normalTween = TS:Create(categoryButton, TweenInfo.new(0.2), {BackgroundColor3 = colors.button})
    
    categoryButton.MouseEnter:Connect(function()
        hoverTween:Play()
    end)
    
    categoryButton.MouseLeave:Connect(function()
        normalTween:Play()
    end)
    
    categoryButton.MouseButton1Click:Connect(function()
        self:SelectCategory(name)
    end)
    
    categories[name] = {
        button = categoryButton,
        modules = {}
    }
    
    return categoryButton
end

-- Função para selecionar categoria
function MinecraftGUI:SelectCategory(name)
    -- Resetar botões de categoria
    for catName, cat in pairs(categories) do
        if cat.button then
            cat.button.BackgroundColor3 = (catName == name) and colors.accent or colors.button
        end
    end
    
    -- Limpar módulos visíveis
    modulesFrame:ClearAllChildren()
    
    -- Mostrar módulos da categoria selecionada
    if categories[name] then
        for _, moduleData in pairs(categories[name].modules) do
            self:CreateModuleUI(moduleData)
        end
    end
end

-- Função para criar módulo
function MinecraftGUI:CreateModule(categoryName, moduleConfig)
    local moduleData = {
        name = moduleConfig.name,
        category = categoryName,
        enabled = false,
        toggle = moduleConfig.toggle or function() end,
        tooltip = moduleConfig.tooltip or "",
        keybind = moduleConfig.keybind or nil
    }
    
    -- Carregar estado salvo
    local savedData = loadConfig()
    if savedData.modules and savedData.modules[moduleConfig.name] then
        moduleData.enabled = savedData.modules[moduleConfig.name].enabled or false
    end
    
    -- Adicionar à categoria
    if not categories[categoryName] then
        self:CreateCategory(categoryName)
    end
    
    table.insert(categories[categoryName].modules, moduleData)
    modules[moduleConfig.name] = moduleData
    
    -- Se esta categoria estiver selecionada, criar UI
    self:SelectCategory(categoryName)
    
    return moduleData
end

-- Função para criar UI do módulo
function MinecraftGUI:CreateModuleUI(moduleData)
    local moduleFrame = Instance.new("Frame")
    moduleFrame.Name = moduleData.name
    moduleFrame.BackgroundColor3 = colors.background2
    moduleFrame.BorderColor3 = colors.border
    moduleFrame.BorderSizePixel = 1
    moduleFrame.Size = UDim2.new(1, -10, 0, 60)
    moduleFrame.Position = UDim2.new(0, 5, 0, 0)
    moduleFrame.Parent = modulesFrame
    
    -- Nome do módulo
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name"
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = moduleData.name
    nameLabel.TextColor3 = colors.text
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Size = UDim2.new(1, -50, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = moduleFrame
    
    -- Descrição/Tooltip
    if moduleData.tooltip ~= "" then
        local tooltipLabel = Instance.new("TextLabel")
        tooltipLabel.Name = "Tooltip"
        tooltipLabel.BackgroundTransparency = 1
        tooltipLabel.Text = moduleData.tooltip
        tooltipLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
        tooltipLabel.TextSize = 12
        tooltipLabel.Font = Enum.Font.Gotham
        tooltipLabel.Size = UDim2.new(1, -10, 0, 20)
        tooltipLabel.Position = UDim2.new(0, 10, 0, 30)
        tooltipLabel.TextXAlignment = Enum.TextXAlignment.Left
        tooltipLabel.Parent = moduleFrame
    end
    
    -- Botão de toggle
    local toggleButton = Instance.new("TextButton")
    toggleButton.Name = "Toggle"
    toggleButton.BackgroundColor3 = moduleData.enabled and colors.moduleOn or colors.moduleOff
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = moduleData.enabled and "ON" or "OFF"
    toggleButton.TextColor3 = colors.text
    toggleButton.TextSize = 14
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.Size = UDim2.new(0, 40, 0, 25)
    toggleButton.Position = UDim2.new(1, -45, 0, 5)
    toggleButton.Parent = moduleFrame
    
    toggleButton.MouseButton1Click:Connect(function()
        moduleData.enabled = not moduleData.enabled
        toggleButton.BackgroundColor3 = moduleData.enabled and colors.moduleOn or colors.moduleOff
        toggleButton.Text = moduleData.enabled and "ON" or "OFF"
        
        -- Executar função de toggle
        if moduleData.toggle then
            pcall(moduleData.toggle, moduleData.enabled)
        end
        
        -- Salvar estado
        saveConfig()
    end)
    
    return moduleFrame
end

-- Configurar teclas
function MinecraftGUI:SetupKeybinds()
    -- Tecla Insert para abrir/fechar
    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == config.ToggleKey then
            mainFrame.Visible = not mainFrame.Visible
        end
        
        -- Tecla K para destruir tudo
        if input.KeyCode == config.DestroyKey then
            self:Destroy()
        end
    end)
end

-- Função para destruir a GUI
function MinecraftGUI:Destroy()
    if gui then
        gui:Destroy()
        gui = nil
        mainFrame = nil
        
        -- Limpar tudo
        modules = {}
        categories = {}
        savedPositions = {}
        
        print("GUI completamente removida!")
    end
end

-- API pública
function MinecraftGUI:AddModule(category, name, toggleFunc, tooltip, keybind)
    return self:CreateModule(category, {
        name = name,
        toggle = toggleFunc,
        tooltip = tooltip,
        keybind = keybind
    })
end

function MinecraftGUI:Toggle()
    if mainFrame then
        mainFrame.Visible = not mainFrame.Visible
    end
end

function MinecraftGUI:GetModule(name)
    return modules[name]
end

function MinecraftGUI:GetModules()
    return modules
end

-- Criar módulos padrão ao inicializar
function MinecraftGUI:CreateDefaultModules()
    -- Combate: Auto Clique
    self:AddModule("Combate", "Auto Clique", function(state)
        print("[Auto Clique]", state and "Ativado" or "Desativado")
        -- Sua lógica de auto clique aqui
    end, "Clica automaticamente para você", nil)
    
    -- Visual: Nomes
    self:AddModule("Visual", "Nomes", function(state)
        print("[Nomes]", state and "Ativado" or "Desativado")
        -- Sua lógica ESP de nomes aqui
    end, "Mostra nomes dos jogadores", nil)
    
    -- Movimentos: Teleporte
    self:AddModule("Movimentos", "Teleporte", function(state)
        print("[Teleporte]", state and "Ativado" or "Desativado")
        -- Sua lógica de teleporte aqui
    end, "Teleporta para onde você mirar", nil)
end

-- Retornar a API
return MinecraftGUI
