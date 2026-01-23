--[[
    HUD CUSTOMIZER V12 FINAL (TOTAL SAVE SYSTEM)
    - Suporte completo para GetConfig() e LoadConfig()
    - Aplicação imediata de configurações ao carregar
    - Reset de Fábrica, Rainbow Suave e Limpeza Nuclear
]]

if _G.HUDMasterV12_Instance then _G.HUDMasterV12_Instance:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleBar = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local CloseBtn = Instance.new("TextButton")
local Content = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

local GUI_BG = Color3.fromRGB(10, 10, 12)
local ACCENT = Color3.fromRGB(0, 255, 200)
local RAINBOW_SPEED = 15

local NATIVE_COLORS = {
    PlayerName = Color3.fromRGB(0, 255, 0),
    Health = Color3.fromRGB(255, 255, 255),
    Level = Color3.fromRGB(255, 255, 255),
    HealthBarFrame = Color3.fromRGB(0, 255, 127),
    BGFrames = Color3.fromRGB(68, 68, 68),
    Title = Color3.fromRGB(255, 255, 255)
}

ScreenGui.Name = "HUDMasterV12"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false
_G.HUDMasterV12_Instance = ScreenGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = GUI_BG
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -185, 0.5, -275)
MainFrame.Size = UDim2.new(0, 370, 0, 550)
MainFrame.Active = true
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

_G.ToggleHUDCustomizer = function() MainFrame.Visible = not MainFrame.Visible end

TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local UserInputService = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Title.Name = "Title"
Title.Parent = TitleBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "HUD CUSTOMIZER V12"
Title.TextColor3 = ACCENT
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left

CloseBtn.Name = "CloseBtn"
CloseBtn.Parent = TitleBar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "×"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 24
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

Content.Name = "Content"
Content.Parent = MainFrame
Content.BackgroundTransparency = 1
Content.Position = UDim2.new(0, 10, 0, 45)
Content.Size = UDim2.new(1, -20, 1, -55)
Content.CanvasSize = UDim2.new(0, 0, 0, 1600)
Content.ScrollBarThickness = 2
UIListLayout.Parent = Content
UIListLayout.Padding = UDim.new(0, 15)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function colorToHex(color) return string.format("#%02X%02X%02X", math.floor(color.R * 255), math.floor(color.G * 255), math.floor(color.B * 255)) end
local function hexToColor3(hex)
    hex = hex:gsub("#", "")
    if #hex == 6 then
        local r, g, b = tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
        if r and g and b then return Color3.fromRGB(r, g, b) end
    end
    return Color3.fromRGB(255, 255, 255)
end

local State = { IsUpdating = false, Originals = {} }
local sections = {}

local function applySectionToHUD(targetName)
    local s = sections[targetName]
    if not s then return end
    local player = game.Players.LocalPlayer
    local nameplate = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("playerNameplate")
    if not nameplate then return end
    local col = hexToColor3(s.hex.Text)
    s.preview.BackgroundColor3 = col
    local function applyToObj(obj)
        if not obj then return end
        obj.Visible = s.visible()
        for _, stroke in pairs(obj:GetDescendants()) do if stroke:IsA("UIStroke") then stroke.Enabled = s.visible() end end
        if obj:IsA("TextLabel") then
            if s.input then obj.Text = s.input.Text end
            obj:SetAttribute("Rainbow", s.rainbow())
            if not s.rainbow() then obj.TextColor3 = col end
        elseif obj:IsA("Frame") then
            obj.BackgroundColor3 = col
            obj:SetAttribute("Rainbow", s.rainbow())
            if s.trans then obj.BackgroundTransparency = tonumber(s.trans.Text) or 0 end
        elseif obj:IsA("ImageLabel") then obj.Visible = s.visible() end
    end
    if targetName == "HealthBarFrame" then
        local hb = nameplate:FindFirstChild("HealthBar"); local bar = hb and hb:FindFirstChild("Frame")
        if bar then applyToObj(bar); local grad = bar:FindFirstChildOfClass("UIGradient"); if grad then grad.Enabled = not s.rainbow() and (tonumber(s.trans and s.trans.Text or 0) < 1) end end
        if hb then hb.Visible = s.visible() end
    elseif targetName == "BGFrames" then
        for _, bg in pairs(nameplate:GetChildren()) do if bg.Name == "BG" and bg:IsA("Frame") then applyToObj(bg) end end
    elseif targetName == "Images" then
        applyToObj(nameplate:FindFirstChild("BasicImage")); applyToObj(nameplate:FindFirstChild("DQPlusImage"))
    else applyToObj(nameplate:FindFirstChild(targetName)) end
end

local function createSection(name, targetName, layoutOrder, config)
    config = config or {}
    local isSpecial = config.isSpecial
    local hasVisibility = config.hasVisibility
    local hasTransparency = config.hasTransparency
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -5, 0, (isSpecial and 140 or 180) + (hasVisibility and 30 or 0) + (hasTransparency and 30 or 0))
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25); frame.LayoutOrder = layoutOrder; frame.Parent = Content
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30); title.BackgroundTransparency = 1; title.Text = "  " .. name; title.TextColor3 = ACCENT; title.Font = Enum.Font.GothamBold; title.TextSize = 11; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = frame
    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(0, 60, 0, 20); resetBtn.Position = UDim2.new(1, -70, 0, 5); resetBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40); resetBtn.Text = "RESET"; resetBtn.TextColor3 = Color3.fromRGB(180, 180, 180); resetBtn.Font = Enum.Font.GothamBold; resetBtn.TextSize = 9; resetBtn.Parent = frame
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 4)
    local input
    if not isSpecial then
        input = Instance.new("TextBox"); input.Size = UDim2.new(1, -20, 0, 30); input.Position = UDim2.new(0, 10, 0, 35); input.BackgroundColor3 = Color3.fromRGB(12, 12, 15); input.PlaceholderText = "Texto..."; input.Text = ""; input.TextColor3 = Color3.new(1,1,1); input.Font = Enum.Font.Gotham; input.TextSize = 12; input.Parent = frame
        Instance.new("UICorner", input).CornerRadius = UDim.new(0, 4)
    end
    local sliderFrame = Instance.new("Frame"); sliderFrame.Size = UDim2.new(1, -20, 0, 12); sliderFrame.Position = UDim2.new(0, 10, 0, isSpecial and 45 or 75); sliderFrame.Parent = frame
    Instance.new("UICorner", sliderFrame).CornerRadius = UDim.new(1, 0)
    local gradient = Instance.new("UIGradient"); gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(0.2, Color3.fromHSV(0.2, 1, 1)), ColorSequenceKeypoint.new(0.4, Color3.fromHSV(0.4, 1, 1)), ColorSequenceKeypoint.new(0.6, Color3.fromHSV(0.6, 1, 1)), ColorSequenceKeypoint.new(0.8, Color3.fromHSV(0.8, 1, 1)), ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))}); gradient.Parent = sliderFrame
    local knob = Instance.new("Frame"); knob.Size = UDim2.new(0, 16, 0, 16); knob.Position = UDim2.new(0, 0, 0.5, 0); knob.AnchorPoint = Vector2.new(0.5, 0.5); knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.Parent = sliderFrame
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", knob).Thickness = 2
    local hexInput = Instance.new("TextBox"); hexInput.Size = UDim2.new(0, 80, 0, 25); hexInput.Position = UDim2.new(0, 10, 0, isSpecial and 70 or 100); hexInput.BackgroundColor3 = Color3.fromRGB(12, 12, 15); hexInput.Text = "#FFFFFF"; hexInput.TextColor3 = Color3.new(1,1,1); hexInput.Font = Enum.Font.Code; hexInput.TextSize = 11; hexInput.Parent = frame
    Instance.new("UICorner", hexInput).CornerRadius = UDim.new(0, 4)
    local colorPreview = Instance.new("Frame"); colorPreview.Size = UDim2.new(0, 25, 0, 25); colorPreview.Position = UDim2.new(0, 95, 0, isSpecial and 70 or 100); colorPreview.BackgroundColor3 = Color3.fromRGB(255, 255, 255); colorPreview.Parent = frame
    Instance.new("UICorner", colorPreview).CornerRadius = UDim.new(0, 4)
    local rainbowBtn = Instance.new("TextButton"); rainbowBtn.Size = UDim2.new(0, 100, 0, 25); rainbowBtn.Position = UDim2.new(1, -110, 0, isSpecial and 70 or 100); rainbowBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 15); rainbowBtn.Text = "Rainbow: OFF"; rainbowBtn.TextColor3 = Color3.new(1,1,1); rainbowBtn.Font = Enum.Font.Gotham; rainbowBtn.TextSize = 10; rainbowBtn.Parent = frame
    Instance.new("UICorner", rainbowBtn).CornerRadius = UDim.new(0, 4)
    local rainbowEnabled = false; local visible = true
    local visBtn
    if hasVisibility then
        visBtn = Instance.new("TextButton"); visBtn.Size = UDim2.new(0, 100, 0, 25); visBtn.Position = UDim2.new(0, 10, 0, isSpecial and 105 or 135); visBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 15); visBtn.Text = "Visível: SIM"; visBtn.TextColor3 = Color3.fromRGB(100, 255, 100); visBtn.Font = Enum.Font.Gotham; visBtn.TextSize = 10; visBtn.Parent = frame
        Instance.new("UICorner", visBtn).CornerRadius = UDim.new(0, 4)
    end
    local transInput
    if hasTransparency then
        transInput = Instance.new("TextBox"); transInput.Size = UDim2.new(0, 50, 0, 25); transInput.Position = UDim2.new(hasVisibility and 0.35 or 0, 80, 0, isSpecial and 105 or 135); transInput.BackgroundColor3 = Color3.fromRGB(12, 12, 15); transInput.Text = "0"; transInput.TextColor3 = Color3.new(1,1,1); transInput.Parent = frame
        Instance.new("UICorner", transInput).CornerRadius = UDim.new(0, 4)
    end
    local sectionData = {
        targetName = targetName, input = input, hex = hexInput, rainbow = function() return rainbowEnabled end,
        setRainbow = function(v) rainbowEnabled = v; rainbowBtn.Text = "Rainbow: " .. (v and "ON" or "OFF"); rainbowBtn.TextColor3 = v and ACCENT or Color3.new(1,1,1) end,
        visible = function() return visible end,
        setVisible = function(v) visible = v; if visBtn then visBtn.Text = "Visível: " .. (v and "SIM" or "NÃO"); visBtn.TextColor3 = v and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100) end end,
        trans = transInput, preview = colorPreview, knob = knob
    }
    local draggingSlider = false
    knob.InputBegan:Connect(function(io) if io.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
    UserInputService.InputEnded:Connect(function(io) if io.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)
    UserInputService.InputChanged:Connect(function(io)
        if draggingSlider and io.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((io.Position.X - sliderFrame.AbsolutePosition.X) / sliderFrame.AbsoluteSize.X, 0, 1)
            knob.Position = UDim2.new(pos, 0, 0.5, 0); hexInput.Text = colorToHex(Color3.fromHSV(pos, 1, 1))
        end
    end)
    if input then input:GetPropertyChangedSignal("Text"):Connect(function() applySectionToHUD(targetName) end) end
    hexInput:GetPropertyChangedSignal("Text"):Connect(function() applySectionToHUD(targetName) end)
    if transInput then transInput:GetPropertyChangedSignal("Text"):Connect(function() applySectionToHUD(targetName) end) end
    rainbowBtn.MouseButton1Click:Connect(function() sectionData.setRainbow(not rainbowEnabled); applySectionToHUD(targetName) end)
    if visBtn then visBtn.MouseButton1Click:Connect(function() sectionData.setVisible(not visible); applySectionToHUD(targetName) end) end
    resetBtn.MouseButton1Click:Connect(function()
        State.IsUpdating = true
        local nativeCol = NATIVE_COLORS[targetName] or Color3.new(1,1,1)
        local nativeText = State.Originals[targetName] or ""
        if input then input.Text = nativeText end
        hexInput.Text = colorToHex(nativeCol)
        if transInput then transInput.Text = "0" end
        sectionData.setVisible(true); sectionData.setRainbow(false)
        State.IsUpdating = false; applySectionToHUD(targetName)
    end)
    sections[targetName] = sectionData
    return sectionData
end

createSection("NOME", "PlayerName", 1, {hasVisibility = true})
createSection("TÍTULO", "Title", 2, {hasVisibility = true})
createSection("LEVEL", "Level", 3, {hasVisibility = true})
createSection("VIDA (TEXTO)", "Health", 4, {hasVisibility = true})
createSection("COR DA BARRA DE VIDA", "HealthBarFrame", 5, {isSpecial = true, hasVisibility = true, hasTransparency = true})
createSection("COR DO FUNDO (BG)", "BGFrames", 6, {isSpecial = true, hasVisibility = true, hasTransparency = true})
createSection("MOLDURA E ÍCONES", "Images", 7, {isSpecial = true, hasVisibility = true})

local function loadCurrentData()
    State.IsUpdating = true
    local player = game.Players.LocalPlayer
    local nameplate = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("playerNameplate")
    if nameplate then
        for targetName, s in pairs(sections) do
            local obj = nameplate:FindFirstChild(targetName)
            if obj and obj:IsA("TextLabel") then State.Originals[targetName] = obj.Text; s.input.Text = obj.Text; s.hex.Text = colorToHex(obj.TextColor3)
            elseif targetName == "HealthBarFrame" then local hb = nameplate:FindFirstChild("HealthBar"); local bar = hb and hb:FindFirstChild("Frame"); if bar then s.hex.Text = colorToHex(bar.BackgroundColor3) end
            elseif targetName == "BGFrames" then local bg = nameplate:FindFirstChild("BG"); if bg then s.hex.Text = colorToHex(bg.BackgroundColor3) end end
            local h, _, _ = Color3.toHSV(hexToColor3(s.hex.Text)); s.knob.Position = UDim2.new(h, 0, 0.5, 0)
        end
    end
    State.IsUpdating = false
end
task.spawn(function() wait(1); loadCurrentData() end)

game:GetService("RunService").RenderStepped:Connect(function()
    local player = game.Players.LocalPlayer
    local nameplate = player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("playerNameplate")
    if not nameplate then return end
    local rainbowColor = Color3.fromHSV((tick() / RAINBOW_SPEED) % 1, 0.7, 1)
    for _, label in pairs(nameplate:GetDescendants()) do if label:GetAttribute("Rainbow") then if label:IsA("Frame") then label.BackgroundColor3 = rainbowColor end; if label:IsA("TextLabel") then label.TextColor3 = rainbowColor end end end
    for _, bg in pairs(nameplate:GetChildren()) do if bg.Name == "BG" and bg:GetAttribute("Rainbow") then bg.BackgroundColor3 = rainbowColor end end
end)

local function GetConfig()
    local config = {}
    for targetName, s in pairs(sections) do config[targetName] = { Text = s.input and s.input.Text or nil, ColorHex = s.hex.Text, Rainbow = s.rainbow(), Visible = s.visible(), Trans = s.trans and s.trans.Text or nil } end
    return config
end

local function LoadConfig(config)
    if not config then return end
    State.IsUpdating = true
    for targetName, saved in pairs(config) do
        local s = sections[targetName]
        if s then
            if s.input and saved.Text then s.input.Text = saved.Text end
            s.hex.Text = saved.ColorHex; s.setRainbow(saved.Rainbow); s.setVisible(saved.Visible)
            if s.trans and saved.Trans then s.trans.Text = saved.Trans end
            local h, _, _ = Color3.toHSV(hexToColor3(saved.ColorHex)); s.knob.Position = UDim2.new(h, 0, 0.5, 0)
            applySectionToHUD(targetName)
        end
    end
    State.IsUpdating = false
end

return { Toggle = _G.ToggleHUDCustomizer, SetVisible = function(v) MainFrame.Visible = v end, GetConfig = GetConfig, LoadConfig = LoadConfig, SetRainbowSpeed = function(s) RAINBOW_SPEED = s end }
