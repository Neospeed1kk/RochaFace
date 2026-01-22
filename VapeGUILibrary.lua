-- Script Principal - Carrega a GUI e adiciona módulos
local VapeGUI = loadstring(game:HttpGet('https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/VapeGUILibrary.lua'))()

-- Inicializar a GUI (cria a interface visual)
local mainapi = VapeGUI:Initialize()

-- AGORA ADICIONE SEUS 3 MÓDULOS ORIGINAIS:
-- 1. Auto Ataque
VapeGUI:AddModule('Combat', {
	Name = 'Auto Ataque',
	Function = function(state)
		print('Auto Ataque:', state)
		-- SUA LÓGICA AQUI
		if state then
			-- Ativar auto ataque
			print("Auto ataque ATIVADO")
		else
			-- Desativar auto ataque
			print("Auto ataque DESATIVADO")
		end
	end,
	Tooltip = 'Ataca automaticamente os inimigos próximos'
})

-- 2. Ataque Aéreo
VapeGUI:AddModule('Combat', {
	Name = 'Ataque Aereo',
	Function = function(state)
		print('Ataque Aereo:', state)
		-- SUA LÓGICA AQUI
		if state then
			print("Ataque aéreo ATIVADO")
		else
			print("Ataque aéreo DESATIVADO")
		end
	end,
	Tooltip = 'Realiza ataques aéreos'
})

-- 3. Nomes e Vida
VapeGUI:AddModule('Render', {
	Name = 'Nomes e Vida',
	Function = function(state)
		print('Nomes e Vida:', state)
		-- SUA LÓGICA DE ESP AQUI
		if state then
			print("ESP ATIVADO")
		else
			print("ESP DESATIVADO")
		end
	end,
	Tooltip = 'Mostra nomes e barras de vida dos jogadores'
})

-- EXEMPLO: Adicionar novo módulo dinamicamente (opcional)
VapeGUI:AddModule('Utility', {
	Name = 'Novo Modulo',
	Function = function(state)
		print('Novo Modulo:', state)
	end,
	Tooltip = 'Descrição do novo módulo'
})

-- Verificar todos os módulos criados
print("=== MÓDULOS CRIADOS ===")
for nome, modulo in pairs(VapeGUI:GetModules()) do
	print(string.format("📦 %s | Categoria: %s | Ativo: %s", 
		nome, 
		modulo.Category, 
		modulo.Enabled and "✅" or "❌"
	))
end

print("\n✅ GUI carregada! Pressione RightShift para abrir/fechar")
