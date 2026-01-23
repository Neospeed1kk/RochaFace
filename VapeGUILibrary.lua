-- vapegui.lua - GUI SEM CATEGORIAS VISUAIS
local VapeGUI = {}

-- Configuração principal
local mainapi = {
    Connections = {},
    Categories = {},
    Keybind = Enum.KeyCode.RightShift,
    Modules = {},
    ThreadFix = setthreadidentity and true or false,
    Windows = {}
}

-- Serviços
local tweenService = game:GetService('TweenService')
local inputService = game:GetService('UserInputService')
local textService = game:GetService('TextService')
local guiService = game:GetService('GuiService')
local players = game:GetService('Players')

-- Variáveis
local clickgui, moduleholder, scaledgui, scale, gui
local expanded

-- Paleta
local uipallet = {
    Main = Color3.fromRGB(64, 64, 64),
    Text = Color3.new(1, 1, 1),
    Font = Font.fromEnum(Enum.Font.SourceSans)
}

-- Sistema de cores simplificado
local color = {}
color.Dark = function(c, num)
    local h, s, v = c:ToHSV()
    return Color3.fromHSV(h, s, math.clamp(v - num, 0, 1))
end

-- Sistema de tween
local tween = {tweens = {}}
function tween:Tween(obj, tweeninfo, goal)
    if self.tweens[obj] then self.tweens[obj]:Cancel() end
    if obj.Parent and obj.Visible then
        self.tweens[obj] = tweenService:Create(obj, tweeninfo, goal)
        self.tweens[obj]:Play()
    else
        for i, v in goal do obj[i] = v end
    end
end

-- Função para criar módulos (SEM CATEGORIAS VISUAIS)
function mainapi:CreateModule(modulesettings)
    local moduleapi = {
        Enabled = false,
        Bind = '',
        Connections = {},
        Name = modulesettings.Name,
        Function = modulesettings.Function
    }
    
    -- Criar botão do módulo
    local modulebutton = Instance.new('TextButton')
    modulebutton.Name = modulesettings.Name
    modulebutton.BackgroundColor3 = uipallet.Main
    modulebutton.BackgroundTransparency = 0.75
    modulebutton.BorderSizePixel = 0
    modulebutton.Text = '   ' .. modulesettings.Name
    modulebutton.TextXAlignment = Enum.TextXAlignment.Left
    modulebutton.TextYAlignment = Enum.TextYAlignment.Center
    modulebutton.TextColor3 = uipallet.Text
    modulebutton.TextSize = 36
    modulebutton.FontFace = uipallet.Font
    modulebutton.Size = UDim2.fromOffset(300, 48)
    modulebutton.Parent = moduleholder
    
    -- Efeitos visuais
    local stroke = Instance.new('UIStroke')
    stroke.Color = color.Dark(uipallet.Main, 0.75)
    stroke.Thickness = 1
    stroke.Transparency = 0.25
    stroke.Parent = modulebutton
    
    local line = Instance.new('Frame')
    line.Size = UDim2.fromOffset(1, 36)
    line.Position = UDim2.new(1, -49, 0, 6)
    line.BackgroundColor3 = stroke.Color
    line.BackgroundTransparency = 0.39
    line.BorderSizePixel = 0
    line.Parent = modulebutton
    
    local triangle = Instance.new('ImageLabel')
    triangle.Size = UDim2.fromOffset(28, 16)
    triangle.Position = UDim2.new(1, -38, 0, 16)
    triangle.BackgroundTransparency = 1
    triangle.Image = 'rbxassetid://0' -- Triângulo simples
    triangle.Parent = modulebutton
    
    -- Container de configurações
    local modulechildren = Instance.new('ScrollingFrame')
    modulechildren.Name = modulesettings.Name .. 'Children'
    modulechildren.Size = UDim2.new()
    modulechildren.Position = UDim2.fromScale(0.5, 0.5)
    modulechildren.AnchorPoint = Vector2.new(0.5, 0.5)
    modulechildren.BackgroundColor3 = uipallet.Main
    modulechildren.BackgroundTransparency = 0.75
    modulechildren.BorderSizePixel = 0
    modulechildren.Visible = false
    modulechildren.Parent = clickgui
    
    -- Layout
    local windowlist = Instance.new('UIListLayout')
    windowlist.SortOrder = Enum.SortOrder.LayoutOrder
    windowlist.Parent = modulechildren
    
    -- Descrição
    local description = Instance.new('TextLabel')
    description.BackgroundTransparency = 1
    description.Text = 'Description:\n' .. (modulesettings.Tooltip or 'None')
    description.TextXAlignment = Enum.TextXAlignment.Left
    description.TextYAlignment = Enum.TextYAlignment.Top
    description.TextColor3 = uipallet.Text
    description.TextSize = 28
    description.FontFace = uipallet.Font
    description.Size = UDim2.new(1, -10, 0, 150)
    description.Parent = modulechildren
    
    -- Funções do módulo
    function moduleapi:Toggle()
        if mainapi.ThreadFix then setthreadidentity(8) end
        self.Enabled = not self.Enabled
        modulebutton.BackgroundColor3 = self.Enabled and Color3.new(0, 1, 0) or uipallet.Main
        
        if self.Function then
            task.spawn(self.Function, self.Enabled)
        end
    end
    
    function moduleapi:Expand()
        modulechildren.Visible = true
        modulechildren.Size = moduleholder.Visible and UDim2.new() or UDim2.new(0, 924, 1, -306)
        tween:Tween(modulechildren, TweenInfo.new(0.4), {Size = moduleholder.Visible and UDim2.new(0, 924, 1, -306) or UDim2.new()})
        expanded = moduleholder.Visible and self or nil
        
        if moduleholder.Visible then
            moduleholder.Visible = false
            task.delay(0.4, function()
                description.Visible = true
            end)
        else
            task.delay(0.4, function()
                moduleholder.Visible = true
                modulechildren.Visible = false
            end)
        end
    end
    
    function moduleapi:SetBind(key)
        self.Bind = key
    end
    
    -- Eventos
    modulebutton.MouseButton1Click:Connect(function()
        moduleapi:Toggle()
    end)
    
    modulebutton.MouseButton2Click:Connect(function()
        moduleapi:Expand()
    end)
    
    triangle.MouseButton1Click:Connect(function()
        moduleapi:Expand()
    end)
    
    -- Auto-size
    windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        if mainapi.ThreadFix then setthreadidentity(8) end
        modulechildren.CanvasSize = UDim2.new(0, 0, 0, windowlist.AbsoluteContentSize.Y / scale.Scale)
    end)
    
    moduleapi.Object = modulebutton
    mainapi.Modules[modulesettings.Name] = moduleapi
    
    return moduleapi
end

-- Inicialização
function VapeGUI:Initialize()
    if gui then return mainapi end
    
    -- Criar GUI
    gui = Instance.new('ScreenGui')
    gui.Name = 'VapeGUI_' .. tostring(math.random(10000, 99999))
    gui.DisplayOrder = 9999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.IgnoreGuiInset = true
    
    if mainapi.ThreadFix then
        gui.Parent = game:GetService("CoreGui")
    else
        gui.Parent = players.LocalPlayer:WaitForChild("PlayerGui")
        gui.ResetOnSpawn = false
    end
    
    -- Container escalável
    scaledgui = Instance.new('Frame')
    scaledgui.Name = 'ScaledGui'
    scaledgui.Size = UDim2.fromScale(1, 1)
    scaledgui.BackgroundTransparency = 1
    scaledgui.Parent = gui
    
    -- ClickGUI
    clickgui = Instance.new('TextButton')
    clickgui.Name = 'ClickGui'
    clickgui.Size = UDim2.fromScale(1, 1)
    clickgui.BackgroundTransparency = 1
    clickgui.Text = ''
    clickgui.Visible = false
    clickgui.Parent = scaledgui
    
    -- Container de módulos
    moduleholder = Instance.new('ScrollingFrame')
    moduleholder.Size = UDim2.new(1, -306, 1, -306)
    moduleholder.Position = UDim2.fromScale(0.5, 0.5)
    moduleholder.AnchorPoint = Vector2.new(0.5, 0.5)
    moduleholder.BackgroundTransparency = 1
    moduleholder.BorderSizePixel = 0
    moduleholder.Parent = clickgui
    
    -- Grid para módulos (3 colunas)
    local modulegrid = Instance.new('UIGridLayout')
    modulegrid.SortOrder = Enum.SortOrder.LayoutOrder
    modulegrid.FillDirection = Enum.FillDirection.Horizontal
    modulegrid.FillDirectionMaxCells = 3
    modulegrid.CellPadding = UDim2.fromOffset(12, 12)
    modulegrid.CellSize = UDim2.fromOffset(300, 48)
    modulegrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    modulegrid.VerticalAlignment = Enum.VerticalAlignment.Center
    modulegrid.Parent = moduleholder
    
    -- Modal
    local modal = Instance.new('TextButton')
    modal.BackgroundTransparency = 1
    modal.Modal = true
    modal.Text = ''
    modal.Parent = clickgui
    
    -- Scale
    scale = Instance.new('UIScale')
    scale.Scale = 1
    scale.Parent = scaledgui
    
    -- Ajustar tamanho
    scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
    
    -- Auto-size do grid
    modulegrid:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        moduleholder.CanvasSize = UDim2.fromOffset(0, modulegrid.AbsoluteContentSize.Y + 2)
    end)
    
    -- Eventos
    mainapi:Clean(clickgui.MouseButton1Click:Connect(function()
        if expanded then expanded:Expand() end
    end))
    
    mainapi:Clean(inputService.InputBegan:Connect(function(inputObj)
        if not inputService:GetFocusedTextBox() and inputObj.KeyCode == mainapi.Keybind then
            if mainapi.ThreadFix then setthreadidentity(8) end
            clickgui.Visible = not clickgui.Visible
        end
    end))
    
    -- Função Clean
    function mainapi:Clean(obj)
        if typeof(obj) == 'Instance' then
            table.insert(self.Connections, {Disconnect = function()
                obj:Destroy()
            end})
        elseif type(obj) == 'function' then
            table.insert(self.Connections, {Disconnect = obj})
        else
            table.insert(self.Connections, obj)
        end
    end
    
    mainapi.gui = gui
    return mainapi
end

-- Adicionar módulo (interface simplificada)
function VapeGUI:AddModule(moduleConfig)
    if not mainapi then
        mainapi = self:Initialize()
    end
    
    return mainapi:CreateModule(moduleConfig)
end

-- Obter módulos
function VapeGUI:GetModules()
    return mainapi.Modules or {}
end

return VapeGUI
