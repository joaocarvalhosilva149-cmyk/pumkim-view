-- ============================================
-- Destaque de "abobora" com raiva + brilho + nome + distância
-- Para Delta Executor
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Palavras-chave: abobora e abreviações comuns em inglês e outros idiomas
local Keywords = {
    "abobora",   -- português
    "pumpkin",   -- inglês
    "calabaza",  -- espanhol
    "citrouille",-- francês
    "kürbis",    -- alemão
    "zucca",     -- italiano
    "abóbora",   -- português com acento
}

-- Verifica se o nome contém alguma palavra-chave (sem diferenciar maiúsculas/minúsculas)
local function matchesKeyword(name)
    local lowerName = string.lower(name)
    for _, kw in ipairs(Keywords) do
        if string.find(lowerName, string.lower(kw), 1, true) then
            return true
        end
    end
    return false
end

-- Armazena objetos já destacados para evitar criação repetida
local tracked = {}

-- Cria efeitos de destaque e distância
local function createHighlightAndLabel(instance)
    if tracked[instance] then return end
    if not instance:IsA("BasePart") then return end
    if not matchesKeyword(instance.Name) then return end

    tracked[instance] = true

    -- 1. Highlight (efeito de raiva/brilho vermelho)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PumpkinRageHighlight"
    highlight.Adornee = instance
    highlight.FillColor = Color3.fromRGB(255, 0, 0)      -- vermelho raiva
    highlight.OutlineColor = Color3.fromRGB(255, 100, 0) -- laranja
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = instance

    -- 2. BillboardGui (nome + distância)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PumpkinDistanceGui"
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = instance

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- amarelo
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.Text = instance.Name .. " 😡"
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distLabel.Position = UDim2.new(0, 0, 0.6, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    distLabel.TextStrokeTransparency = 0
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.SourceSans
    distLabel.Text = "distância: --"
    distLabel.Parent = billboard

    -- Atualiza distância em tempo real
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not instance.Parent or not billboard.Parent then
            if connection then connection:Disconnect() end
            return
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local dist = (instance.Position - hrp.Position).Magnitude
            distLabel.Text = string.format("distância: %d m", math.floor(dist))
        end
    end)
end

-- Percorre todos os objetos existentes
for _, obj in ipairs(Workspace:GetDescendants()) do
    pcall(createHighlightAndLabel, obj)
end

-- Monitora novos objetos adicionados
Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    pcall(createHighlightAndLabel, obj)
end)

print("[PumpkinRage] Carregado. Objetos correspondentes serão destacados com raiva e exibirão nome + distância.")
