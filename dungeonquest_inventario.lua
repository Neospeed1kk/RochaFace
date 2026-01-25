--[[
    SCRIPT V5.2 - PRONTO PARA HOSPEDAGEM
    - Tecla para abrir/fechar a GUI alterada para "Home".
    - Nenhuma outra alteração de lógica. O script está pronto para ser hospedado
      e carregado via loadstring.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Player = Players.LocalPlayer

-- ==================== CONFIGURAÇÃO E VARIÁVEIS GLOBAIS ====================
local GUI_KEY = Enum.KeyCode.Home -- <<< TECLA ALTERADA PARA "HOME"
local MAX_ITEMS = 300
local DATA_FOLDER = "InventoryCache" -- Pasta para salvar os caches
local USER_ID = tostring(Player.UserId) -- ID do usuário atual para o nome do arquivo

local inventoryCache = {} -- O cache que será usado pela GUI
local currentTab = "General"
local currentCategory = "weapons"
local filterSettings = {
    minLevel = 0,
    maxLevel = 999,
    focus = "All",
}

-- Remover GUI antiga, se houver
local function cleanupOldGUI()
    for _, gui in ipairs(Player.PlayerGui:GetChildren()) do
        if gui.Name == "InventoryScannerGUI" then gui:Destroy() end
    end
end
cleanupOldGUI()

-- ==================== SISTEMA DE DADOS (CACHE PERSISTENTE) ====================

-- Função para buscar o inventário do servidor (a operação "lenta")
local function fetchInventoryFromServer()
    local remotes = ReplicatedStorage:FindFirstChild("remotes")
    local reloadInvy = remotes and remotes:FindFirstChild("reloadInvy")
    if not reloadInvy then return nil end
    
    local success, result = pcall(function() return reloadInvy:InvokeServer() end)
    if not success or not result then return nil end

    -- Processa e categoriza os itens recebidos
    local processed = { weapons = {}, armors = {}, abilities = {}, rings = {}, others = {} }
    for key, categoryData in pairs(result) do
        if type(categoryData) == "table" then
            for _, item in pairs(categoryData) do
                local itemType = (item.type or key or ""):lower()
                if itemType:find("weapon") or itemType:find("sword") or key == "weapons" then
                    table.insert(processed.weapons, item)
                elseif itemType:find("helmet") or itemType:find("chest") or itemType:find("armor") or key == "helmets" or key == "armors" then
                    table.insert(processed.armors, item)
                elseif itemType:find("ability") or itemType:find("skill") or key == "abilities" then
                    table.insert(processed.abilities, item)
                elseif itemType:find("ring") or key == "rings" then
                    table.insert(processed.rings, item)
                else
                    table.insert(processed.others, item)
                end
            end
        end
    end
    return processed
end

-- Salva o cache de inventário atual no arquivo JSON do usuário
local function saveInventoryCache()
    if not isfolder(DATA_FOLDER) then makefolder(DATA_FOLDER) end
    
    local success, err = pcall(function()
        local jsonString = HttpService:JSONEncode(inventoryCache)
        writefile(DATA_FOLDER .. "/" .. USER_ID .. ".json", jsonString)
    end)
    
    if not success then
        warn("Falha ao salvar cache do inventário: " .. tostring(err))
    end
end

-- Carrega o cache de inventário do arquivo JSON do usuário, se existir
local function loadInventoryCache()
    local filePath = DATA_FOLDER .. "/" .. USER_ID .. ".json"
    if not isfile(filePath) then return false end -- Retorna false se não houver cache salvo

    local success, result = pcall(function()
        local fileContent = readfile(filePath)
        return HttpService:JSONDecode(fileContent)
    end)

    if success and type(result) == "table" then
        inventoryCache = result
        return true -- Retorna true se o cache foi carregado com sucesso
    else
        warn("Falha ao carregar ou decodificar cache do inventário.")
        return false
    end
end

-- ==================== CONSTRUÇÃO DA GUI ====================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "InventoryScannerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = Player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 950, 0, 650)
mainFrame.Position = UDim2.new(0.5, -475, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

-- Notificação de feedback para o usuário
local notificationLabel = Instance.new("TextLabel")
notificationLabel.Size = UDim2.new(0, 220, 0, 40)
notificationLabel.Position = UDim2.new(0.5, -110, 1, -60)
notificationLabel.BackgroundColor3 = Color3.fromRGB(20, 80, 20)
notificationLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
notificationLabel.Font = Enum.Font.GothamBold
notificationLabel.TextSize = 14
notificationLabel.Text = "Sincronizado!"
notificationLabel.Visible = false
notificationLabel.ZIndex = 1002
notificationLabel.Parent = screenGui
Instance.new("UICorner", notificationLabel).CornerRadius = UDim.new(0, 8)

local function showNotification(message, color)
    notificationLabel.Text = message
    notificationLabel.BackgroundColor3 = color or Color3.fromRGB(20, 80, 20)
    notificationLabel.Visible = true
    task.delay(2, function() notificationLabel.Visible = false end)
end

-- MENU LATERAL
local sideMenu = Instance.new("Frame")
sideMenu.Size = UDim2.new(0, 180, 1, 0)
sideMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
sideMenu.BorderSizePixel = 0
sideMenu.Parent = mainFrame
Instance.new("UICorner", sideMenu).CornerRadius = UDim.new(0, 10)

local menuTitle = Instance.new("TextLabel")
menuTitle.Text = "MENU"
menuTitle.Size = UDim2.new(1, 0, 0, 50)
menuTitle.BackgroundTransparency = 1
menuTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
menuTitle.Font = Enum.Font.GothamBold
menuTitle.TextSize = 16
menuTitle.Parent = sideMenu

local function createMenuBtn(text, pos)
    local btn = Instance.new("TextButton")
    btn.Text = text
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, pos)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = sideMenu
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local btnGeneral = createMenuBtn("GERAL", 60)
local btnFiltered = createMenuBtn("FILTRADO", 110)
local btnSync = createMenuBtn("SINCRONIZAR", 540) -- Botão alterado de "RECARREGAR" para "SINCRONIZAR"
btnSync.BackgroundColor3 = Color3.fromRGB(0, 100, 180)
local btnClose = createMenuBtn("REMOVER", 590)
btnClose.BackgroundColor3 = Color3.fromRGB(150, 50, 50)

-- ÁREA DE CONTEÚDO
local container = Instance.new("Frame")
container.Size = UDim2.new(1, -190, 1, -10)
container.Position = UDim2.new(0, 185, 0, 5)
container.BackgroundTransparency = 1
container.Parent = mainFrame

-- Painel de Filtros
local filterPanel = Instance.new("Frame")
filterPanel.Size = UDim2.new(1, -20, 0, 80)
filterPanel.Position = UDim2.new(0, 10, 0, 10)
filterPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
filterPanel.Visible = false
filterPanel.Parent = container
Instance.new("UICorner", filterPanel).CornerRadius = UDim.new(0, 8)

local function createInput(placeholder, size, pos, parent)
    local box = Instance.new("TextBox")
    box.PlaceholderText = placeholder; box.Size = size; box.Position = pos; box.Parent = parent
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 60); box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.Font = Enum.Font.Gotham; box.TextSize = 12; box.Text = ""
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)
    return box
end

local minLvlInput = createInput("Nv. Mín", UDim2.new(0, 80, 0, 30), UDim2.new(0, 10, 0, 10), filterPanel)
local maxLvlInput = createInput("Nv. Máx", UDim2.new(0, 80, 0, 30), UDim2.new(0, 100, 0, 10), filterPanel)

local focusBtn = Instance.new("TextButton")
focusBtn.Text = "FOCO: TODOS"; focusBtn.Size = UDim2.new(0, 120, 0, 30); focusBtn.Position = UDim2.new(0, 190, 0, 10)
focusBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200); focusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
focusBtn.Font = Enum.Font.GothamBold; focusBtn.TextSize = 11; focusBtn.Parent = filterPanel
Instance.new("UICorner", focusBtn).CornerRadius = UDim.new(0, 4)

-- Tabs de Categoria
local tabsFrame = Instance.new("Frame")
tabsFrame.Size = UDim2.new(1, -20, 0, 40); tabsFrame.Position = UDim2.new(0, 10, 0, 10)
tabsFrame.BackgroundTransparency = 1; tabsFrame.Parent = container

local catBtns = {}
local categories = {{Name = "ARMAS", Key = "weapons"}, {Name = "ARMADURAS", Key = "armors"}, {Name = "SKILLS", Key = "abilities"}, {Name = "ANÉIS", Key = "rings"}}
for i, cat in ipairs(categories) do
    local b = Instance.new("TextButton")
    b.Text = cat.Name; b.Size = UDim2.new(1/#categories, -5, 1, 0); b.Position = UDim2.new((i-1)/#categories, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 60); b.TextColor3 = Color3.fromRGB(200, 200, 200)
    b.Font = Enum.Font.GothamBold; b.TextSize = 11; b.Parent = tabsFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    catBtns[cat.Key] = b
end

-- Grid de Itens
local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, -10, 1, -100); scroll.Position = UDim2.new(0, 5, 0, 60)
scroll.BackgroundTransparency = 1; scroll.ScrollBarThickness = 4
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y; scroll.Parent = container

local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.new(0, 135, 0, 165); grid.CellPadding = UDim2.new(0, 15, 0, 15)
grid.HorizontalAlignment = Enum.HorizontalAlignment.Center; grid.Parent = scroll

local gridPadding = Instance.new("UIPadding")
gridPadding.PaddingTop = UDim.new(0, 15); gridPadding.PaddingBottom = UDim.new(0, 15)
gridPadding.PaddingLeft = UDim.new(0, 10); gridPadding.PaddingRight = UDim.new(0, 10)
gridPadding.Parent = scroll

-- Tooltip
local tooltip = Instance.new("Frame")
tooltip.Size = UDim2.new(0, 260, 0, 220); tooltip.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
tooltip.Visible = false; tooltip.ZIndex = 1000; tooltip.Parent = screenGui
Instance.new("UICorner", tooltip).CornerRadius = UDim.new(0, 8)
local ttStroke = Instance.new("UIStroke")
ttStroke.Color = Color3.fromRGB(80, 80, 100); ttStroke.Thickness = 1.5; ttStroke.Parent = tooltip

local ttTitle = Instance.new("TextLabel")
ttTitle.Size = UDim2.new(1, -20, 0, 35); ttTitle.Position = UDim2.new(0, 10, 0, 5)
ttTitle.BackgroundTransparency = 1; ttTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ttTitle.Font = Enum.Font.GothamBold; ttTitle.TextSize = 15; ttTitle.TextXAlignment = Enum.TextXAlignment.Left
ttTitle.ZIndex = 1001; ttTitle.Parent = tooltip

local ttContent = Instance.new("TextLabel")
ttContent.Size = UDim2.new(1, -20, 1, -50); ttContent.Position = UDim2.new(0, 10, 0, 40)
ttContent.BackgroundTransparency = 1; ttContent.TextColor3 = Color3.fromRGB(230, 230, 230)
ttContent.Font = Enum.Font.Gotham; ttContent.TextSize = 12; ttContent.TextWrapped = true
ttContent.TextYAlignment = Enum.TextYAlignment.Top; ttContent.TextXAlignment = Enum.TextXAlignment.Left
ttContent.ZIndex = 1001; ttContent.Parent = tooltip

-- ==================== LÓGICA DE RENDERIZAÇÃO E EXIBIÇÃO ====================

local function getRarityColor(rarity)
    rarity = tostring(rarity or "common"):lower()
    local colors = {
        common = Color3.fromRGB(150, 150, 150), uncommon = Color3.fromRGB(50, 255, 50),
        rare = Color3.fromRGB(50, 150, 255), epic = Color3.fromRGB(180, 50, 255),
        legendary = Color3.fromRGB(255, 150, 0), ["legendary+"] = Color3.fromRGB(255, 220, 0),
        mythic = Color3.fromRGB(255, 50, 50)
    }
    return colors[rarity] or colors.common
end

local function createItemCard(item)
    local card = Instance.new("Frame")
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 45); card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = getRarityColor(item.rarity); stroke.Thickness = 2.5
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; stroke.Parent = card

    if item.imageId and item.imageId ~= "" then
        local img = Instance.new("ImageLabel")
        img.Size = UDim2.new(0.6, 0, 0.4, 0); img.Position = UDim2.new(0.2, 0, 0.1, 0)
        img.BackgroundTransparency = 1; img.Image = item.imageId
        img.ScaleType = Enum.ScaleType.Fit; img.Parent = card
    end

    local name = Instance.new("TextLabel")
    name.Text = item.name or "Item"; name.Size = UDim2.new(1, -10, 0, 40); name.Position = UDim2.new(0, 5, 0.5, 0)
    name.BackgroundTransparency = 1; name.TextColor3 = Color3.fromRGB(255, 255, 255)
    name.Font = Enum.Font.GothamBold; name.TextSize = 10; name.TextWrapped = true; name.Parent = card

    local info = Instance.new("TextLabel")
    info.Text = "Nv." .. (item.levelReq or "1"); info.Size = UDim2.new(1, -10, 0, 20); info.Position = UDim2.new(0, 5, 0.8, 0)
    info.BackgroundTransparency = 1; info.TextColor3 = getRarityColor(item.rarity)
    info.Font = Enum.Font.Gotham; info.TextSize = 9; info.Parent = card

    card.MouseEnter:Connect(function()
        ttTitle.Text = item.name or "Item"; ttTitle.TextColor3 = getRarityColor(item.rarity)
        local stats = {}
        if item.physicalDamage or item.physicalPower then table.insert(stats, "⚔️ Físico: " .. (item.physicalDamage or item.physicalPower)) end
        if item.spellPower then table.insert(stats, "✨ Mágico: " .. item.spellPower) end
        if item.health then table.insert(stats, "❤️ Vida: " .. item.health) end
        if item.defense then table.insert(stats, "🛡️ Defesa: " .. item.defense) end
        if item.currentUpgrade then table.insert(stats, "⬆️ Up: " .. item.currentUpgrade .. "/" .. (item.maxUpgrades or "?")) end
        local desc = "Raridade: " .. (item.rarity or "common"):upper() .. "\n"
        desc = desc .. "Nível Requerido: " .. (item.levelReq or "1") .. "\n\n"
        desc = desc .. "📊 STATUS:\n" .. (next(stats) and table.concat(stats, "\n") or "Nenhum status extra")
        ttContent.Text = desc; tooltip.Visible = true
    end)
    card.MouseLeave:Connect(function() tooltip.Visible = false end)
    return card
end

-- Função principal que atualiza a exibição dos itens na tela
local function updateDisplay()
    for _, c in pairs(scroll:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
    
    local list = {}
    if currentTab == "General" then
        list = inventoryCache[currentCategory] or {}
        scroll.Position = UDim2.new(0, 5, 0, 60)
        scroll.Size = UDim2.new(1, -10, 1, -70)
    else -- "Filtered"
        scroll.Position = UDim2.new(0, 5, 0, 100)
        scroll.Size = UDim2.new(1, -10, 1, -110)
        
        local pool = {}
        -- Corrigido para iterar em todas as categorias do cache
        for _, catItems in pairs(inventoryCache) do
            if type(catItems) == "table" then
                for _, item in pairs(catItems) do table.insert(pool, item) end
            end
        end
        
        for _, item in pairs(pool) do
            local lvl = tonumber(item.levelReq) or 0
            local passLvl = lvl >= filterSettings.minLevel and lvl <= filterSettings.maxLevel
            local phys = tonumber(item.physicalDamage or item.physicalPower) or 0
            local mag = tonumber(item.spellPower) or 0
            local passFocus = true
            if filterSettings.focus == "Magic" then passFocus = mag > phys
            elseif filterSettings.focus == "Physical" then passFocus = phys > mag end
            if passLvl and passFocus then table.insert(list, item) end
        end
        
        table.sort(list, function(a, b)
            local pA = math.max(tonumber(a.physicalDamage or a.physicalPower) or 0, tonumber(a.spellPower) or 0, tonumber(a.health) or 0)
            local pB = math.max(tonumber(b.physicalDamage or b.physicalPower) or 0, tonumber(b.spellPower) or 0, tonumber(b.health) or 0)
            return pA > pB
        end)
    end

    for i = 1, math.min(#list, MAX_ITEMS) do
        createItemCard(list[i]).Parent = scroll
    end
end

-- ==================== EVENTOS E LÓGICA PRINCIPAL ====================

-- Função de Sincronização: Busca no servidor, atualiza o cache e salva localmente
local function synchronizeData()
    showNotification("Sincronizando...", Color3.fromRGB(0, 100, 180))
    local newInventory = fetchInventoryFromServer()
    if newInventory then
        inventoryCache = newInventory
        saveInventoryCache() -- Salva o novo cache no arquivo do usuário
        updateDisplay()
        showNotification("Sincronizado com Sucesso!")
    else
        showNotification("Falha na Sincronização", Color3.fromRGB(150, 40, 40))
    end
end

btnSync.MouseButton1Click:Connect(synchronizeData)

btnGeneral.MouseButton1Click:Connect(function()
    currentTab = "General"; filterPanel.Visible = false; tabsFrame.Visible = true
    btnGeneral.TextColor3 = Color3.fromRGB(255, 255, 255); btnFiltered.TextColor3 = Color3.fromRGB(200, 200, 200)
    updateDisplay()
end)

btnFiltered.MouseButton1Click:Connect(function()
    currentTab = "Filtered"; filterPanel.Visible = true; tabsFrame.Visible = false
    btnFiltered.TextColor3 = Color3.fromRGB(255, 255, 255); btnGeneral.TextColor3 = Color3.fromRGB(200, 200, 200)
    updateDisplay()
end)

for key, btn in pairs(catBtns) do
    btn.MouseButton1Click:Connect(function()
        currentCategory = key
        for _, b in pairs(catBtns) do b.TextColor3 = Color3.fromRGB(200, 200, 200) end
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        updateDisplay()
    end)
end

focusBtn.MouseButton1Click:Connect(function()
    if filterSettings.focus == "All" then filterSettings.focus = "Magic"
    elseif filterSettings.focus == "Magic" then filterSettings.focus = "Physical"
    else filterSettings.focus = "All" end
    focusBtn.Text = "FOCO: " .. filterSettings.focus:upper()
    updateDisplay()
end)

minLvlInput:GetPropertyChangedSignal("Text"):Connect(function()
    filterSettings.minLevel = tonumber(minLvlInput.Text) or 0
    updateDisplay()
end)

maxLvlInput:GetPropertyChangedSignal("Text"):Connect(function()
    filterSettings.maxLevel = tonumber(maxLvlInput.Text) or 999
    updateDisplay()
end)

btnClose.MouseButton1Click:Connect(function() screenGui:Destroy() end)

UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == GUI_KEY then mainFrame.Visible = not mainFrame.Visible end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if tooltip.Visible then
        local m = Player:GetMouse()
        tooltip.Position = UDim2.new(0, m.X + 15, 0, m.Y + 15)
    end
end)

-- ==================== INICIALIZAÇÃO DO SCRIPT ====================
task.spawn(function()
    -- 1. Tenta carregar o inventário do cache local do usuário
    local loadedFromCache = loadInventoryCache()
    
    if loadedFromCache then
        -- 2. Se carregou do cache, exibe imediatamente e avisa
        showNotification("Cache local carregado!", Color3.fromRGB(80, 60, 150))
    else
        -- 3. Se não havia cache, faz a busca inicial no servidor e cria o cache
        synchronizeData()
    end
    
    -- Define a cor do botão da categoria inicial e atualiza a tela
    if catBtns[currentCategory] then
        catBtns[currentCategory].TextColor3 = Color3.fromRGB(255, 255, 255)
    end
    updateDisplay()
end)

print("✅ SCRIPT V5.2: Pronto para hospedar! Tecla [Home] ativada.")
