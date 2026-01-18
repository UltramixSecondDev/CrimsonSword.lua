-- Crucible Final: Sistema de Combate + 3 Capas de Energía Argent
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

local RS_BASE = CFrame.new(1, 0.5, 0) * CFrame.Angles(0, math.rad(90), 0)
local TEXTURE_ID = "rbxassetid://629019562"
local BLADE_TEX = "rbxassetid://6391592051"

-- Colores actualizados
local C_DARK = Color3.fromRGB(35, 30, 30)
local C_STEEL = Color3.fromRGB(60, 60, 65)
local C_BRONZE = Color3.fromRGB(85, 50, 40)
local C_ENERGY = Color3.fromRGB(255, 10, 10)

-----------------------------------------------------------------------
-- [SISTEMA DE SHAKE]
-----------------------------------------------------------------------
local function applyShake(intensity, duration)
    local startTime = tick()
    local connection
    connection = RunService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        if elapsed < duration then
            local fade = (1 - elapsed / duration)
            local offset = Vector3.new(
                math.random(-10, 10) * intensity * fade,
                math.random(-10, 10) * intensity * fade,
                math.random(-10, 10) * intensity * fade
            )
            camera.CFrame = camera.CFrame * CFrame.new(offset * 0.1)
        else
            connection:Disconnect()
        end
    end)
end

-----------------------------------------------------------------------
-- [SISTEMA DE HACER PAPILLA]
-----------------------------------------------------------------------
local function hacerPapilla(modeloEnemigo, impactoPos)
    local eHum = modeloEnemigo:FindFirstChildOfClass("Humanoid")
    if not eHum or eHum.Health <= 0 then return end
    eHum.Health = 0
    applyShake(1.2, 0.3) 
    for _, parte in pairs(modeloEnemigo:GetChildren()) do
        if parte:IsA("BasePart") then
            for _, joint in pairs(parte:GetChildren()) do
                if joint:IsA("Motor6D") or joint:IsA("Weld") or joint:IsA("ManualWeld") then joint:Destroy() end
            end
            local direccion = (parte.Position - impactoPos).Unit
            parte.Velocity = (direccion + Vector3.new(0, 1, 0)) * 65
            parte.RotVelocity = Vector3.new(math.random(-40,40), math.random(-40,40), math.random(-40,40))
            parte.CanCollide = true
            parte.Color = Color3.fromRGB(150, 0, 0) 
            local g = Instance.new("PointLight", parte)
            g.Color = C_ENERGY; g.Brightness = 4; g.Range = 5
            Debris:AddItem(g, 1)
            local p = Instance.new("ParticleEmitter", parte)
            p.Color = ColorSequence.new(C_ENERGY); p.Size = NumberSequence.new(0.4, 0)
            p.Rate = 120; p.Lifetime = NumberRange.new(0.3, 0.6); p.Speed = NumberRange.new(5, 15); p:Emit(15)
        end
    end
    Debris:AddItem(modeloEnemigo, 2.5) 
end

-----------------------------------------------------------------------
-- [1] CONSTRUCCIÓN
-----------------------------------------------------------------------
local tool = Instance.new("Tool"); tool.Name = "Crucible"; tool.Parent = player.Backpack
local handle = Instance.new("Part"); handle.Name = "Handle"; handle.Size = Vector3.new(0.4, 1.2, 0.4); handle.Transparency = 1; handle.Parent = tool

local function createPiece(name, meshId, size, material, cf, angles, color, applyTex)
    local p = Instance.new("MeshPart")
    p.Name = name; p.MeshId = "rbxassetid://" .. meshId; p.Size = size; p.Material = material or Enum.Material.Metal; p.Color = color
    p.CanCollide = false; p.Massless = true; p.Parent = handle
    local w = Instance.new("WeldConstraint", p); w.Part0, w.Part1 = handle, p
    p.CFrame = handle.CFrame * cf
    if angles then p.CFrame = p.CFrame * CFrame.Angles(math.rad(angles.X), math.rad(angles.Y), math.rad(angles.Z)) end
    if applyTex then
        for _, face in pairs(Enum.NormalId:GetEnumItems()) do
            local t = Instance.new("Texture", p); t.Texture = TEXTURE_ID; t.Face = face; t.Transparency = 0.5; t.Color3 = color; t.StudsPerTileU, t.StudsPerTileV = 1.2, 1.2
        end
    end
    return p
end

local piezas = {
    {n="Grip", id="4828976853", size=Vector3.new(0.2, 0.2, 0.2), col=Color3.fromRGB(180, 164, 139), cf=CFrame.new(0, -0.4, 0)},
    {n="Cover", id="4829018149", size=Vector3.new(0.03, 0.04, 0.04), col=Color3.fromRGB(203, 198, 175), cf=CFrame.new(0, -0.4, 0)},
    {n="P4020", id="4828974020", size=Vector3.new(0.2, 0.2, 0.22), col=Color3.fromRGB(90, 95, 98), cf=CFrame.new(0, 1.3, 0), ang=Vector3.new(0,90,0)},
    {n="P3381", id="4828973381", size=Vector3.new(0.1, 0.1, 0.1), col=Color3.fromRGB(91, 78, 80), cf=CFrame.new(0, 0.9, 0)},
    {n="P4319", id="4828974319", size=Vector3.new(0.2, 0.2, 0.18), col=Color3.fromRGB(123, 123, 124), cf=CFrame.new(0, 0.9, 0), ang=Vector3.new(0,90,0)},
    {n="P4881", id="4828974881", size=Vector3.new(0.2, 0.2, 0.18), col=Color3.fromRGB(105, 102, 92), cf=CFrame.new(0, 0.9, 0), ang=Vector3.new(0,90,0)},
    {n="P2747", id="4829042747", size=Vector3.new(0.025, 0.02, 0.025), col=Color3.fromRGB(162, 159, 140), cf=CFrame.new(0, 1.6, 0), ang=Vector3.new(0,90,0)},
    {n="P6971", id="4828976971", size=Vector3.new(0.14, 0.14, 0.14), col=Color3.fromRGB(199, 191, 159), cf=CFrame.new(0, -1.4, 0)},
    {n="P5551", id="4828975551", size=Vector3.new(0.1, 0.1, 0.1), col=Color3.fromRGB(90, 95, 98), cf=CFrame.new(0, 2, 0), ang=Vector3.new(0,90,0)},
    {n="P5018", id="4828975018", size=Vector3.new(0.15, 0.15, 0.15), col=Color3.fromRGB(123, 123, 124), cf=CFrame.new(0, 1.6, 0), ang=Vector3.new(0,90,0)},
    {n="P4139", id="4828974139", size=Vector3.new(0.2, 0.2, 0.2), col=Color3.fromRGB(105, 102, 92), cf=CFrame.new(0, 0.9, 0), ang=Vector3.new(0,90,0)},
    {n="P7347", id="4828977347", size=Vector3.new(0.18, 0.18, 0.18), col=Color3.fromRGB(162, 159, 140), cf=CFrame.new(0, -1.4, 0)},
    {n="P3738_A", id="4828973381", size=Vector3.new(0.3, 0.3, 0.3), col=Color3.fromRGB(199, 191, 159), cf=CFrame.new(0, -1.2, 0)},
    {n="P3738_B", id="4828973381", size=Vector3.new(0.2, 0.2, 0.2), col=Color3.fromRGB(90, 95, 98), cf=CFrame.new(0, 0.5, 0)},
    {n="P5146", id="4828975146", size=Vector3.new(0.19, 0.19, 0.19), col=Color3.fromRGB(123, 123, 124), cf=CFrame.new(0, 1, 0), ang=Vector3.new(0,90,0)},
    {n="SideMark", id="4828975382", size=Vector3.new(0.15, 0.15, 0.15), col=Color3.fromRGB(199, 191, 159), cf=CFrame.new(0.1, 0.9, 0), ang=Vector3.new(0,90,0)},
    {n="TopGuard", id="4828976014", size=Vector3.new(0.18, 0.18, 0.18), col=Color3.fromRGB(203, 198, 175), cf=CFrame.new(0, 2.2, 0), ang=Vector3.new(0,90,0)}
}
for _, i in pairs(piezas) do createPiece(i.n, i.id, i.size, nil, i.cf, i.ang, i.col, true) end

local bMain = Instance.new("Part", handle); bMain.Name = "BladeMain"; bMain.Transparency = 0.2; bMain.Material = Enum.Material.Neon; bMain.Color = C_ENERGY; bMain.CanCollide = false
local mMain = Instance.new("SpecialMesh", bMain); mMain.MeshId = "rbxassetid://6391398772"; mMain.TextureId = BLADE_TEX; mMain.Scale = Vector3.new(0.1, 0.1, 0.1)
local wMain = Instance.new("Weld", bMain); wMain.Part0, wMain.Part1 = handle, bMain; wMain.C0 = CFrame.new(0, 4.3, 0) * CFrame.Angles(0, math.rad(90), 0)

local bAura = Instance.new("Part", handle); bAura.Name = "BladeAura"; bAura.Transparency = 0.39; bAura.Material = Enum.Material.ForceField; bAura.Color = C_ENERGY; bAura.CanCollide = false
local mAura = Instance.new("SpecialMesh", bAura); mAura.MeshId = "rbxassetid://6391398772"; mAura.TextureId = BLADE_TEX; mAura.Scale = Vector3.new(0.1, 0.1, 0.1)
local wAura = Instance.new("Weld", bAura); wAura.Part0, wAura.Part1 = handle, bAura; wAura.C0 = CFrame.new(0, 4.3, 0) * CFrame.Angles(0, math.rad(90), 0)

local mark = createPiece("Mark", "4828974484", Vector3.new(0.2, 0.2, 0.2), Enum.Material.Neon, CFrame.new(0, 0.9, 0), Vector3.new(0, 90, 0), C_ENERGY, false)
local markA = createPiece("MarkAura", "4828974484", Vector3.new(0.21, 0.21, 0.21), Enum.Material.ForceField, CFrame.new(0, 0.9, 0), Vector3.new(0, 90, 0), C_ENERGY, false)
local light = Instance.new("PointLight", bMain); light.Color = C_ENERGY; light.Range = 15; light.Brightness = 0

-----------------------------------------------------------------------
-- [NUEVO: TRIPLE CAPA DE ENERGÍA DISTRIBUIDA EN LA HOJA]
-----------------------------------------------------------------------
local function crearEnergiaHoja(hoja)
    local offsets = {Vector3.new(0, -1.8, 0), Vector3.new(0, 0, 0), Vector3.new(0, 1.8, 0)}
    for i, offset in ipairs(offsets) do
        local att = Instance.new("Attachment", hoja)
        att.Name = "BladeEnergy_"..i; att.Position = offset
        local p = Instance.new("ParticleEmitter", att)
        p.Texture = "rbxassetid://5076152048"; p.Brightness = 1; p.Color = ColorSequence.new(C_ENERGY)
        p.Lifetime = NumberRange.new(0.5, 0.66); p.LightEmission = 1; p.LockedToPart = true
        p.Rate = 12; p.Rotation = NumberRange.new(-360, 360); p.RotSpeed = NumberRange.new(-360, 360)
        p.Speed = NumberRange.new(0, 0); p.TimeScale = 0.5; p.ZOffset = 0.5
        p.Size = NumberSequence.new({NumberSequenceKeypoint.new(0, 8), NumberSequenceKeypoint.new(1, 0.2)})
        p.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.2, 0.502),
            NumberSequenceKeypoint.new(0.5, 0.59), NumberSequenceKeypoint.new(0.691, 0.708),
            NumberSequenceKeypoint.new(0.865, 0.838), NumberSequenceKeypoint.new(1, 1)
        })
        p.Enabled = false
    end
end
crearEnergiaHoja(bMain)

local a0 = Instance.new("Attachment", bMain); a0.Position = Vector3.new(0, 2.5, 0)
local a1 = Instance.new("Attachment", bMain); a1.Position = Vector3.new(0, -2.5, 0)
local trail = Instance.new("Trail", bMain); trail.Attachment0, trail.Attachment1 = a0, a1; trail.Color = ColorSequence.new(C_ENERGY); trail.Lifetime = 0.3; trail.Enabled = false

-----------------------------------------------------------------------
-- [2] LÓGICA DE COMBATE
-----------------------------------------------------------------------
local equipSnd = Instance.new("Sound", handle); equipSnd.SoundId = "rbxassetid://112303690225030"; equipSnd.Volume = 5
local idleSnd = Instance.new("Sound", handle); idleSnd.SoundId = "rbxassetid://605578076"; idleSnd.Looped = true; idleSnd.Volume = 0.5
local offSnd = Instance.new("Sound", handle); offSnd.SoundId = "rbxassetid://100513131280674"; offSnd.Volume = 2

local comboSounds = {[1] = "rbxassetid://77811291915592", [2] = "rbxassetid://130278732947249", [3] = "rbxassetid://91315302125131", [4] = "rbxassetid://105681148232029", [5] = "rbxassetid://91315302125131"}

local function setFX(val)
    local isEquipped = (val == 0)
    bMain.Transparency = isEquipped and 0.2 or 1; bAura.Transparency = isEquipped and 0.39 or 1
    mark.Transparency = isEquipped and 0 or 1; markA.Transparency = isEquipped and 0.4 or 1
    light.Brightness = isEquipped and 3 or 0
    for _, child in pairs(bMain:GetDescendants()) do
        if child:IsA("ParticleEmitter") then child.Enabled = isEquipped end
    end
end
setFX(1)

local combo, isAttacking, hitTable, canDamage = 1, false, {}, false

bMain.Touched:Connect(function(hit)
    if not canDamage then return end
    local modelo = hit.Parent:FindFirstChild("Humanoid") and hit.Parent or hit.Parent.Parent:FindFirstChild("Humanoid") and hit.Parent.Parent
    if modelo then
        local eHum = modelo:FindFirstChild("Humanoid")
        if eHum and eHum ~= hum and not hitTable[eHum] then
            hitTable[eHum] = true
            local s = Instance.new("Sound", hit); s.SoundId = "rbxassetid://5665936061"; s:Play(); Debris:AddItem(s, 1)
            hacerPapilla(modelo, bMain.Position); applyShake(0.6, 0.2)
        end
    end
end)

tool.Activated:Connect(function()
    if isAttacking or bMain.Transparency == 1 then return end
    isAttacking = true
    local rs = char.Torso:FindFirstChild("Right Shoulder")
    if rs then
        hitTable = {}; canDamage = true; trail.Enabled = true
        local s = Instance.new("Sound", handle); s.SoundId = comboSounds[combo]; s.Volume = combo == 5 and 3 or 1.5; s:Play(); Debris:AddItem(s, 2)
        applyShake(combo == 5 and 0.8 or 0.3, 0.15)
        
        if combo == 1 then
            TweenService:Create(rs, TweenInfo.new(0.3), {C0 = RS_BASE * CFrame.Angles(math.rad(-110), 0, 0)}):Play(); task.wait(0.3)
            TweenService:Create(rs, TweenInfo.new(0.15), {C0 = RS_BASE * CFrame.Angles(math.rad(-110), 0, math.rad(-90))}):Play(); task.wait(0.2)
        elseif combo == 2 then
            TweenService:Create(rs, TweenInfo.new(0.3), {C0 = RS_BASE * CFrame.Angles(math.rad(80), math.rad(-40), 0)}):Play(); task.wait(0.3)
            TweenService:Create(rs, TweenInfo.new(0.15), {C0 = RS_BASE * CFrame.Angles(math.rad(120), 0, math.rad(-60))}):Play(); task.wait(0.2)
        elseif combo == 3 then
            TweenService:Create(rs, TweenInfo.new(0.25), {C0 = RS_BASE * CFrame.Angles(math.rad(-40), math.rad(30), 0)}):Play(); task.wait(0.25)
            TweenService:Create(rs, TweenInfo.new(0.15), {C0 = RS_BASE * CFrame.Angles(math.rad(-40), math.rad(-40), math.rad(-70))}):Play(); task.wait(0.2)
        elseif combo == 4 then
            TweenService:Create(rs, TweenInfo.new(0.4), {C0 = RS_BASE * CFrame.Angles(0, 0, math.rad(95))}):Play(); task.wait(0.4)
            TweenService:Create(rs, TweenInfo.new(0.1), {C0 = RS_BASE * CFrame.Angles(math.rad(90), math.rad(-5), math.rad(40)) * CFrame.new(1,0.1,0)}):Play(); task.wait(0.1)
            TweenService:Create(rs, TweenInfo.new(0.3), {C0 = RS_BASE * CFrame.Angles(math.rad(90), 0, math.rad(-55)) * CFrame.new(1,0.7,0)}):Play(); task.wait(0.3)
        elseif combo == 5 then
            TweenService:Create(rs, TweenInfo.new(0.4), {C0 = RS_BASE * CFrame.Angles(math.rad(-120), 0, math.rad(-15))}):Play(); task.wait(0.4)
            applyShake(1.8, 0.4)
            TweenService:Create(rs, TweenInfo.new(0.12), {C0 = RS_BASE * CFrame.new(1, -0.2, -0.6) * CFrame.Angles(math.rad(-195), 0, math.rad(-85))}):Play(); task.wait(0.12)
            TweenService:Create(rs, TweenInfo.new(0.3), {C0 = RS_BASE * CFrame.new(1, -0.2, -0.6) * CFrame.Angles(math.rad(-145), 0, math.rad(-35))}):Play(); task.wait(0.35)
        end
        canDamage = false; trail.Enabled = false
        TweenService:Create(rs, TweenInfo.new(0.4), {C0 = RS_BASE * CFrame.Angles(math.rad(15), 0, 0)}):Play()
        combo = (combo >= 5) and 1 or combo + 1; task.wait(0.3)
    end
    isAttacking = false
end)

tool.Equipped:Connect(function()
    local rs = char.Torso:FindFirstChild("Right Shoulder")
    if rs then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and (part.Name:find("Arm") or part.Name:find("Hand")) then
                part.LocalTransparencyModifier = 0
                part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function() part.LocalTransparencyModifier = 0 end)
            end
        end
        equipSnd:Play(); TweenService:Create(rs, TweenInfo.new(0.6), {C0 = RS_BASE * CFrame.Angles(math.rad(-20), 0, math.rad(40))}):Play(); task.wait(0.7)
        setFX(0); idleSnd:Play(); TweenService:Create(rs, TweenInfo.new(0.5), {C0 = RS_BASE * CFrame.Angles(math.rad(15), 0, 0)}):Play()
    end
end)

tool.Unequipped:Connect(function()
    idleSnd:Stop(); offSnd:Play(); setFX(1); trail.Enabled = false
    if char.Torso:FindFirstChild("Right Shoulder") then char.Torso["Right Shoulder"].C0 = RS_BASE end
end)

