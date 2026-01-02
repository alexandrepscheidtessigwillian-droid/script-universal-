---------------------------------------------------
-- LOCALPLAYER E SERVIÇOS
---------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

---------------------------------------------------
-- CONFIGURAÇÃO PADRÃO
---------------------------------------------------
local COR_ESP = Color3.fromRGB(255,0,0)
local ESP_ATIVO = true
local NOCLIP_ATIVO = false
local HUMANOID_SPEED = 16
local HUMANOID_JUMP = 50
local savedPoints = {}
local AUTOHEAL_ATIVO = false
local GODMODE_ATIVO = false
local ANTISLAP_ATIVO = false

---------------------------------------------------
-- FUNÇÕES AUXILIARES (UI)
---------------------------------------------------
local function criarLabel(txt)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1,0,0,20)
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.fromRGB(220,220,220)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 14
    l.TextXAlignment = Enum.TextXAlignment.Left
    return l
end

local function criarBox(placeholder, default)
    local b = Instance.new("TextBox")
    b.Size = UDim2.new(1,0,0,25)
    b.PlaceholderText = placeholder
    b.Text = tostring(default)
    b.ClearTextOnFocus = false
    b.BackgroundColor3 = Color3.fromRGB(45,45,50)
    b.TextColor3 = Color3.fromRGB(255,255,255)
    b.Font = Enum.Font.Gotham
    b.TextSize = 14
    Instance.new("UICorner", b)
    return b
end

local function criarToggle(txt, default, setFunc)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1,0,0,25)
    container.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", container)
    label.Size = UDim2.new(0.6,0,1,0)
    label.BackgroundTransparency = 1
    label.Text = txt
    label.TextColor3 = Color3.fromRGB(220,220,220)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0.35,0,1,0)
    btn.Position = UDim2.new(0.65,0,0,0)
    btn.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
    btn.Text = default and "ON" or "OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    Instance.new("UICorner", btn)

    btn.MouseButton1Click:Connect(function()
        default = not default
        btn.BackgroundColor3 = default and Color3.fromRGB(0,200,0) or Color3.fromRGB(200,0,0)
        btn.Text = default and "ON" or "OFF"
        setFunc(default)
    end)

    return container
end

---------------------------------------------------
-- ESP CORRIGIDO (INTEGRADO AO BOTÃO ESP)
---------------------------------------------------
local ESPs = {}

local function ehInimigo(player)
    if player == LocalPlayer then return false end
    if not LocalPlayer.Team or not player.Team then return true end
    return LocalPlayer.Team ~= player.Team
end

local function limparESP(player)
    if ESPs[player] then
        if ESPs[player].Highlight then ESPs[player].Highlight:Destroy() end
        if ESPs[player].Billboard then ESPs[player].Billboard:Destroy() end
        ESPs[player] = nil
    end
end

local function criarESP(player)
    local function aplicar(char)
        limparESP(player)

        local hrp = char:WaitForChild("HumanoidRootPart", 10)
        if not hrp then return end

        local highlight = Instance.new("Highlight")
        highlight.FillColor = COR_ESP
        highlight.OutlineColor = COR_ESP
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = char
        highlight.Enabled = false
        highlight.Parent = Workspace

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0,120,0,25)
        billboard.StudsOffset = Vector3.new(0,3,0)
        billboard.AlwaysOnTop = true
        billboard.Adornee = hrp
        billboard.Enabled = false
        billboard.Parent = Workspace

        local text = Instance.new("TextLabel", billboard)
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.TextColor3 = COR_ESP
        text.TextStrokeTransparency = 0
        text.Font = Enum.Font.GothamBold
        text.TextSize = 14

        ESPs[player] = { Highlight = highlight, Billboard = billboard, Text = text }

        char.AncestryChanged:Connect(function()
            if not char:IsDescendantOf(Workspace) then
                limparESP(player)
            end
        end)
    end

    if player.Character then aplicar(player.Character) end
    player.CharacterAdded:Connect(aplicar)
end

for _,p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then criarESP(p) end
end
Players.PlayerAdded:Connect(criarESP)
Players.PlayerRemoving:Connect(limparESP)

---------------------------------------------------
-- GUI PRINCIPAL (IGUAL AO SEU)
---------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalScript_GUI"
gui.Parent = PlayerGui
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,250,0,400)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.new(0.5,0,0.5,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local border = Instance.new("UIStroke", frame)
border.Thickness = 3
border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
task.spawn(function()
    while true do
        border.Color = Color3.fromHSV(tick()%5/5,1,1)
        task.wait(0.03)
    end
end)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,25)
title.BackgroundTransparency = 1
title.Text = "Universal Script"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255,255,255)

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,25,0,20)
closeBtn.Position = UDim2.new(1,-33,0,2)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Text = "X"
Instance.new("UICorner", closeBtn)
closeBtn.MouseButton1Click:Connect(function() gui.Enabled = false end)

local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Size = UDim2.new(0,25,0,20)
minimizeBtn.Position = UDim2.new(1,-65,0,2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(150,150,150)
minimizeBtn.TextColor3 = Color3.new(1,1,1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.Text = "-"
Instance.new("UICorner", minimizeBtn)

local contentFrame = Instance.new("Frame", frame)
contentFrame.Size = UDim2.new(1,0,1,0)
contentFrame.Position = UDim2.new(0,0,0,25)
contentFrame.BackgroundTransparency = 1

local scroll = Instance.new("ScrollingFrame", contentFrame)
scroll.Size = UDim2.new(1, -10, 1, -35)
scroll.Position = UDim2.new(0,5,0,0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 6
scroll.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar

local mainLayout = Instance.new("UIListLayout", scroll)
mainLayout.SortOrder = Enum.SortOrder.LayoutOrder
mainLayout.Padding = UDim.new(0,5)

---------------------------------------------------
-- TODOS OS SEUS BOTÕES (IGUAIS)
---------------------------------------------------
local speedLabel = criarLabel("Speed:"); speedLabel.Parent = scroll
local speedBox = criarBox("Velocidade", HUMANOID_SPEED); speedBox.Parent = scroll

local jumpLabel = criarLabel("Jump:"); jumpLabel.Parent = scroll
local jumpBox = criarBox("Jump", HUMANOID_JUMP); jumpBox.Parent = scroll

-- BOTÃO ESP (USA ESSE)
local espToggle = criarToggle("ESP", true, function(val)
    ESP_ATIVO = val
end); espToggle.Parent = scroll

local noclipToggle = criarToggle("Noclip", false, function(val) NOCLIP_ATIVO = val end); noclipToggle.Parent = scroll
local antiSlapToggle = criarToggle("Anti-Slap", false, function(val) ANTISLAP_ATIVO = val end); antiSlapToggle.Parent = scroll

-- Teleport
local tpLabel = criarLabel("Teleportar por Nick:"); tpLabel.Parent = scroll
local nickBox = criarBox("Nick",""); nickBox.Parent = scroll
local tpBtn = Instance.new("TextButton")
tpBtn.Size = UDim2.new(1,0,0,25)
tpBtn.Text = "Teleportar"
tpBtn.Font = Enum.Font.GothamBold
tpBtn.TextSize = 14
tpBtn.TextColor3 = Color3.new(1,1,1)
tpBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
Instance.new("UICorner", tpBtn)
tpBtn.Parent = scroll
tpBtn.MouseButton1Click:Connect(function()
    local nick = nickBox.Text
    local target = nick ~= "" and Players:FindFirstChild(nick)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame =
            target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
    end
end)

-- Points
local pointsLabel = criarLabel("Salvar Points:"); pointsLabel.Parent = scroll
local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1,0,0,25)
saveBtn.Text = "Salvar Point"
saveBtn.Font = Enum.Font.GothamBold
saveBtn.TextSize = 14
saveBtn.TextColor3 = Color3.new(1,1,1)
saveBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
Instance.new("UICorner", saveBtn)
saveBtn.Parent = scroll

local pointsContainer = Instance.new("Frame", scroll)
pointsContainer.Size = UDim2.new(1,0,0,0)
pointsContainer.BackgroundTransparency = 1
local pointsLayout = Instance.new("UIListLayout", pointsContainer)
pointsLayout.Padding = UDim.new(0,5)

local function atualizarPoints()
    for _,v in ipairs(pointsContainer:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end
    for i,point in ipairs(savedPoints) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,0,0,25)
        btn.Text = "Point "..i
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Color3.new(1,1,1)
        btn.BackgroundColor3 = Color3.fromRGB(0,200,0)
        Instance.new("UICorner", btn)
        btn.Parent = pointsContainer
        btn.MouseButton1Click:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = point
            end
        end)
    end
    pointsContainer.Size = UDim2.new(1,0,0,#savedPoints*30)
end

saveBtn.MouseButton1Click:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        table.insert(savedPoints, LocalPlayer.Character.HumanoidRootPart.CFrame)
        atualizarPoints()
    end
end)

-- Heal
local healLabel = criarLabel("Recuperar Vida:"); healLabel.Parent = scroll
local healBtn = Instance.new("TextButton")
healBtn.Size = UDim2.new(1,0,0,25)
healBtn.Text = "Curar"
healBtn.Font = Enum.Font.GothamBold
healBtn.TextSize = 14
healBtn.TextColor3 = Color3.new(1,1,1)
healBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
Instance.new("UICorner", healBtn)
healBtn.Parent = scroll
healBtn.MouseButton1Click:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = hum.MaxHealth end
end)

local autoHealToggle = criarToggle("Auto-Curar", false, function(val) AUTOHEAL_ATIVO = val end)
autoHealToggle.Parent = scroll

local godToggle = criarToggle("God Mode", false, function(val) GODMODE_ATIVO = val end)
godToggle.Parent = scroll

---------------------------------------------------
-- LOOP PRINCIPAL (ESP USA O BOTÃO ESP)
---------------------------------------------------
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    -- atributos
    hum.WalkSpeed = tonumber(speedBox.Text) or HUMANOID_SPEED
    hum.JumpPower = tonumber(jumpBox.Text) or HUMANOID_JUMP

    if NOCLIP_ATIVO then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    if AUTOHEAL_ATIVO and hum.Health < hum.MaxHealth then
        hum.Health = hum.MaxHealth
    end
    if GODMODE_ATIVO then
        hum.Health = hum.MaxHealth
    end

    if ANTISLAP_ATIVO then
        local v = hrp.AssemblyLinearVelocity
        if math.abs(v.X) > 50 or math.abs(v.Z) > 50 then
            hrp.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
        end
    end

    -- ESP (NUNCA MAIS SÓ CRONÔMETRO)
    for player,data in pairs(ESPs) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
            local enemy = ehInimigo(player)
            if ESP_ATIVO and enemy then
                data.Highlight.Enabled = true
                data.Billboard.Enabled = true
                data.Text.Text = player.Name.." | "..math.floor(dist).." studs"
            else
                data.Highlight.Enabled = false
                data.Billboard.Enabled = false
            end
        end
    end
end)

---------------------------------------------------
-- MINIMIZAR
---------------------------------------------------
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    contentFrame.Visible = not minimized
    frame.Size = minimized and UDim2.new(0,250,0,25) or UDim2.new(0,250,0,400)
    minimizeBtn.Text = minimized and "+" or "-"
end)

---------------------------------------------------
-- FREECAM MOBILE COMPLETA
---------------------------------------------------
local FreeCamAtivo = false
local cameraSpeed = 2
local verticalSpeed = 2
local cam = workspace.CurrentCamera
local moveVector = Vector3.new(0,0,0)

-- Botão na sua rolagem
local freeCamBtn = Instance.new("TextButton", scroll)
freeCamBtn.Size = UDim2.new(1,0,0,25)
freeCamBtn.Text = "FreeCam"
freeCamBtn.Font = Enum.Font.GothamBold
freeCamBtn.TextSize = 14
freeCamBtn.TextColor3 = Color3.new(1,1,1)
freeCamBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
Instance.new("UICorner", freeCamBtn)

-- Botão X para sair da FreeCam
local exitCamBtn = Instance.new("TextButton", gui)
exitCamBtn.Size = UDim2.new(0,35,0,35)
exitCamBtn.Position = UDim2.new(1,-45,0,10)
exitCamBtn.Text = "X"
exitCamBtn.Font = Enum.Font.GothamBold
exitCamBtn.TextSize = 20
exitCamBtn.TextColor3 = Color3.new(1,1,1)
exitCamBtn.BackgroundColor3 = Color3.fromRGB(200,0,0)
Instance.new("UICorner", exitCamBtn)
exitCamBtn.Visible = false

-- Joystick para andar
local joystickFrame = Instance.new("Frame", gui)
joystickFrame.Size = UDim2.new(0,120,0,120)
joystickFrame.Position = UDim2.new(0,20,1,-250) -- ajustado mais para cima
joystickFrame.BackgroundTransparency = 0.5
joystickFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
joystickFrame.Visible = false
Instance.new("UICorner", joystickFrame)

local knob = Instance.new("Frame", joystickFrame)
knob.Size = UDim2.new(0,50,0,50)
knob.Position = UDim2.new(0.5,-25,0.5,-25)
knob.BackgroundColor3 = Color3.fromRGB(150,150,150)
Instance.new("UICorner", knob)

local knobPressed = false
local UserInputService = game:GetService("UserInputService")

-- Subir / Descer
local upBtn = Instance.new("TextButton", gui)
upBtn.Size = UDim2.new(0,35,0,35)
upBtn.Position = UDim2.new(0,20,1,-300)
upBtn.Text = "▲"
upBtn.Font = Enum.Font.GothamBold
upBtn.TextSize = 20
upBtn.TextColor3 = Color3.new(1,1,1)
upBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
Instance.new("UICorner", upBtn)
upBtn.Visible = false

local downBtn = Instance.new("TextButton", gui)
downBtn.Size = UDim2.new(0,35,0,35)
downBtn.Position = UDim2.new(0,20,1,-250)
downBtn.Text = "▼"
downBtn.Font = Enum.Font.GothamBold
downBtn.TextSize = 20
downBtn.TextColor3 = Color3.new(1,1,1)
downBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
Instance.new("UICorner", downBtn)
downBtn.Visible = false

local verticalMove = 0

-- Controles do knob
knob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        knobPressed = true
    end
end)

knob.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        knobPressed = false
        knob.Position = UDim2.new(0.5,-25,0.5,-25)
        moveVector = Vector3.new(0,0,0)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if knobPressed and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local pos = Vector2.new(input.Position.X, input.Position.Y)
        local delta = pos - joystickFrame.AbsolutePosition - Vector2.new(60,60)
        local radius = math.clamp(delta.Magnitude,0,50)
        local dir = delta.Unit * radius
        knob.Position = UDim2.new(0,60+dir.X-25,0,60+dir.Y-25)
        moveVector = Vector3.new(dir.X/50,0,dir.Y/50)
    end
end)

-- Subir/Descer
upBtn.MouseButton1Click:Connect(function()
    verticalMove = verticalSpeed
end)
downBtn.MouseButton1Click:Connect(function()
    verticalMove = -verticalSpeed
end)

-- Ativar FreeCam
freeCamBtn.MouseButton1Click:Connect(function()
    FreeCamAtivo = true
    exitCamBtn.Visible = true
    joystickFrame.Visible = true
    upBtn.Visible = true
    downBtn.Visible = true
    -- Tirar a câmera do personagem
    cam.CameraType = Enum.CameraType.Scriptable
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        cam.CFrame = CFrame.new(hrp.Position + Vector3.new(0,5,0))
    end
end)

-- Fechar FreeCam
exitCamBtn.MouseButton1Click:Connect(function()
    FreeCamAtivo = false
    exitCamBtn.Visible = false
    joystickFrame.Visible = false
    upBtn.Visible = false
    downBtn.Visible = false
    cam.CameraType = Enum.CameraType.Custom
end)

-- Movimento da câmera
RunService.RenderStepped:Connect(function()
    if FreeCamAtivo then
        local cf = cam.CFrame
        local forward = cf.LookVector * moveVector.Z
        local right = cf.RightVector * moveVector.X
        local up = Vector3.new(0, verticalMove, 0)
        cam.CFrame = cf + (forward + right + up) * cameraSpeed
        verticalMove = 0 -- reset após cada frame
    end
end)

---------------------------------------------------
-- CHÃO MÁGICO LOCAL SIMPLES
---------------------------------------------------
local chaoMagicoAtivo = false
local floorSize = Vector3.new(6,1,6)
local floorLifetime = 5 -- segundos que o bloco fica

-- Botão dentro do scroll
local chaoMagicoBtn = Instance.new("TextButton")
chaoMagicoBtn.Size = UDim2.new(1,0,0,25)
chaoMagicoBtn.Text = "Chão Mágico"
chaoMagicoBtn.Font = Enum.Font.GothamBold
chaoMagicoBtn.TextSize = 14
chaoMagicoBtn.TextColor3 = Color3.new(1,1,1)
chaoMagicoBtn.BackgroundColor3 = Color3.fromRGB(0,150,255)
Instance.new("UICorner", chaoMagicoBtn)
chaoMagicoBtn.Parent = scroll

chaoMagicoBtn.MouseButton1Click:Connect(function()
    chaoMagicoAtivo = not chaoMagicoAtivo
    chaoMagicoBtn.Text = chaoMagicoAtivo and "Chão Mágico: Ativado" or "Chão Mágico"
end)

-- Função para criar o bloco
local function criarBloco(pos)
    local bloco = Instance.new("Part")
    bloco.Size = floorSize
    bloco.Position = pos
    bloco.Anchored = true
    bloco.CanCollide = true
    bloco.Material = Enum.Material.SmoothPlastic
    bloco.Color = Color3.fromRGB(0,100,255)
    bloco.Parent = Workspace
    game.Debris:AddItem(bloco, floorLifetime)
end

-- Loop contínuo simples
spawn(function()
    while true do
        if chaoMagicoAtivo then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position - Vector3.new(0, hrp.Size.Y/2 + floorSize.Y/2, 0)
                criarBloco(pos)
            end
        end
        wait(0.1,3) -- a cada meio segundo cria um bloco embaixo
    end
end)

---------------------------------------------------
-- SHIFT LOCK REAL (ESTILO ROBLOX)
---------------------------------------------------

local SHIFTLOCK_ATIVO = false
local Camera = workspace.CurrentCamera
local shiftOffset = Vector3.new(1.8, 0, 0) -- lateral

-- BOTÃO
local shiftLockToggle = criarToggle("Shift Lock", false, function(val)
    SHIFTLOCK_ATIVO = val
end)
shiftLockToggle.Parent = scroll

-- ATUALIZAR PERSONAGEM
local function atualizarChar()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return char,
        char:WaitForChild("Humanoid"),
        char:WaitForChild("HumanoidRootPart")
end

local char, hum, hrp = atualizarChar()

LocalPlayer.CharacterAdded:Connect(function()
    char, hum, hrp = atualizarChar()
end)

-- LOOP
RunService.RenderStepped:Connect(function()
    if FreeCamAtivo then return end

    if SHIFTLOCK_ATIVO then
        -- câmera estilo shift lock
        hum.AutoRotate = false
        hum.CameraOffset = shiftOffset

        -- personagem segue a câmera
        local camLook = Vector3.new(Camera.CFrame.LookVector.X, 0, Camera.CFrame.LookVector.Z)
        if camLook.Magnitude > 0 then
            hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + camLook)
        end
    else
        hum.AutoRotate = true
        hum.CameraOffset = Vector3.new(0,0,0)
    end
end)
