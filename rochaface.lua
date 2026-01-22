-- Script Higor Rocha [Utilitario V2] com HigorGUI v3
local HigorGUI = loadstring(game:HttpGet("SEU_LINK_AQUI/HigorGUIv4.lua"))()

local GUI = HigorGUI.new({
    Title = "Higor Rocha [Utilitario V2]",
    ToggleKey = Enum.KeyCode.G
})

-- Configurações
local scriptAtivo = true
local autoFarmAtivo = false
local autoAttackAtivo = false
local aerialAttackAtivo = false
local showNamesAtivo = false

-- Services
local players = game:GetService("Players")
local workspace = game:GetService("Workspace")
local player = players.LocalPlayer

-- Sistema de Nomes
local nameTags = {}

local function createNameTag(enemy)
    if not enemy or not enemy:FindFirstChild("HumanoidRootPart") or nameTags[enemy] then return end
    
    local hrp = enemy.HumanoidRootPart
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "EnemyNameTag"
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.AlwaysOnTop = true
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.MaxDistance = 150
    billboard.Parent = hrp
    
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Text = "100%"
    hpLabel.Size = UDim2.new(1, 0, 0.5, 0)
    hpLabel.BackgroundTransparency = 0.8
    hpLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    hpLabel.BorderSizePixel = 0
    hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextSize = 18
    hpLabel.Parent = billboard
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Text = enemy.Name
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0.5, 0)
    nameLabel.BackgroundTransparency = 0.8
    nameLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.BorderSizePixel = 0
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 16
    nameLabel.Parent = billboard
    
    nameTags[enemy] = { Billboard = billboard, HPLabel = hpLabel }
    
    local humanoid = enemy:FindFirstChild("Humanoid")
    if humanoid then
        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health <= 0 then
                if nameTags[enemy] and nameTags[enemy].Billboard then
                    nameTags[enemy].Billboard:Destroy()
                end
                nameTags[enemy] = nil
            else
                local healthPercent = math.floor((humanoid.Health / humanoid.MaxHealth) * 100)
                hpLabel.Text = "❤️ " .. healthPercent .. "%"
                if healthPercent > 75 then
                    hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 50 then
                    hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                elseif healthPercent > 25 then
                    hpLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
                else
                    hpLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                end
            end
        end)
    end
end

local function updateNameTags()
    if not showNamesAtivo then
        for enemy in pairs(nameTags) do
            if nameTags[enemy] and nameTags[enemy].Billboard then
                nameTags[enemy].Billboard:Destroy()
            end
        end
        nameTags = {}
        return
    end
    
    local dungeon = workspace:FindFirstChild("dungeon")
    if dungeon then
        for _, room in pairs(dungeon:GetChildren()) do
            local enemies = room:FindFirstChild("enemyFolder")
            if enemies then
                for _, enemy in pairs(enemies:GetChildren()) do
                    if enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        createNameTag(enemy)
                    end
                end
            end
        end
    end
end

-- ===== JANELAS FLUTUANTES =====

-- Janela COMBATE
local windowCombate = GUI:CreateWindow("Combate", 50, 50, 180, 100)
GUI:AddToggle(windowCombate, "Ataque Aéreo", false, function(state)
    aerialAttackAtivo = state
end)
GUI:AddToggle(windowCombate, "Auto Attack", false, function(state)
    autoAttackAtivo = state
end)
GUI:AddToggle(windowCombate, "Auto Farm", false, function(state)
    autoFarmAtivo = state
end)

-- Janela MOVIMENTOS
local windowMovimentos = GUI:CreateWindow("Movimentos", 250, 50, 180, 100)
GUI:AddToggle(windowMovimentos, "Teleporte", false, function(state)
end)
GUI:AddToggle(windowMovimentos, "Velocidade", false, function(state)
end)
GUI:AddToggle(windowMovimentos, "Voo", false, function(state)
end)

-- Janela VISUAL
local windowVisual = GUI:CreateWindow("Visual", 450, 50, 180, 100)
GUI:AddToggle(windowVisual, "ESP", false, function(state)
end)
GUI:AddToggle(windowVisual, "Hitbox", false, function(state)
end)
GUI:AddToggle(windowVisual, "Mostrar Nomes", false, function(state)
    showNamesAtivo = state
    updateNameTags()
end)

-- Janela CONFIGS
local windowConfigs = GUI:CreateWindow("Configs", 650, 50, 180, 60)
GUI:AddButton(windowConfigs, "Remover Script", function()
    scriptAtivo = false
    for enemy in pairs(nameTags) do
        if nameTags[enemy] and nameTags[enemy].Billboard then
            nameTags[enemy].Billboard:Destroy()
        end
    end
    GUI.ScreenGui:Destroy()
end)

print("✓ Script carregado! Pressione G para toggle | Arraste pelo título")
