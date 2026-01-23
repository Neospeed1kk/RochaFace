-- vapegui.lua - GUI Library MODULARIZADA mas mantendo interface ORIGINAL
local VapeGUI = {}

-- Função para criar a GUI completa (igual ao seu código)
local function createGUI()
    local mainapi = {
        Connections = {},
        Categories = {},
        GUIColor = {Hue = 0.46, Sat = 0.96, Value = 0.52},
        Keybind = Enum.KeyCode.RightShift,
        Loaded = false,
        Libraries = {},
        Modules = {},
        Notifications = {Enabled = true},
        Place = game.PlaceId,
        Profile = 'default',
        Profiles = {},
        RainbowSpeed = {Value = 1},
        RainbowUpdateSpeed = {Value = 60},
        RainbowTable = {},
        Scale = {Value = 1},
        ToggleNotifications = {Enabled = true},
        ThreadFix = setthreadidentity and true or false,
        Version = '6.35.3',
        Windows = {}
    }

    -- Serviços (IDÊNTICO)
    local cloneref = cloneref or function(obj) return obj end
    local tweenService = cloneref(game:GetService('TweenService'))
    local inputService = cloneref(game:GetService('UserInputService'))
    local textService = cloneref(game:GetService('TextService'))
    local guiService = cloneref(game:GetService('GuiService'))
    local runService = cloneref(game:GetService('RunService'))
    local httpService = cloneref(game:GetService('HttpService'))

    -- Variáveis locais (IDÊNTICO)
    local fontsize = Instance.new('GetTextBoundsParams')
    fontsize.Width = math.huge
    local notifications
    local getcustomasset
    local clickgui
    local expanded
    local moduleholder
    local scaledgui
    local toolblur
    local tooltip
    local scale
    local gui

    -- Sistemas de cores e tween (IDÊNTICO)
    local color = {}
    local tween = {tweens = {}, tweenstwo = {}}
    local uipallet = {
        Main = Color3.fromRGB(64, 64, 64),
        Text = Color3.new(1, 1, 1),
        Font = Font.fromEnum(Enum.Font.SourceSans),
        FontSemiBold = Font.fromEnum(Enum.Font.SourceSans, Enum.FontWeight.SemiBold),
        Tween = TweenInfo.new(0.16, Enum.EasingStyle.Linear)
    }

    -- Funções auxiliares (IDÊNTICAS)
    local function getTableSize(tab)
        local ind = 0
        for _ in tab do ind += 1 end
        return ind
    end

    local function randomString()
        local array = {}
        for i = 1, math.random(10, 100) do
            array[i] = string.char(math.random(32, 126))
        end
        return table.concat(array)
    end

    -- Sistema de cores (IDÊNTICO)
    color.Dark = function(color, num)
        local h, s, v = color:ToHSV()
        local _, _, compare = uipallet.Main:ToHSV()
        return Color3.fromHSV(h, s, math.clamp(compare > 0.5 and v + num or v - num, 0, 1))
    end

    color.Light = function(color, num)
        local h, s, v = color:ToHSV()
        local _, _, compare = uipallet.Main:ToHSV()
        return Color3.fromHSV(h, s, math.clamp(compare > 0.5 and v - num or v + num, 0, 1))
    end

    -- Sistema de tween (IDÊNTICO)
    function tween:Tween(obj, tweeninfo, goal, tab)
        tab = tab or self.tweens
        if tab[obj] then tab[obj]:Cancel() end
        if obj.Parent and obj.Visible then
            tab[obj] = tweenService:Create(obj, tweeninfo, goal)
            tab[obj].Completed:Once(function()
                if tab then
                    tab[obj] = nil
                    tab = nil
                end
            end)
            tab[obj]:Play()
        else
            for i, v in goal do obj[i] = v end
        end
    end

    function tween:Cancel(obj)
        if self.tweens[obj] then
            self.tweens[obj]:Cancel()
            self.tweens[obj] = nil
        end
    end

    -- Função Clean (IDÊNTICA)
    function mainapi:Clean(obj)
        if typeof(obj) == 'Instance' then
            table.insert(self.Connections, {Disconnect = function()
                obj:ClearAllChildren()
                obj:Destroy()
            end})
            return
        elseif type(obj) == 'function' then
            table.insert(self.Connections, {Disconnect = obj})
            return
        end
        table.insert(self.Connections, obj)
    end

    -- Função para criar categorias (IDÊNTICA)
    function mainapi:CreateCategory(categorysettings)
        local categoryapi = {Type = 'Category'}

        function categoryapi:CreateModule(modulesettings)
            local moduleapi = {
                Enabled = false, 
                Options = {}, 
                Bind = '', 
                Connections = {}, 
                Index = modulesettings.Index or getTableSize(mainapi.Modules), 
                ExtraText = modulesettings.ExtraText, 
                Name = modulesettings.Name, 
                Category = categorysettings.Name,
                Function = modulesettings.Function
            }

            -- Criação do botão do módulo (IDÊNTICO)
            local modulebutton = Instance.new('TextButton')
            modulebutton.BackgroundColor3 = uipallet.Main
            modulebutton.BackgroundTransparency = 0.75
            modulebutton.BorderSizePixel = 0
            modulebutton.Text = '   ' .. modulesettings.Name
            modulebutton.TextXAlignment = Enum.TextXAlignment.Left
            modulebutton.TextYAlignment = Enum.TextYAlignment.Center
            modulebutton.TextColor3 = uipallet.Text
            modulebutton.TextSize = 36
            modulebutton.FontFace = uipallet.Font
            modulebutton.Parent = moduleholder
            
            -- Stroke (IDÊNTICO)
            local stroke = Instance.new('UIStroke')
            stroke.Color = color.Dark(uipallet.Main, 0.75)
            stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            stroke.Thickness = 1
            stroke.Transparency = 0.25
            stroke.Parent = modulebutton
            
            -- Linha (IDÊNTICO)
            local line = Instance.new('Frame')
            line.Size = UDim2.fromOffset(1, 36)
            line.Position = UDim2.new(1, -49, 0, 6)
            line.BackgroundColor3 = stroke.Color
            line.BackgroundTransparency = 0.39
            line.BorderSizePixel = 0
            line.Parent = modulebutton
            
            -- Triângulo (IDÊNTICO)
            local triangle = Instance.new('ImageButton')
            triangle.Size = UDim2.fromOffset(28, 16)
            triangle.Position = UDim2.new(1, -38, 0, 16)
            triangle.BackgroundTransparency = 1
            triangle.Image = 'rbxasset://wurst/triangle.png'
            triangle.AutoButtonColor = false
            triangle.Parent = modulebutton
            
            -- Container dos elementos (IDÊNTICO)
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
            
            moduleapi.Children = modulechildren
            
            -- Layout (IDÊNTICO)
            local windowlist = Instance.new('UIListLayout')
            windowlist.SortOrder = Enum.SortOrder.LayoutOrder
            windowlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
            windowlist.Parent = modulechildren
            
            -- Descrição (IDÊNTICA)
            local description = Instance.new('TextLabel')
            description.BackgroundTransparency = 1
            description.Text = 'Type: Hack, Category: ' .. moduleapi.Category .. '\n\nDescription:\n' .. (modulesettings.Tooltip or 'None') .. '\n\nSettings:'
            description.TextXAlignment = Enum.TextXAlignment.Left
            description.TextYAlignment = Enum.TextYAlignment.Top
            description.TextColor3 = uipallet.Text
            description.TextSize = 28
            description.FontFace = uipallet.Font
            description.Size = UDim2.new(1, -10, 0, 150)
            description.Parent = modulechildren
            
            -- Funções do módulo (IDÊNTICAS)
            function moduleapi:Expand()
                modulechildren.Visible = true
                modulechildren.Size = moduleholder.Visible and UDim2.new() or UDim2.new(0, 924, 1, -306)
                tween:Tween(modulechildren, TweenInfo.new(0.4, Enum.EasingStyle.Linear), {Size = moduleholder.Visible and UDim2.new(0, 924, 1, -306) or UDim2.new()})
                expanded = moduleholder.Visible and self or nil

                local visibletable = {}
                description.Visible = false

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

            function moduleapi:SetBind(val)
                if type(val) == 'table' then
                    -- Implementar createMobileButton se necessário
                    return
                end
                self.Bind = val
            end

            function moduleapi:Toggle(multiple)
                if mainapi.ThreadFix then setthreadidentity(8) end
                self.Enabled = not self.Enabled
                modulebutton.BackgroundColor3 = self.Enabled and Color3.new(0, 1, 0) or uipallet.Main
                if not self.Enabled then
                    for _, v in self.Connections do v:Disconnect() end
                    table.clear(self.Connections)
                end
                if moduleapi.Function then
                    task.spawn(moduleapi.Function, self.Enabled)
                end
            end
            
            -- Eventos (IDÊNTICOS)
            modulebutton.MouseButton1Click:Connect(function()
                moduleapi:Toggle()
            end)
            
            modulebutton.MouseButton2Click:Connect(function()
                moduleapi:Expand()
            end)
            
            triangle.MouseButton1Click:Connect(function()
                moduleapi:Expand()
            end)
            
            -- Auto-size (IDÊNTICO)
            windowlist:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                if mainapi.ThreadFix then setthreadidentity(8) end
                modulechildren.CanvasSize = UDim2.new(0, 0, 0, windowlist.AbsoluteContentSize.Y / scale.Scale)
            end)

            moduleapi.Object = modulebutton
            mainapi.Modules[modulesettings.Name] = moduleapi

            -- Ordenação (IDÊNTICA)
            local sorted = {}
            for i in mainapi.Modules do
                table.insert(sorted, i)
            end

            table.sort(sorted, function(a, b) 
                return (mainapi.Modules[a].Index or 0) > (mainapi.Modules[b].Index or 0)
            end)

            for i, v in ipairs(sorted) do
                mainapi.Modules[v].Index = i
                mainapi.Modules[v].Object.LayoutOrder = i
            end

            return moduleapi
        end

        mainapi.Categories[categorysettings.Name] = categoryapi
        return categoryapi
    end

    -- AGORA CRIAR A GUI (IDÊNTICO ao seu código)
    gui = Instance.new('ScreenGui')
    gui.Name = randomString()
    gui.DisplayOrder = 9999999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.IgnoreGuiInset = true
    gui.OnTopOfCoreBlur = true
    
    if mainapi.ThreadFix then
        gui.Parent = (gethui and gethui()) or cloneref(game:GetService('CoreGui'))
    else
        gui.Parent = cloneref(game:GetService('Players')).LocalPlayer.PlayerGui
        gui.ResetOnSpawn = false
    end
    
    mainapi.gui = gui
    
    -- GUI escalável (IDÊNTICO)
    scaledgui = Instance.new('Frame')
    scaledgui.Name = 'ScaledGui'
    scaledgui.Size = UDim2.fromScale(1, 1)
    scaledgui.BackgroundTransparency = 1
    scaledgui.Parent = gui
    
    -- ClickGUI (IDÊNTICO)
    clickgui = Instance.new('TextButton')
    clickgui.Name = 'ClickGui'
    clickgui.Size = UDim2.fromScale(1, 1)
    clickgui.BackgroundTransparency = 1
    clickgui.Text = ''
    clickgui.Visible = false
    clickgui.Parent = scaledgui
    
    -- Container de módulos (IDÊNTICO)
    moduleholder = Instance.new('ScrollingFrame')
    moduleholder.Size = UDim2.new(1, -306, 1, -306)
    moduleholder.Position = UDim2.fromScale(0.5, 0.5)
    moduleholder.AnchorPoint = Vector2.new(0.5, 0.5)
    moduleholder.BackgroundTransparency = 1
    moduleholder.BorderSizePixel = 0
    moduleholder.Parent = clickgui
    
    -- Grid layout (IDÊNTICO)
    local modulegrid = Instance.new('UIGridLayout')
    modulegrid.SortOrder = Enum.SortOrder.LayoutOrder
    modulegrid.FillDirection = Enum.FillDirection.Horizontal
    modulegrid.FillDirectionMaxCells = 3
    modulegrid.CellPadding = UDim2.fromOffset(12, 12)
    modulegrid.CellSize = UDim2.fromOffset(300, 48)
    modulegrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    modulegrid.VerticalAlignment = Enum.VerticalAlignment.Center
    modulegrid.Parent = moduleholder
    
    -- Modal (IDÊNTICO)
    local modal = Instance.new('TextButton')
    modal.BackgroundTransparency = 1
    modal.Modal = true
    modal.Text = ''
    modal.Parent = clickgui
    
    -- Cursor (IDÊNTICO)
    local cursor = Instance.new('ImageLabel')
    cursor.Size = UDim2.fromOffset(64, 64)
    cursor.BackgroundTransparency = 1
    cursor.Visible = false
    cursor.Image = 'rbxasset://textures/Cursors/KeyboardMouse/ArrowFarCursor.png'
    cursor.Parent = gui
    
    -- Scale (IDÊNTICO)
    scale = Instance.new('UIScale')
    scale.Scale = 1
    scale.Parent = scaledgui
    mainapi.guiscale = scale
    scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
    
    -- Evento de redimensionamento (IDÊNTICO)
    modulegrid:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
        moduleholder.CanvasSize = UDim2.fromOffset(0, modulegrid.AbsoluteContentSize.Y + 2)
    end)
    
    -- Criar categorias padrão (IDÊNTICO)
    for _, v in {'Combat', 'Blatant', 'Render', 'Utility', 'World', 'Inventory', 'Minigames'} do
        mainapi:CreateCategory({Name = v})
    end
    
    -- Eventos de clique (IDÊNTICOS)
    mainapi:Clean(clickgui.MouseButton1Click:Connect(function()
        if expanded then expanded:Expand() end
    end))
    
    mainapi:Clean(scale:GetPropertyChangedSignal('Scale'):Connect(function()
        scaledgui.Size = UDim2.fromScale(1 / scale.Scale, 1 / scale.Scale)
        for _, v in scaledgui:GetDescendants() do
            if v:IsA('GuiObject') and v.Visible then
                v.Visible = false
                v.Visible = true
            end
        end
    end))
    
    -- Evento de teclado (IDÊNTICO)
    mainapi:Clean(inputService.InputBegan:Connect(function(inputObj)
        if not inputService:GetFocusedTextBox() and inputObj.KeyCode ~= Enum.KeyCode.Unknown then
            if inputObj.KeyCode == mainapi.Keybind then
                if mainapi.ThreadFix then setthreadidentity(8) end
                clickgui.Visible = not clickgui.Visible
            end
            
            local toggled = false
            for i, v in mainapi.Modules do
                if v.Bind == inputObj.KeyCode.Name then
                    toggled = true
                    v:Toggle(true)
                end
            end
        end
    end))
    
    return mainapi
end

-- Variável global para armazenar a API
local mainapi = nil

-- Função para inicializar a GUI
function VapeGUI:Initialize()
    if not mainapi then
        mainapi = createGUI()
    end
    return mainapi
end

-- Função para adicionar módulos dinamicamente
function VapeGUI:AddModule(categoryName, moduleConfig)
    if not mainapi then
        mainapi = createGUI()
    end
    
    local category = mainapi.Categories[categoryName]
    if not category then
        category = mainapi:CreateCategory({Name = categoryName})
    end
    
    return category:CreateModule(moduleConfig)
end

-- Função para obter todos os módulos
function VapeGUI:GetModules()
    return mainapi and mainapi.Modules or {}
end

-- Retornar a biblioteca
return VapeGUI
