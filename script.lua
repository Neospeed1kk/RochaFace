-- Script Principal Final Sem sistema de Hud e tals, porem ainda possui coisas relacionadas que deve ser removido.
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Neospeed1kk/RochaFace/refs/heads/main/gui.lua"))()
local HttpService = game:GetService("HttpService")

-- Nome do arquivo de configuração
local SAVE_FILE = "HigorRocha_Config.json"

-- Estrutura padrão de configurações
local Config = {
    Keybinds = {
        RajadaFarm = "F",
        AutoAttack = "V",
        AtaqueAereo = "H",
        HUDCustomizer = "U"
    },
    Settings = {
        FarmDistance = 12,
        AerialDistance = 15,
        BurstCount = 15,
        SpeedMultiplier = 2,
        FlySpeed = 50,
        FOVValue = 80,
        RainbowSpeed = 15
    },
    Abilities = {}, -- Salva Burst e Keybind de cada habilidade
    HUD = {}
}

-- Funções de Save/Load
local function SaveSettings()
    local success, json = pcall(function() return HttpService:JSONEncode(Config) end)
    if success then writefile(SAVE_FILE, json) end
end

local function LoadSettings()
    if isfile(SAVE_FILE) then
        local success, content = pcall(function() return readfile(SAVE_FILE) end)
        if success then
            local success2, decoded = pcall(function() return HttpService:JSONDecode(content) end)
            if success2 then
                for k, v in pairs(decoded.Keybinds or {}) do Config.Keybinds[k] = v end
                for k, v in pairs(decoded.Settings or {}) do Config.Settings[k] = v end
                Config.Abilities = decoded.Abilities or {}
                Config.HUD = decoded.HUD or {}
                print("✅ Configurações carregadas!")
            end
        end
    end
end

LoadSettings()

-- Services
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local vim = game:GetService("VirtualInputManager")
local player = players.LocalPlayer
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- Variáveis de estado
local scriptAtivo = true
local autoFarmAtivo = false
local autoAttackAtivo = false
local aerialAttackAtivo = false
local farmDistance = Config.Settings.FarmDistance
local aerialDistance = Config.Settings.AerialDistance
local cooldown = false
local duracaoSelecionada = 2
local showNamesAtivo = false
local nameTags = {}

local speedAtivo = false
local speedMultiplier = Config.Settings.SpeedMultiplier
local flyAtivo = false
local flySpeed = Config.Settings.FlySpeed
local fullbrightAtivo = false
local entityRenderAtivo = false
local entityRenderDistance = 500
local fovAtivo = false
local fovValue = Config.Settings.FOVValue
local originalFOV = 70

-- Referências aos módulos
local RajadaFarmModule, AutoAttackModule, AtaqueAereoModule, NomeModule
local SpeedModule, FlyModule, FullbrightModule, EntityRenderModule, FOVModule, HUDModule
local AbilitiesCategory

-- Criar categorias
local Combat = Library:CreateCategory("Combate", UDim2.new(0, 50, 0, 100))
local Movement = Library:CreateCategory("Movimento", UDim2.new(0, 250, 0, 100))
local Visual = Library:CreateCategory("Visuais", UDim2.new(0, 450, 0, 100))
local Utils = Library:CreateCategory("Utilitários", UDim2.new(0, 650, 0, 100))
AbilitiesCategory = Library:CreateCategory("Habilidades", UDim2.new(0, 850, 0, 100))

-- ========== SISTEMA DE HABILIDADES ==========
local ActiveAbilities = {}

local function useAbility(event, burstCount)
    if not event then return end
    local mouse = player:GetMouse()
    local targetPos = mouse.Hit.Position
    
    for i = 1, burstCount do
        task.spawn(function()
            pcall(function()
                event:FireServer(targetPos)
                event:FireServer()
            end)
        end)
    end
end

local function updateAbilities()
    -- Limpar módulos antigos da categoria
    for _, v in pairs(AbilitiesCategory.Options:GetChildren()) do
        if v:IsA("Frame") then v:Destroy() end
    end
    ActiveAbilities = {}

    local backpack = player:FindFirstChild("Backpack")
    local character = player.Character
    local foundTools = {}

    local function scan(container)
        if not container then return end
        for _, tool in pairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local event = tool:FindFirstChild("abilityEvent") or tool:FindFirstChild("spellEvent") or tool:FindFirstChildWhichIsA("RemoteEvent")
                if event then
                    foundTools[tool.Name] = {Tool = tool, Event = event}
                end
            end
        end
    end

    scan(backpack)
    scan(character)

    for name, data in pairs(foundTools) do
        -- Criar configuração se não existir
        if not Config.Abilities[name] then
            Config.Abilities[name] = {Burst = 10, Key = "None"}
        end

        local abilityModule = AbilitiesCategory:AddModule(name, function()
            useAbility(data.Event, Config.Abilities[name].Burst)
        end, true)

        abilityModule:AddSlider("Burst", 1, 100, Config.Abilities[name].Burst, function(val)
            Config.Abilities[name].Burst = val
            SaveSettings()
        end)

        -- Adicionar Keybind na aba de Configurações da Library
        local defaultKey = Config.Abilities[name].Key ~= "None" and Enum.KeyCode[Config.Abilities[name].Key] or nil
        Library:AddKeybind("Hab: " .. name, defaultKey, function(key, pressed)
            if pressed then
                useAbility(data.Event, Config.Abilities[name].Burst)
            else
                -- Apenas mudou a tecla
                Config.Abilities[name].Key = key.Name
                SaveSettings()
            end
        end)

        ActiveAbilities[name] = data
    end

    -- Botão de Scan por último
    AbilitiesCategory:AddModule("🔄 ESCANEAR", function()
        updateAbilities()
    end, true)
end

-- ========== SISTEMA DE NOMES ==========
local function createNameTag(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") or nameTags[enemy] then return end
    local hrp = enemy.HumanoidRootPart
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EnemyNameTag"
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.MaxDistance = 150
    billboard.Active = true
    billboard.ClipsDescendants = false
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.Parent = hrp
    
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Name = "HP_Label"
    hpLabel.Text = "100%"
    hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
    hpLabel.Position = UDim2.new(0, 0, 0, 0)
    hpLabel.BackgroundTransparency = 0.8
    hpLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    hpLabel.BorderSizePixel = 0
    hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hpLabel.TextStrokeTransparency = 0.3
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextSize = 18
    hpLabel.TextScaled = false
    hpLabel.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "Name_Label"
    nameLabel.Text = enemy.Name
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 0.8
    nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.BorderSizePixel = 0
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.TextScaled = false
    nameLabel.Parent = billboard
    
    nameTags[enemy] = { Billboard = billboard, HPLabel = hpLabel, NameLabel = nameLabel }
    
    local humanoid = enemy:FindFirstChild("Humanoid")
    if humanoid then
        local function updateHealth()
            if not humanoid or humanoid.Health <= 0 then
                if nameTags[enemy] and nameTags[enemy].Billboard then nameTags[enemy].Billboard:Destroy() end
                nameTags[enemy] = nil
                return
            end
            local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
            hpLabel.Text = "❤️ " .. healthPercent .. "%"
            if healthPercent > 75 then hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            elseif healthPercent > 50 then hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            elseif healthPercent > 25 then hpLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            else hpLabel.TextColor3 = Color3.fromRGB(255, 0, 0) end
        end
        humanoid:GetPropertyChangedSignal("Health"):Connect(updateHealth)
        updateHealth()
        humanoid.Died:Connect(function()
            if nameTags[enemy] and nameTags[enemy].Billboard then nameTags[enemy].Billboard:Destroy() end
            nameTags[enemy] = nil
        end)
    end
    return billboard
end

local function removeNameTag(enemy)
    if nameTags[enemy] then
        if nameTags[enemy].Billboard then nameTags[enemy].Billboard:Destroy() end
        nameTags[enemy] = nil
    end
end

local function updateNameTags()
    if not showNamesAtivo then
        for enemy in pairs(nameTags) do removeNameTag(enemy) end
        nameTags = {}
        return
    end
    local dungeon = workspace:FindFirstChild("dungeon")
    if not dungeon then return end
    for _, room in pairs(dungeon:GetChildren()) do
        local enemies = room:FindFirstChild("enemyFolder")
        if enemies then
            for _, enemy in pairs(enemies:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then createNameTag(enemy)
                else removeNameTag(enemy) end
            end
        end
    end
    for enemy in pairs(nameTags) do
        if not enemy or not enemy.Parent or not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0 then removeNameTag(enemy) end
    end
end

-- ========== FLUTUAÇÃO ==========
local function makeCharacterFloat(hrp, state)
    if not hrp then return end
    local bv = hrp:FindFirstChild("FloatVelocity")
    if state then
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "FloatVelocity"
            bv.MaxForce = Vector3.new(0, 5000, 0)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.P = 1000
            bv.Parent = hrp
            local bg = hrp:FindFirstChild("FloatGyro")
            if not bg then
                bg = Instance.new("BodyGyro")
                bg.Name = "FloatGyro"
                bg.MaxTorque = Vector3.new(10000, 10000, 10000)
                bg.P = 1000
                bg.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(math.rad(90), 0, 0)
                bg.Parent = hrp
            end
        end
    else
        if bv then bv:Destroy() end
        local bg = hrp:FindFirstChild("FloatGyro")
        if bg then bg:Destroy() end
    end
end

local function smoothAerialPosition(hrp, enemyHrp)
    if not hrp or not enemyHrp then return end
    local enemyPos = enemyHrp.Position
    local aerialPos = enemyPos + Vector3.new(0, aerialDistance, 0)
    hrp.CFrame = CFrame.new(aerialPos) * CFrame.Angles(math.rad(90), 0, 0)
    return aerialPos
end

-- ========== BUSCA INIMIGOS ==========
local function GetClosestEnemy()
    local dungeon = workspace:FindFirstChild("dungeon")
    if not dungeon then return nil end
    if not (player and player.Character and player.Character:FindFirstChild("HumanoidRootPart")) then return nil end
    local myPos = player.Character.HumanoidRootPart.Position
    local closestEnemy = nil
    local shortestDistance = math.huge
    for _, room in pairs(dungeon:GetChildren()) do
        local enemies = room:FindFirstChild("enemyFolder")
        if enemies then
            for _, enemy in pairs(enemies:GetChildren()) do
                local hrp = enemy:FindFirstChild("HumanoidRootPart")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local dist = (myPos - hrp.Position).Magnitude
                    if dist < shortestDistance then shortestDistance = dist; closestEnemy = hrp end
                end
            end
        end
    end
    return closestEnemy
end

-- ========== RAJADA FARM ==========
local function activateRajadaFarm()
    if cooldown then return end
    cooldown = true
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local originalCFrame = hrp.CFrame
        for i = 1, Config.Settings.BurstCount do
            local target = GetClosestEnemy()
            if target then
                hrp.CFrame = target.CFrame * CFrame.new(0, farmDistance, 0)
                vim:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                task.wait(0.01)
                vim:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
            task.wait(0.05)
        end
        hrp.CFrame = originalCFrame
    end
    task.wait(duracaoSelecionada)
    cooldown = false
end

local function toggleAutoAttack() autoAttackAtivo = not autoAttackAtivo end
local function toggleAtaqueAereo() aerialAttackAtivo = not aerialAttackAtivo end

local function toggleSpeed(estado)
    speedAtivo = estado
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = estado and (16 * speedMultiplier) or 16 end
end

local function toggleFly(estado)
    flyAtivo = estado
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChild("FlyVelocity") or Instance.new("BodyVelocity")
        bv.Name = "FlyVelocity"
        bv.MaxForce = estado and Vector3.new(math.huge, math.huge, math.huge) or Vector3.new(0, 0, 0)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
        
        if estado then
            task.spawn(function()
                while flyAtivo and scriptAtivo do
                    local moveDir = player.Character.Humanoid.MoveDirection
                    local camCF = workspace.CurrentCamera.CFrame
                    local velocity = Vector3.new(0, 0, 0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - camCF.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + camCF.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, 1, 0) end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then velocity = velocity - Vector3.new(0, 1, 0) end
                    bv.Velocity = velocity.Unit * flySpeed
                    if velocity.Magnitude == 0 then bv.Velocity = Vector3.new(0, 0, 0) end
                    task.wait()
                end
                bv:Destroy()
            end)
        end
    end
end

local function toggleFullbright(estado)
    fullbrightAtivo = estado
    if estado then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    else
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.OutdoorAmbient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
    end
end

local function toggleEntityRender(estado)
    entityRenderAtivo = estado
end

local function toggleFOV(estado)
    fovAtivo = estado
    if estado then workspace.CurrentCamera.FieldOfView = fovValue
    else workspace.CurrentCamera.FieldOfView = originalFOV end
end

-- ========== CATEGORIA: COMBATE ==========
RajadaFarmModule = Combat:AddModule("Rajada Farm", function() activateRajadaFarm() end, true)
RajadaFarmModule:AddSlider("Distância", 5, 30, farmDistance, function(valor)
    Config.Settings.FarmDistance = valor; farmDistance = valor; SaveSettings()
end)
RajadaFarmModule:AddSlider("Quantidade", 5, 50, Config.Settings.BurstCount, function(valor)
    Config.Settings.BurstCount = valor; SaveSettings()
end)

AutoAttackModule = Combat:AddModule("Auto Attack", function(estado) toggleAutoAttack() end, false)

-- ========== CATEGORIA: MOVIMENTO ==========
AtaqueAereoModule = Movement:AddModule("Ataque Aéreo", function(estado) toggleAtaqueAereo() end, false)
AtaqueAereoModule:AddSlider("Altura", 5, 50, aerialDistance, function(valor)
    Config.Settings.AerialDistance = valor; aerialDistance = valor; SaveSettings()
end)

SpeedModule = Movement:AddModule("Speed", function(estado) toggleSpeed(estado) end, false)
SpeedModule:AddSlider("Multiplicador", 1, 5, speedMultiplier, function(valor)
    Config.Settings.SpeedMultiplier = valor; speedMultiplier = valor; if speedAtivo then toggleSpeed(true) end; SaveSettings()
end)

FlyModule = Movement:AddModule("Fly", function(estado) toggleFly(estado) end, false)
FlyModule:AddSlider("Velocidade", 20, 200, flySpeed, function(valor)
    Config.Settings.FlySpeed = valor; flySpeed = valor; SaveSettings()
end)

-- ========== CATEGORIA: VISUAIS ==========
NomeModule = Visual:AddModule("Nome", function(estado) showNamesAtivo = estado; updateNameTags() end, false)
FullbrightModule = Visual:AddModule("Fullbright", function(estado) toggleFullbright(estado) end, false)
EntityRenderModule = Visual:AddModule("Entity Render", function(estado) toggleEntityRender(estado) end, false)
EntityRenderModule:AddSlider("Distância", 100, 1000, entityRenderDistance, function(valor) entityRenderDistance = valor end)
FOVModule = Visual:AddModule("FOV Changer", function(estado) toggleFOV(estado) end, false)
FOVModule:AddSlider("Valor FOV", 70, 120, fovValue, function(valor)
    Config.Settings.FOVValue = valor; fovValue = valor; if fovAtivo then toggleFOV(true) end; SaveSettings()
end)

-- ========== CATEGORIA: UTILITÁRIOS ==========
Utils:AddModule("Salvar Configurações", function()
    SaveSettings()
    print("💾 Configurações salvas!")
end, true)

Utils:AddModule("Remover Script", function()
    scriptAtivo = false; autoFarmAtivo = false; autoAttackAtivo = false; aerialAttackAtivo = false; showNamesAtivo = false
    speedAtivo = false; flyAtivo = false; fullbrightAtivo = false; entityRenderAtivo = false; fovAtivo = false
    toggleSpeed(false); toggleFly(false); toggleFullbright(false); toggleEntityRender(false); toggleFOV(false)
    for enemy in pairs(nameTags) do removeNameTag(enemy) end
    game:GetService("CoreGui").ManusGuiLib:Destroy()
end, true)

-- ========== INICIALIZAÇÃO DE HABILIDADES ==========
updateAbilities()
player.CharacterAdded:Connect(function()
    task.wait(1)
    updateAbilities()
end)

-- ========== KEYBINDS GERAIS ==========
Library:AddKeybind("Rajada Farm ("..Config.Keybinds.RajadaFarm..")", Enum.KeyCode[Config.Keybinds.RajadaFarm], function(key, pressed) if pressed then activateRajadaFarm() end end)
Library:AddKeybind("Auto Attack ("..Config.Keybinds.AutoAttack..")", Enum.KeyCode[Config.Keybinds.AutoAttack], function(key, pressed) if pressed then toggleAutoAttack() end end)
Library:AddKeybind("Ataque Aéreo ("..Config.Keybinds.AtaqueAereo..")", Enum.KeyCode[Config.Keybinds.AtaqueAereo], function(key, pressed) if pressed then toggleAtaqueAereo() end end)

-- ========== LOOPS ==========
task.spawn(function() while scriptAtivo do if autoFarmAtivo then pcall(function() local target = GetClosestEnemy(); local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart"); if target and hrp then hrp.CFrame = target.CFrame * CFrame.new(0, farmDistance, 0) end end) end; task.wait(0.05) end end)
task.spawn(function()
    local isFloating = false
    while scriptAtivo do
        if aerialAttackAtivo then
            pcall(function()
                local target = GetClosestEnemy()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if target and hrp then
                    if not isFloating then makeCharacterFloat(hrp, true); isFloating = true end
                    smoothAerialPosition(hrp, target)
                    local floatPart = hrp:FindFirstChild("FloatVelocity")
                    if floatPart then floatPart.Velocity = Vector3.new(0, 0, 0) end
                else
                    if isFloating then makeCharacterFloat(hrp, false); isFloating = false end
                end
            end)
        else
            if isFloating then
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if hrp then makeCharacterFloat(hrp, false) end
                isFloating = false
            end
        end
        task.wait(0.1)
    end
end)
task.spawn(function() while scriptAtivo do if autoAttackAtivo then vim:SendMouseButtonEvent(0, 0, 0, true, game, 0); task.wait(0.01); vim:SendMouseButtonEvent(0, 0, 0, false, game, 0) end; task.wait(0.1) end end)
task.spawn(function() while scriptAtivo do if showNamesAtivo then updateNameTags() end; task.wait(0.5) end end)
task.spawn(function() while scriptAtivo do task.wait(10); SaveSettings() end end)

print("✅ Script Principal Atualizado com Sucesso!")
