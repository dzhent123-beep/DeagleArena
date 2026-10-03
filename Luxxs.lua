--[[ luxxs v6.1 — Fixed preview click + aim dot ]]

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local PURPLE = Color3.fromRGB(150, 80, 255)
local BG = Color3.fromRGB(18, 16, 26)
local BG2 = Color3.fromRGB(26, 23, 38)
local BG3 = Color3.fromRGB(36, 32, 52)
local WHITE = Color3.fromRGB(255, 255, 255)
local GRAY = Color3.fromRGB(160, 155, 180)
local BODY_GRAY = Color3.fromRGB(150, 150, 156)

local THEME = { accent = PURPLE }
local THEME_LINKS = {}
local function linkTheme(obj, prop)
    THEME_LINKS[#THEME_LINKS + 1] = { obj = obj, prop = prop }
end
local function applyAccent(c)
    THEME.accent = c
    for _, l in ipairs(THEME_LINKS) do
        pcall(function() if l.obj.Parent then l.obj[l.prop] = c end end)
    end
end
local function ACC() return THEME.accent end

local PALETTE = {
    ["Purple"] = Color3.fromRGB(150, 80, 255),
    ["Red"] = Color3.fromRGB(255, 60, 60),
    ["Orange"] = Color3.fromRGB(255, 150, 40),
    ["Yellow"] = Color3.fromRGB(255, 225, 60),
    ["Green"] = Color3.fromRGB(70, 230, 110),
    ["Cyan"] = Color3.fromRGB(70, 200, 255),
    ["Blue"] = Color3.fromRGB(70, 100, 255),
    ["Pink"] = Color3.fromRGB(255, 110, 200),
    ["White"] = Color3.fromRGB(255, 255, 255),
    ["Gold"] = Color3.fromRGB(255, 200, 80),
}
local COLOR_NAMES = { "Rainbow", "Purple", "Red", "Orange", "Yellow", "Green", "Cyan", "Blue", "Pink", "White", "Gold" }
local WING_COLORS = { "White", "Gold", "Rainbow", "Purple", "Cyan", "Pink", "Red" }
local ACCENT_NAMES = { "Purple", "Red", "Orange", "Yellow", "Green", "Cyan", "Blue", "Pink", "Gold" }
local MENU_KEYS = { "RightShift", "LeftShift", "Insert", "Home", "Delete", "End", "F1", "F2", "F3", "F4" }

local function getColor(name, t, off)
    if name == "Rainbow" or name == "Радужный" then
        return Color3.fromHSV((((t or 0) * 0.2) + (off or 0)) % 1, 0.85, 1)
    end
    return PALETTE[name] or PURPLE
end

local connections = {}
local function track(c) connections[#connections + 1] = c return c end
local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), props)
    t:Play() return t
end
local function corner(obj, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = obj; return c
end
local function stroke(obj, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color; s.Thickness = thick or 1; s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border; s.Parent = obj; return s
end

local Flags, Setters, Defaults = {}, {}, {}
local function register(key, default, setter)
    Flags[key] = default; Defaults[key] = default; Setters[key] = setter
end

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "luxxs"; gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true; gui.DisplayOrder = 999
local okParent, parent = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
if not okParent or not parent then parent = LocalPlayer:WaitForChild("PlayerGui") end
if parent:FindFirstChild("luxxs") then parent.luxxs:Destroy() end
gui.Parent = parent

local function notify(text)
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(1, 1)
    f.Size = UDim2.new(0, 260, 0, 40)
    f.Position = UDim2.new(1, 290, 1, -24)
    f.BackgroundColor3 = BG2; f.ZIndex = 200; f.Parent = gui
    corner(f, 10); stroke(f, ACC(), 1.5, 0.3)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1; l.Size = UDim2.new(1, -20, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0); l.RichText = true
    l.Font = Enum.Font.GothamMedium; l.TextSize = 13
    l.TextColor3 = WHITE; l.TextXAlignment = Enum.TextXAlignment.Left
    l.Text = '<b>lu<font color="rgb(150,80,255)">xxs</font></b>   ' .. text
    l.ZIndex = 201; l.Parent = f
    tween(f, 0.45, { Position = UDim2.new(1, -24, 1, -24) }, Enum.EasingStyle.Back)
    task.delay(2.6, function()
        tween(f, 0.35, { Position = UDim2.new(1, 290, 1, -24) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.4, function() f:Destroy() end)
    end)
end

local function makeDraggable(handle, target, onClick)
    local dragging, startPos, startInput, moved = false, nil, nil, false
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; moved = false
            startInput = input.Position; startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onClick then onClick() end
                end
            end)
        end
    end)
    track(UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - startInput
            if delta.Magnitude > 5 then moved = true end
            if moved then
                tween(target, 0.08, { Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) }, Enum.EasingStyle.Linear)
            end
        end
    end))
end

-- ===== KEY =====
local VALID_KEY = "LUXXS"
local UNLOCKED = false
local keyReq = nil
local tryUnlock

local function buildKeyScreen()
    local root = Instance.new("Frame")
    root.Size = UDim2.new(1, 0, 1, 0)
    root.BackgroundColor3 = Color3.fromRGB(8, 6, 14)
    root.BorderSizePixel = 0; root.ZIndex = 100; root.Parent = gui

    local glow = Instance.new("Frame")
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.5, 0, 0.36, 0)
    glow.Size = UDim2.new(0, 620, 0, 620)
    glow.BackgroundColor3 = PURPLE; glow.BackgroundTransparency = 0.92
    glow.BorderSizePixel = 0; glow.ZIndex = 100; glow.Parent = root
    corner(glow, 310)

    local lbl = Instance.new("TextLabel")
    lbl.AnchorPoint = Vector2.new(0.5, 0.5)
    lbl.Position = UDim2.new(0.5, 0, 0.38, 0)
    lbl.Size = UDim2.new(0, 600, 0, 140)
    lbl.BackgroundTransparency = 1; lbl.RichText = true
    lbl.Font = Enum.Font.GothamBlack; lbl.TextSize = 96
    lbl.Text = '<b>LU<font color="rgb(150,80,255)">XX</font>S</b>'
    lbl.TextColor3 = WHITE; lbl.ZIndex = 101; lbl.Parent = root
    local ls = Instance.new("UIScale"); ls.Scale = 0.1; ls.Parent = lbl

    local sub = Instance.new("TextLabel")
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.Position = UDim2.new(0.5, 0, 0.38, 82)
    sub.Size = UDim2.new(0, 400, 0, 20)
    sub.BackgroundTransparency = 1; sub.Font = Enum.Font.Gotham
    sub.TextSize = 13; sub.TextColor3 = GRAY
    sub.Text = "enter access key"; sub.ZIndex = 101
    sub.TextTransparency = 1; sub.Parent = root

    local bar = Instance.new("Frame")
    bar.AnchorPoint = Vector2.new(0.5, 0)
    bar.Position = UDim2.new(0.5, 0, 0.38, 112)
    bar.Size = UDim2.new(0, 380, 0, 4)
    bar.BackgroundColor3 = Color3.fromRGB(40, 35, 60)
    bar.BorderSizePixel = 0; bar.ZIndex = 101; bar.Parent = root
    corner(bar, 2)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = PURPLE; fill.BorderSizePixel = 0; fill.Parent = bar
    corner(fill, 2)

    local box = Instance.new("Frame")
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.Position = UDim2.new(0.5, 0, 0.60, 0)
    box.Size = UDim2.new(0, 340, 0, 50)
    box.BackgroundColor3 = BG2; box.BackgroundTransparency = 1
    box.ZIndex = 101; box.Parent = root
    corner(box, 12)
    local boxStroke = stroke(box, PURPLE, 2, 1)

    local input = Instance.new("TextBox")
    input.AnchorPoint = Vector2.new(0, 0.5)
    input.Position = UDim2.new(0, 16, 0.5, 0)
    input.Size = UDim2.new(1, -120, 1, 0)
    input.BackgroundTransparency = 1; input.Font = Enum.Font.GothamMedium
    input.PlaceholderText = "LUXXS"; input.PlaceholderColor3 = GRAY
    input.Text = ""; input.TextSize = 17; input.TextColor3 = WHITE
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.ClearTextOnFocus = false; input.ZIndex = 102
    input.TextTransparency = 1; input.Parent = box

    local btn = Instance.new("TextButton")
    btn.AnchorPoint = Vector2.new(1, 0.5)
    btn.Position = UDim2.new(1, -8, 0.5, 0)
    btn.Size = UDim2.new(0, 100, 0, 38)
    btn.BackgroundColor3 = PURPLE; btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 14
    btn.TextColor3 = WHITE; btn.Text = "ENTER"
    btn.ZIndex = 102; btn.BackgroundTransparency = 1
    btn.TextTransparency = 1; btn.Parent = box
    corner(btn, 10)

    local hint = Instance.new("TextLabel")
    hint.AnchorPoint = Vector2.new(0.5, 0.5)
    hint.Position = UDim2.new(0.5, 0, 0.60, 50)
    hint.Size = UDim2.new(0, 400, 0, 18)
    hint.BackgroundTransparency = 1; hint.Font = Enum.Font.Gotham
    hint.TextSize = 12; hint.TextColor3 = GRAY
    hint.Text = "default: LUXXS  •  Enter to submit"
    hint.ZIndex = 101; hint.TextTransparency = 1; hint.Parent = root

    keyReq = { root=root, lbl=lbl, ls=ls, sub=sub, bar=bar, fill=fill, box=box, input=input, btn=btn, hint=hint, glow=glow }

    tween(ls, 0.8, { Scale = 1 }, Enum.EasingStyle.Back)
    tween(glow, 0.8, { BackgroundTransparency = 0.88 })
    tween(sub, 0.6, { TextTransparency = 0 })
    task.delay(0.7, function()
        tween(box, 0.4, { BackgroundTransparency = 0 })
        tween(boxStroke, 0.4, { Transparency = 0 })
        tween(input, 0.4, { TextTransparency = 0 })
        tween(btn, 0.4, { BackgroundTransparency = 0, TextTransparency = 0 })
        tween(hint, 0.4, { TextTransparency = 0 })
        tween(fill, 1.4, { Size = UDim2.new(1, 0, 1, 0) }, Enum.EasingStyle.Quart)
        task.wait(0.2)
        pcall(function() input:CaptureFocus() end)
    end)
    task.spawn(function()
        while keyReq and keyReq.root and keyReq.root.Parent do
            tween(lbl, 1.1, { TextTransparency = 0.25 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.1)
            tween(lbl, 1.1, { TextTransparency = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(1.1)
        end
    end)
    input.FocusLost:Connect(function(e) if e then tryUnlock() end end)
    btn.MouseButton1Click:Connect(function() tryUnlock() end)
end

function tryUnlock()
    if not keyReq or UNLOCKED then return end
    local entered = (keyReq.input.Text or ""):upper():gsub("%s", "")
    if entered == VALID_KEY then
        UNLOCKED = true
        local k = keyReq; keyReq = nil
        tween(k.lbl, 0.35, { TextSize = 120, TextTransparency = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        tween(k.ls, 0.4, { Scale = 1.3 })
        tween(k.sub, 0.25, { TextTransparency = 1 })
        tween(k.bar, 0.25, { BackgroundTransparency = 1 })
        tween(k.fill, 0.25, { BackgroundTransparency = 1 })
        tween(k.box, 0.25, { BackgroundTransparency = 1 })
        tween(k.input, 0.25, { TextTransparency = 1 })
        tween(k.btn, 0.25, { BackgroundTransparency = 1, TextTransparency = 1 })
        tween(k.hint, 0.25, { TextTransparency = 1 })
        tween(k.glow, 0.5, { BackgroundTransparency = 1 })
        task.delay(0.55, function() pcall(function() k.root:Destroy() end) end)
        notify("key accepted • welcome")
    else
        local orig = keyReq.box.Position
        for i = 1, 6 do
            keyReq.box.Position = UDim2.new(0.5, (i % 2 == 0) and 8 or -8, 0.60, 0)
            task.wait(0.04)
        end
        keyReq.box.Position = orig
        local s = keyReq.box:FindFirstChildOfClass("UIStroke")
        if s then
            s.Color = Color3.fromRGB(255, 70, 70)
            task.delay(0.6, function() if s and s.Parent then s.Color = PURPLE end end)
        end
        keyReq.input.Text = ""
    end
end

-- ===== COSMETICS =====
local Cos = {}
local setBodyHidden
local hiddenOrig = {}

local function destroyCos(name)
    if Cos[name] then
        for _, o in ipairs(Cos[name].objs) do pcall(function() o:Destroy() end) end
        Cos[name] = nil
        if name == "skeleton" and setBodyHidden then setBodyHidden(false) end
    end
end
local function isOwnCosmetic(p)
    return p:FindFirstAncestor("luxxsWings") or p:FindFirstAncestor("luxxsHat") or p:FindFirstAncestor("luxxsSkeleton")
end
function setBodyHidden(hidden)
    if hidden then
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if (p:IsA("BasePart") or p:IsA("Decal")) and p.Name ~= "HumanoidRootPart" and not isOwnCosmetic(p) then
                if hiddenOrig[p] == nil then hiddenOrig[p] = p.Transparency end
                p.Transparency = 1
            end
        end
    else
        for p, tr in pairs(hiddenOrig) do if p.Parent then p.Transparency = tr end end
        hiddenOrig = {}
    end
end
local function newPart(size, parentObj)
    local p = Instance.new("Part")
    p.Size = size; p.CanCollide = false; p.CanQuery = false; p.CanTouch = false
    p.Massless = true; p.Anchored = false; p.Parent = parentObj
    return p
end
local function buildWings()
    destroyCos("wings")
    local char = LocalPlayer.Character
    local torso = char and (char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso"))
    if not torso then return end
    local model = Instance.new("Model"); model.Name = "luxxsWings"
    local feathers = {}
    for _, side in ipairs({ -1, 1 }) do
        for i = 1, 6 do
            local len = 4.2 - i * 0.35
            local p = newPart(Vector3.new(len, 0.5, 0.08), model)
            p.Material = Enum.Material.Neon
            local w = Instance.new("Weld"); w.Part0 = torso; w.Part1 = p; w.Parent = p
            feathers[#feathers + 1] = { part = p, weld = w, side = side, i = i, len = len }
        end
    end
    model.Parent = char
    Cos.wings = { objs = { model }, model = model, feathers = feathers }
end
local function buildHat()
    destroyCos("hat")
    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    local model = Instance.new("Model"); model.Name = "luxxsHat"
    local slices = {}
    local n = 20
    local maxR = 2.4
    for i = 1, n do
        local t = (i - 1) / (n - 1)
        local r = maxR * (1 - t) ^ 0.75
        if r < 0.06 then r = 0.06 end
        local p = newPart(Vector3.new(0.13, r * 2, r * 2), model)
        p.Shape = Enum.PartType.Cylinder
        p.Material = Enum.Material.SmoothPlastic
        local w = Instance.new("Weld")
        w.Part0 = head; w.Part1 = p
        w.C0 = CFrame.new(0, 0.35 + t * 1.9, 0) * CFrame.Angles(0, 0, math.pi / 2)
        w.Parent = p
        slices[i] = p
    end
    model.Parent = char
    Cos.hat = { objs = { model }, model = model, slices = slices }
end
local function buildTrail()
    destroyCos("trail")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local a0 = Instance.new("Attachment"); a0.Name = "luxxsA0"; a0.Parent = hrp
    local a1 = Instance.new("Attachment"); a1.Name = "luxxsA1"; a1.Parent = hrp
    local tr = Instance.new("Trail")
    tr.Name = "luxxsTrail"; tr.Attachment0 = a0; tr.Attachment1 = a1
    tr.LightEmission = 1; tr.FaceCamera = true
    tr.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.1), NumberSequenceKeypoint.new(1, 1) })
    tr.Parent = hrp
    Cos.trail = { objs = { a0, a1, tr }, a0 = a0, a1 = a1, trail = tr }
end
local function buildSkeleton()
    destroyCos("skeleton")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local model = Instance.new("Model"); model.Name = "luxxsSkeleton"
    local bones = {}
    local defs = {
        { pos = Vector3.new(0, 1.55, 0), size = Vector3.new(0.55, 0.55, 0.55), ball = true },
        { pos = Vector3.new(0, 1.15, 0), size = Vector3.new(0.35, 0.14, 0.14), vert = true },
        { pos = Vector3.new(0, 0.55, 0), size = Vector3.new(1.4, 0.14, 0.14), vert = true },
        { pos = Vector3.new(0, 1.0, 0), size = Vector3.new(1.3, 0.12, 0.12) },
        { pos = Vector3.new(0, 0.05, 0), size = Vector3.new(0.5, 0.12, 0.12) },
        { pos = Vector3.new(-0.65, 0.55, 0), size = Vector3.new(0.9, 0.12, 0.12), vert = true },
        { pos = Vector3.new(-0.65, -0.3, 0), size = Vector3.new(0.8, 0.12, 0.12), vert = true },
        { pos = Vector3.new(0.65, 0.55, 0), size = Vector3.new(0.9, 0.12, 0.12), vert = true },
        { pos = Vector3.new(0.65, -0.3, 0), size = Vector3.new(0.8, 0.12, 0.12), vert = true },
        { pos = Vector3.new(-0.2, -0.65, 0), size = Vector3.new(1.0, 0.16, 0.16), vert = true },
        { pos = Vector3.new(-0.2, -1.55, 0), size = Vector3.new(0.9, 0.14, 0.14), vert = true },
        { pos = Vector3.new(0.2, -0.65, 0), size = Vector3.new(1.0, 0.16, 0.16), vert = true },
        { pos = Vector3.new(0.2, -1.55, 0), size = Vector3.new(0.9, 0.14, 0.14), vert = true },
    }
    for i, d in ipairs(defs) do
        local p = newPart(d.size, model)
        p.Material = Enum.Material.SmoothPlastic
        local rot = CFrame.new()
        if d.ball then p.Shape = Enum.PartType.Ball
        else
            p.Shape = Enum.PartType.Cylinder
            if d.vert then rot = CFrame.Angles(0, 0, math.pi / 2) end
        end
        local w = Instance.new("Weld"); w.Part0 = hrp; w.Part1 = p
        w.C0 = CFrame.new(d.pos) * rot; w.Parent = p
        bones[i] = p
    end
    model.Parent = char
    Cos.skeleton = { objs = { model }, model = model, bones = bones }
    setBodyHidden(true)
end

local SKINS = {
    ["Gold"] = { Color3.fromRGB(255, 200, 40), Enum.Material.Metal },
    ["Neon"] = { Color3.fromRGB(255, 200, 60), Enum.Material.Neon },
    ["Ice"] = { Color3.fromRGB(150, 220, 255), Enum.Material.Ice },
    ["Ghost"] = { Color3.fromRGB(230, 230, 255), Enum.Material.ForceField },
    ["Lava"] = { Color3.fromRGB(255, 80, 20), Enum.Material.CrackedLava },
    ["Black"] = { Color3.fromRGB(20, 20, 20), Enum.Material.Plastic },
}
local SKIN_NAMES = { "Off", "Gold", "Neon", "Ice", "Ghost", "Lava", "Black" }
local skinOrig = {}
local function resetSkin()
    for p, d in pairs(skinOrig) do if p.Parent then p.Color = d.c p.Material = d.m end end
    skinOrig = {}
end
local function applySkin(name)
    resetSkin()
    local skin = SKINS[name]
    local char = LocalPlayer.Character
    if not skin or not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" and not isOwnCosmetic(p) then
            skinOrig[p] = { c = p.Color, m = p.Material }
            p.Color = skin[1]; p.Material = skin[2]
        end
    end
end
local function colorSeq(name, t)
    if name == "Rainbow" then
        local kp = {}
        for k = 0, 6 do kp[#kp + 1] = ColorSequenceKeypoint.new(k / 6, getColor(name, t, -k / 6 * 0.8)) end
        return ColorSequence.new(kp)
    end
    return ColorSequence.new(getColor(name))
end

-- ============================================================
-- AIMBOT
-- ============================================================
local Aim = { fovCircle = nil }
local AIM_PARTS = { "Head", "Torso", "UpperTorso", "HumanoidRootPart", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }
local AIM_MODE = { "Smooth", "Sharp" }

local function getAimPart(plr)
    local char = plr and plr.Character
    if not char then return nil end
    local partName = Flags["Aimbot/Body Part"] or "Head"
    return char:FindFirstChild(partName) or char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
end
local function isAlive(plr)
    local char = plr and plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end
local function isTeam(plr) return plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team end

local function getClosestTarget()
    local cam = workspace.CurrentCamera
    if not cam then return nil end
    local center = cam.ViewportSize / 2
    local best, bestDist = nil, math.huge
    local fov = Flags["Aimbot/FOV"] or 150
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            if not (Flags["Aimbot/Team Check"] and isTeam(plr)) then
                local part = getAimPart(plr)
                if part then
                    local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local d = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if d < bestDist and d <= fov then best = plr; bestDist = d end
                    end
                end
            end
        end
    end
    return best, bestDist
end

local function ensureFovCircle()
    if Aim.fovCircle then return Aim.fovCircle end
    local sg = Instance.new("ScreenGui")
    sg.Name = "luxxsFov"; sg.IgnoreGuiInset = true; sg.ResetOnSpawn = false
    sg.DisplayOrder = 998
    local ok, p = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
    sg.Parent = ok and p or LocalPlayer:WaitForChild("PlayerGui")
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.new(0.5, 0, 0.5, 0)
    f.BackgroundTransparency = 1; f.Visible = false
    f.Parent = sg
    corner(f, 9999)
    local s = Instance.new("UIStroke")
    s.Color = ACC(); s.Thickness = 1.5; s.Transparency = 0.4
    s.Parent = f
    linkTheme(s, "Color")
    Aim.fovCircle = { sg = sg, frame = f, stroke = s }
    return Aim.fovCircle
end

RunService:BindToRenderStep("luxxs_aimbot", Enum.RenderPriority.Camera.Value + 1, function(dt)
    local cam = workspace.CurrentCamera
    if not cam then return end

    local aimOn = Flags["Aimbot/Enabled"]
    if Flags["Aimbot/FOV Circle"] and aimOn then
        local c = ensureFovCircle()
        c.frame.Visible = true
        local fov = Flags["Aimbot/FOV"] or 150
        c.frame.Size = UDim2.new(0, fov * 2, 0, fov * 2)
    elseif Aim.fovCircle then
        Aim.fovCircle.frame.Visible = false
    end

    if not aimOn then return end

    local target = getClosestTarget()
    if not target then return end
    local part = getAimPart(target)
    if not part then return end

    local aimPos = part.Position
    local pred = (Flags["Aimbot/Prediction"] or 0) / 100
    if pred > 0 then
        local char = target.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.RootPart then
            aimPos = aimPos + hum.RootPart.AssemblyLinearVelocity * pred
        end
    end

    local mode = Flags["Aimbot/Mode"] or "Smooth"
    local cur = cam.CFrame

    if mode == "Sharp" then
        cam.CFrame = CFrame.new(cur.Position, aimPos)
    else
        local smooth = math.max(1, Flags["Aimbot/Smoothness"] or 5)
        local alpha = math.clamp(dt * (10 / smooth), 0.03, 1)
        local goal = CFrame.new(cur.Position, aimPos)
        cam.CFrame = cur:Lerp(goal, alpha)
    end
end)

-- ============================================================
-- ESP + CHAMS
-- ============================================================
local ESP = { sg = nil, data = {} }

local function ensureESP()
    if ESP.sg then return end
    local sg = Instance.new("ScreenGui")
    sg.Name = "luxxsESP"; sg.IgnoreGuiInset = true
    sg.ResetOnSpawn = false; sg.DisplayOrder = 5
    local ok, p = pcall(function() return (gethui and gethui()) or game:GetService("CoreGui") end)
    sg.Parent = ok and p or LocalPlayer:WaitForChild("PlayerGui")
    ESP.sg = sg
end

local function drawLineF(frame, p1, p2)
    local dx, dy = p2.X - p1.X, p2.Y - p1.Y
    local len = math.sqrt(dx*dx + dy*dy)
    frame.Position = UDim2.new(0, (p1.X + p2.X)/2, 0, (p1.Y + p2.Y)/2)
    frame.Size = UDim2.new(0, len, 0, 1.2)
    frame.Rotation = math.deg(math.atan2(dy, dx))
end

local R15_EDGES = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local R6_EDGES = {
    {"Head","Torso"},{"Torso","LeftArm"},{"Torso","RightArm"},
    {"Torso","LeftLeg"},{"Torso","RightLeg"},
}
local R15_PARTS = { "Head","UpperTorso","LowerTorso","LeftUpperArm","LeftLowerArm","LeftHand","RightUpperArm","RightLowerArm","RightHand","LeftUpperLeg","LeftLowerLeg","LeftFoot","RightUpperLeg","RightLowerLeg","RightFoot" }
local R6_PARTS  = { "Head","Torso","LeftArm","RightArm","LeftLeg","RightLeg" }

local function getBoneParts(char)
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    local src = isR15 and R15_PARTS or R6_PARTS
    local map = {}
    for _, name in ipairs(src) do
        local p = char:FindFirstChild(name)
        if p then map[name] = p end
    end
    return map, isR15
end

local function createESP(plr)
    local folder = Instance.new("Folder")
    folder.Name = "ESP_" .. plr.Name
    folder.Parent = ESP.sg

    local box2d = Instance.new("Frame")
    box2d.BackgroundTransparency = 1; box2d.BorderSizePixel = 0
    box2d.Visible = false; box2d.Parent = folder
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(255, 60, 60); s.Thickness = 1.5
    s.Parent = box2d

    local nameL = Instance.new("TextLabel")
    nameL.BackgroundTransparency = 1
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 13; nameL.TextColor3 = Color3.fromRGB(255,255,255)
    nameL.TextStrokeTransparency = 0; nameL.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    nameL.Text = plr.Name; nameL.Visible = false; nameL.Parent = folder

    local distL = Instance.new("TextLabel")
    distL.BackgroundTransparency = 1
    distL.Font = Enum.Font.GothamMedium
    distL.TextSize = 12; distL.TextColor3 = Color3.fromRGB(255,255,255)
    distL.TextStrokeTransparency = 0; distL.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    distL.Text = ""; distL.Visible = false; distL.Parent = folder

    local box3d = {}
    for i = 1, 12 do
        local l = Instance.new("Frame")
        l.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
        l.BorderSizePixel = 0; l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.Visible = false; l.Parent = folder
        box3d[i] = l
    end
    local skel = {}
    for i = 1, 20 do
        local l = Instance.new("Frame")
        l.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        l.BorderSizePixel = 0; l.AnchorPoint = Vector2.new(0.5, 0.5)
        l.Visible = false; l.Parent = folder
        skel[i] = l
    end

    local highlight = Instance.new("Highlight")
    highlight.Name = "luxxsChams"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 60, 60)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Adornee = nil
    highlight.Parent = folder

    return { folder = folder, box2d = box2d, box2dStroke = s, name = nameL, dist = distL,
             box3d = box3d, skel = skel, highlight = highlight, char = nil }
end

local function hideESP(d)
    if not d then return end
    d.box2d.Visible = false
    d.name.Visible = false
    d.dist.Visible = false
    for _, l in ipairs(d.box3d) do l.Visible = false end
    for _, l in ipairs(d.skel) do l.Visible = false end
end

local function updateESP()
    if not ESP.sg then return end
    local cam = workspace.CurrentCamera
    if not cam then return end

    local espOn = Flags["ESP/Enabled"]
    local chamsOn = Flags["Chams/Enabled"]
    local show2D = Flags["ESP/2D Box"]
    local show3D = Flags["ESP/3D Box"]
    local showName = Flags["ESP/Name"]
    local showDist = Flags["ESP/Distance"]
    local showSkel = Flags["ESP/Enemy Skeleton"]
    local teamCheck = Flags["ESP/Team Check"]
    local maxDist = Flags["ESP/Max Distance"] or 500

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local head = char and char:FindFirstChild("Head")
            local hum = char and char:FindFirstChild("Humanoid")
            local alive = hum and hum.Health > 0
            local isTeamP = plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team
            local skip = teamCheck and isTeamP

            local d = ESP.data[plr]
            if not d then d = createESP(plr); ESP.data[plr] = d end

            if chamsOn and char and alive and not skip then
                d.highlight.Adornee = char
                d.highlight.Enabled = true
                local c = PALETTE[Flags["Chams/Color"] or "Red"] or Color3.fromRGB(255,60,60)
                d.highlight.FillColor = c
                d.highlight.FillTransparency = 1 - (Flags["Chams/Fill"] or 60) / 100
                d.highlight.OutlineColor = WHITE
                d.highlight.OutlineTransparency = 0
            else
                d.highlight.Enabled = false
            end

            if not espOn or not char or not hrp or not alive or skip then
                hideESP(d)
            else
                local dist = myRoot and (myRoot.Position - hrp.Position).Magnitude or 0
                if dist > maxDist then
                    hideESP(d)
                else
                    local topY = head and (head.Position.Y + head.Size.Y/2 + 0.3) or (hrp.Position.Y + 3)
                    local botY = hrp.Position.Y - 3
                    local halfXZ = 1.5
                    local corners = {}
                    for _, x in ipairs({-halfXZ, halfXZ}) do
                        for _, z in ipairs({-halfXZ, halfXZ}) do
                            for _, y in ipairs({topY, botY}) do
                                local w = Vector3.new(hrp.Position.X + x, y, hrp.Position.Z + z)
                                local s, on = cam:WorldToViewportPoint(w)
                                corners[#corners+1] = {pos = Vector2.new(s.X, s.Y), on = on}
                            end
                        end
                    end
                    local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
                    for _, c in ipairs(corners) do
                        if c.pos.X < minX then minX = c.pos.X end
                        if c.pos.X > maxX then maxX = c.pos.X end
                        if c.pos.Y < minY then minY = c.pos.Y end
                        if c.pos.Y > maxY then maxY = c.pos.Y end
                    end

                    if show2D then
                        d.box2d.Visible = true
                        d.box2d.Position = UDim2.new(0, minX, 0, minY)
                        d.box2d.Size = UDim2.new(0, maxX - minX, 0, maxY - minY)
                    else d.box2d.Visible = false end

                    if showName then
                        d.name.Visible = true
                        d.name.Text = plr.Name
                        d.name.Position = UDim2.new(0, (minX+maxX)/2 - 100, 0, minY - 18)
                        d.name.Size = UDim2.new(0, 200, 0, 16)
                    else d.name.Visible = false end

                    if showDist then
                        d.dist.Visible = true
                        d.dist.Text = string.format("[%d]", math.floor(dist))
                        d.dist.Position = UDim2.new(0, (minX+maxX)/2 - 100, 0, maxY + 2)
                        d.dist.Size = UDim2.new(0, 200, 0, 16)
                    else d.dist.Visible = false end

                    if show3D then
                        local edges = {
                            {1,2},{3,4},{5,6},{7,8},
                            {1,3},{2,4},{5,7},{6,8},
                            {1,5},{2,6},{3,7},{4,8},
                        }
                        for i, e in ipairs(edges) do
                            local c1, c2 = corners[e[1]], corners[e[2]]
                            local l = d.box3d[i]
                            if c1 and c2 and c1.on and c2.on then
                                l.Visible = true
                                drawLineF(l, c1.pos, c2.pos)
                            else l.Visible = false end
                        end
                    else for _, l in ipairs(d.box3d) do l.Visible = false end end

                    if showSkel then
                        local map, isR15 = getBoneParts(char)
                        local edges = isR15 and R15_EDGES or R6_EDGES
                        local used = 0
                        for _, e in ipairs(edges) do
                            local p1, p2 = map[e[1]], map[e[2]]
                            if p1 and p2 then
                                local s1, on1 = cam:WorldToViewportPoint(p1.Position)
                                local s2, on2 = cam:WorldToViewportPoint(p2.Position)
                                used = used + 1
                                local l = d.skel[used]
                                if l then
                                    if on1 and on2 then
                                        l.Visible = true
                                        drawLineF(l, Vector2.new(s1.X, s1.Y), Vector2.new(s2.X, s2.Y))
                                    else l.Visible = false end
                                end
                            end
                        end
                        for i = used + 1, #d.skel do d.skel[i].Visible = false end
                    else for _, l in ipairs(d.skel) do l.Visible = false end end
                end
            end
        end
    end
end

track(RunService.RenderStepped:Connect(updateESP))

-- ===== Heartbeat =====
track(RunService.Heartbeat:Connect(function()
    local t = os.clock()
    local w = Cos.wings
    if w and w.model.Parent then
        local flap = math.sin(t * (Flags["Visuals/Wing Speed"] or 3)) * 0.2
        local cname = Flags["Visuals/Wing Color"]
        for _, f in ipairs(w.feathers) do
            local a = math.rad(10 + f.i * 12) + flap * (0.5 + f.i * 0.12)
            local theta = (f.side == 1) and a or (math.pi - a)
            f.weld.C0 = CFrame.new(f.side * 0.5, 0.45, 0.6)
                * CFrame.Angles(0, f.side * -0.35, 0)
                * CFrame.Angles(0, 0, theta)
                * CFrame.new(f.len / 2, 0, 0)
            f.part.Color = getColor(cname, t, f.i * 0.05)
        end
    end
    local h = Cos.hat
    if h and h.model.Parent then
        local cname = Flags["Visuals/Hat Color"]
        for i, s in ipairs(h.slices) do s.Color = getColor(cname, t, i * 0.07) end
    end
    local tr = Cos.trail
    if tr and tr.trail.Parent then
        local width = (Flags["Visuals/Trail Width"] or 4) * 0.4
        tr.a0.Position = Vector3.new(0, width / 2, 0)
        tr.a1.Position = Vector3.new(0, -width / 2, 0)
        tr.trail.Lifetime = math.max(0.1, (Flags["Visuals/Trail Length"] or 10) / 10)
        tr.trail.Color = colorSeq(Flags["Visuals/Trail Color"], t)
    end
    local sk = Cos.skeleton
    if sk and sk.model.Parent then
        local c = getColor(Flags["Visuals/Skeleton Color"], t, 0)
        for _, b in ipairs(sk.bones) do b.Color = c end
    end
    if Flags["Character/Spin"] then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Flags["Character/Spin Speed"] or 6), 0)
        end
    end
end))

local function applyCosmetics()
    if Flags["Visuals/Wings"] then buildWings() else destroyCos("wings") end
    if Flags["Visuals/Hat"] then buildHat() else destroyCos("hat") end
    if Flags["Visuals/Trail"] then buildTrail() else destroyCos("trail") end
    if Flags["Visuals/Skeleton"] then buildSkeleton() else destroyCos("skeleton") end
    applySkin(Flags["Skins/Skin"] or "Off")
end

track(LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    char:WaitForChild("Head", 10)
    task.wait(0.3)
    applyCosmetics()
end))

-- ===== SHADERS =====
local Shader = {}
local PRESETS = {
    ["Cinematic"] = { b=0.02,c=0.25,s=-0.1,tint=Color3.fromRGB(255,238,220),bloom=0.5,bsize=28,bth=1.0,rays=0.08,dens=0.3,haze=1.2,acol=Color3.fromRGB(190,190,205) },
    ["Neon Night"] = { b=-0.03,c=0.3,s=0.5,tint=Color3.fromRGB(215,190,255),bloom=1.3,bsize=42,bth=0.75,rays=0,dens=0.35,haze=1.5,acol=Color3.fromRGB(110,70,200) },
    ["Sunset"] = { b=0.03,c=0.15,s=0.3,tint=Color3.fromRGB(255,205,160),bloom=0.6,bsize=30,bth=0.9,rays=0.25,dens=0.3,haze=1.8,acol=Color3.fromRGB(255,170,120) },
    ["Vivid"] = { b=0.02,c=0.2,s=0.7,tint=Color3.fromRGB(255,255,255),bloom=0.4,bsize=24,bth=1.0,rays=0.1,dens=0.2,haze=0.5,acol=Color3.fromRGB(200,215,235) },
    ["Noir"] = { b=-0.02,c=0.4,s=-1,tint=Color3.fromRGB(235,235,245),bloom=0.3,bsize=20,bth=1.0,rays=0,dens=0.35,haze=2.2,acol=Color3.fromRGB(160,160,170) },
    ["Dream"] = { b=0.05,c=-0.05,s=0.3,tint=Color3.fromRGB(255,210,255),bloom=1.0,bsize=50,bth=0.7,rays=0.15,dens=0.4,haze=1.0,acol=Color3.fromRGB(255,190,240) },
}
local PRESET_NAMES = { "Off", "Cinematic", "Neon Night", "Sunset", "Vivid", "Noir", "Dream" }
local NEUTRAL = { b=0,c=0,s=0,tint=Color3.fromRGB(255,255,255),bloom=0,bsize=24,bth=1,rays=0 }

local function ensureShader()
    if Shader.cc then return end
    local function mk(c) local i = Instance.new(c); i.Name = "luxxs_"..c; i.Parent = Lighting; return i end
    Shader.cc = mk("ColorCorrectionEffect")
    Shader.bloom = mk("BloomEffect")
    Shader.rays = mk("SunRaysEffect")
    local atm = Lighting:FindFirstChildOfClass("Atmosphere")
    if atm then
        Shader.atm = atm
        Shader.atmOrig = { Density = atm.Density, Haze = atm.Haze, Color = atm.Color }
    else
        Shader.atm = mk("Atmosphere"); Shader.atm.Density = 0; Shader.atmCreated = true
    end
end
local function disableShader(full)
    if not Shader.cc then return end
    Shader.cc.Enabled = false; Shader.bloom.Enabled = false; Shader.rays.Enabled = false
    if Shader.atmOrig then pcall(function() tween(Shader.atm, 0.5, Shader.atmOrig) end)
    elseif Shader.atm then pcall(function() Shader.atm.Density = 0 end) end
    if full then
        for _, k in ipairs({ "cc","bloom","rays" }) do pcall(function() Shader[k]:Destroy() end) end
        if Shader.atmCreated then pcall(function() Shader.atm:Destroy() end) end
        Shader = {}
    end
end
local function refreshShader(time)
    time = time or 0.9
    local preset = PRESETS[Flags["Shaders/Preset"] or "Off"]
    local ob = (Flags["Shaders/Brightness"] or 0) / 100
    local oc = (Flags["Shaders/Contrast"] or 0) / 100
    local os_ = (Flags["Shaders/Saturation"] or 0) / 100
    local obl = (Flags["Shaders/Bloom"] or 0) / 50
    if not preset and ob == 0 and oc == 0 and os_ == 0 and obl == 0 then disableShader(false) return end
    ensureShader()
    local p = preset or NEUTRAL
    Shader.cc.Enabled = true; Shader.bloom.Enabled = true; Shader.rays.Enabled = true
    tween(Shader.cc, time, { Brightness = p.b+ob, Contrast = p.c+oc, Saturation = p.s+os_, TintColor = p.tint })
    tween(Shader.bloom, time, { Intensity = p.bloom+obl, Size = p.bsize, Threshold = p.bth })
    tween(Shader.rays, time, { Intensity = p.rays })
    if preset then tween(Shader.atm, time, { Density = preset.dens, Haze = preset.haze, Color = preset.acol })
    elseif Shader.atmOrig then tween(Shader.atm, time, Shader.atmOrig)
    else tween(Shader.atm, time, { Density = 0 }) end
end

-- ============================================================
-- UI
-- ============================================================
local main = Instance.new("CanvasGroup")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.new(0, 880, 0, 440)
main.BackgroundColor3 = BG; main.BorderSizePixel = 0
main.GroupTransparency = 1; main.Visible = false; main.Parent = gui
corner(main, 14)
local mainStroke = stroke(main, ACC(), 1.5, 0.4); linkTheme(mainStroke, "Color")

local scale = Instance.new("UIScale"); scale.Scale = 0.7; scale.Parent = main
local userScale = 1

local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 46); top.BackgroundColor3 = BG2
top.BorderSizePixel = 0; top.Parent = main

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1; title.Position = UDim2.new(0, 16, 0, 0)
title.Size = UDim2.new(0, 200, 1, 0); title.RichText = true
title.Font = Enum.Font.GothamBold; title.TextSize = 24
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = '<b>lu<font color="rgb(150,80,255)">xxs</font></b>'
title.TextColor3 = WHITE; title.Parent = top

local ver = Instance.new("TextLabel")
ver.BackgroundTransparency = 1; ver.Position = UDim2.new(1, -120, 0, 0)
ver.Size = UDim2.new(0, 104, 1, 0); ver.Font = Enum.Font.Gotham
ver.TextSize = 12; ver.TextColor3 = GRAY; ver.TextXAlignment = Enum.TextXAlignment.Right
ver.Text = "v6.1"; ver.Parent = top

local side = Instance.new("Frame")
side.Position = UDim2.new(0, 0, 0, 46)
side.Size = UDim2.new(0, 130, 1, -46)
side.BackgroundColor3 = BG2; side.BorderSizePixel = 0; side.Parent = main

local sideList = Instance.new("Frame")
sideList.BackgroundTransparency = 1
sideList.Position = UDim2.new(0, 8, 0, 10)
sideList.Size = UDim2.new(1, -16, 1, -20); sideList.Parent = side

local indicator = Instance.new("Frame")
indicator.Size = UDim2.new(0, 4, 0, 24)
indicator.Position = UDim2.new(0, 0, 0, 15)
indicator.BackgroundColor3 = ACC(); indicator.BorderSizePixel = 0
indicator.ZIndex = 3; indicator.Parent = side
corner(indicator, 2); linkTheme(indicator, "BackgroundColor3")

local pages = Instance.new("Frame")
pages.BackgroundTransparency = 1
pages.Position = UDim2.new(0, 140, 0, 56)
pages.Size = UDim2.new(0, 470, 1, -66)
pages.ClipsDescendants = true; pages.Parent = main

local previewPanel = Instance.new("Frame")
previewPanel.Position = UDim2.new(0, 620, 0, 56)
previewPanel.Size = UDim2.new(0, 250, 1, -66)
previewPanel.BorderSizePixel = 0; previewPanel.Parent = main

local tabs = {}
local currentTab = nil
local switching = false

local function selectTab(tab)
    if currentTab == tab or switching then return end
    switching = true
    local old = currentTab
    currentTab = tab
    tween(indicator, 0.35, { Position = UDim2.new(0, 0, 0, 15 + tab.index * 40) }, Enum.EasingStyle.Back)
    for _, t in ipairs(tabs) do
        tween(t.button, 0.25, { TextColor3 = (t == tab) and WHITE or GRAY, BackgroundTransparency = (t == tab) and 0.7 or 1 })
    end
    if old then
        tween(old.page, 0.2, { GroupTransparency = 1, Position = UDim2.new(0, -20, 0, 0) })
        task.delay(0.2, function() old.page.Visible = false end)
    end
    task.delay(old and 0.15 or 0, function()
        tab.page.Position = UDim2.new(0, 20, 0, 0)
        tab.page.GroupTransparency = 1
        tab.page.Visible = true
        tween(tab.page, 0.35, { GroupTransparency = 0, Position = UDim2.new(0, 0, 0, 0) })
        task.delay(0.35, function() switching = false end)
    end)
end

local function createTab(name)
    local index = #tabs
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 34)
    button.Position = UDim2.new(0, 0, 0, index * 40)
    button.BackgroundColor3 = ACC(); button.BackgroundTransparency = 1
    button.Font = Enum.Font.GothamMedium; button.TextSize = 14
    button.TextColor3 = GRAY; button.Text = name
    button.AutoButtonColor = false; button.Parent = sideList
    corner(button, 8); linkTheme(button, "BackgroundColor3")

    local page = Instance.new("CanvasGroup")
    page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1
    page.Visible = false; page.GroupTransparency = 1; page.Parent = pages

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1; scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3; scroll.ScrollBarImageColor3 = ACC()
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = page; linkTheme(scroll, "ScrollBarImageColor3")

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local pad = Instance.new("UIPadding")
    pad.PaddingRight = UDim.new(0, 6); pad.PaddingTop = UDim.new(0, 2); pad.Parent = scroll

    local tab = { button = button, page = page, scroll = scroll, index = index, name = name }
    table.insert(tabs, tab)
    button.MouseButton1Click:Connect(function() selectTab(tab) end)
    button.MouseEnter:Connect(function() if currentTab ~= tab then tween(button, 0.2, { TextColor3 = WHITE }) end end)
    button.MouseLeave:Connect(function() if currentTab ~= tab then tween(button, 0.2, { TextColor3 = GRAY }) end end)

    function tab:Label(text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 20); l.BackgroundTransparency = 1
        l.Font = Enum.Font.GothamBold; l.TextSize = 13
        l.TextColor3 = ACC(); l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = text; l.Parent = scroll; linkTheme(l, "TextColor3")
    end
    function tab:Text(text)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, 0, 0, 24); l.BackgroundColor3 = BG3
        l.Font = Enum.Font.Gotham; l.TextSize = 13
        l.TextColor3 = GRAY; l.TextXAlignment = Enum.TextXAlignment.Left
        l.Text = "   " .. text; l.Parent = scroll
        corner(l, 6); return l
    end
    function tab:Toggle(text, default, callback)
        local key = name .. "/" .. text
        local state = default or false
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 38); row.BackgroundColor3 = BG3
        row.AutoButtonColor = false; row.Text = ""; row.Parent = scroll
        corner(row, 8)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(1, -70, 1, 0); lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14; lbl.TextColor3 = WHITE; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = text; lbl.Parent = row
        local sw = Instance.new("Frame")
        sw.AnchorPoint = Vector2.new(1, 0.5)
        sw.Position = UDim2.new(1, -12, 0.5, 0)
        sw.Size = UDim2.new(0, 40, 0, 20)
        sw.BackgroundColor3 = state and ACC() or Color3.fromRGB(60, 56, 80)
        sw.Parent = row; corner(sw, 10)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        knob.BackgroundColor3 = WHITE; knob.Parent = sw; corner(knob, 8)
        register(key, state, function(v)
            state = v and true or false
            Flags[key] = state
            tween(sw, 0.25, { BackgroundColor3 = state and ACC() or Color3.fromRGB(60, 56, 80) })
            tween(knob, 0.3, { Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8) }, Enum.EasingStyle.Back)
            if callback then task.spawn(callback, state) end
        end)
        row.MouseButton1Click:Connect(function() Setters[key](not state) end)
        row.MouseEnter:Connect(function() tween(row, 0.2, { BackgroundColor3 = Color3.fromRGB(44, 39, 64) }) end)
        row.MouseLeave:Connect(function() tween(row, 0.2, { BackgroundColor3 = BG3 }) end)
    end
    function tab:Button(text, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 0, 38)
        b.BackgroundColor3 = ACC(); b.BackgroundTransparency = 0.25
        b.AutoButtonColor = false; b.Font = Enum.Font.GothamMedium
        b.TextSize = 14; b.TextColor3 = WHITE; b.Text = text
        b.Parent = scroll; corner(b, 8); linkTheme(b, "BackgroundColor3")
        b.MouseEnter:Connect(function() tween(b, 0.2, { BackgroundTransparency = 0 }) end)
        b.MouseLeave:Connect(function() tween(b, 0.2, { BackgroundTransparency = 0.25 }) end)
        b.MouseButton1Click:Connect(function()
            tween(b, 0.08, { Size = UDim2.new(1, -8, 0, 34) })
            task.delay(0.08, function() tween(b, 0.25, { Size = UDim2.new(1, 0, 0, 38) }, Enum.EasingStyle.Back) end)
            if callback then task.spawn(callback) end
        end)
    end
    function tab:Slider(text, min, max, default, callback)
        local key = name .. "/" .. text
        local value = default or min
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 50); row.BackgroundColor3 = BG3
        row.Parent = scroll; corner(row, 8)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 4)
        lbl.Size = UDim2.new(1, -24, 0, 20); lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14; lbl.TextColor3 = WHITE; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = text .. ": " .. tostring(value); lbl.Parent = row
        local bar = Instance.new("Frame")
        bar.Position = UDim2.new(0, 12, 0, 34)
        bar.Size = UDim2.new(1, -24, 0, 6)
        bar.BackgroundColor3 = Color3.fromRGB(60, 56, 80); bar.Parent = row
        corner(bar, 3)
        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = ACC(); fill.BorderSizePixel = 0; fill.Parent = bar
        corner(fill, 3); linkTheme(fill, "BackgroundColor3")
        register(key, value, function(v)
            v = math.clamp(math.floor((tonumber(v) or min) + 0.5), min, max)
            value = v; Flags[key] = v
            lbl.Text = text .. ": " .. tostring(v)
            tween(fill, 0.1, { Size = UDim2.new((v - min) / (max - min), 0, 1, 0) }, Enum.EasingStyle.Linear)
            if callback then task.spawn(callback, v) end
        end)
        local sliding = false
        local function update(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            Setters[key](min + (max - min) * rel)
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = true; update(i.Position.X)
            end
        end)
        track(UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                sliding = false
            end
        end))
        track(UIS.InputChanged:Connect(function(i)
            if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                update(i.Position.X)
            end
        end))
    end
    function tab:Choice(text, options, default, callback)
        local key = name .. "/" .. text
        local idx = table.find(options, default) or 1
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 38); row.BackgroundColor3 = BG3
        row.AutoButtonColor = false; row.Text = ""; row.Parent = scroll
        corner(row, 8)
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1; lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.Size = UDim2.new(0.5, -12, 1, 0); lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14; lbl.TextColor3 = WHITE; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Text = text; lbl.Parent = row
        local val = Instance.new("TextLabel")
        val.BackgroundTransparency = 1; val.Position = UDim2.new(0.5, 0, 0, 0)
        val.Size = UDim2.new(0.5, -12, 1, 0); val.Font = Enum.Font.GothamBold
        val.TextSize = 14; val.TextColor3 = ACC(); val.TextXAlignment = Enum.TextXAlignment.Right
        val.Text = options[idx] .. "  >"; val.Parent = row; linkTheme(val, "TextColor3")
        register(key, options[idx], function(v)
            local i = table.find(options, v)
            if not i then return end
            idx = i; Flags[key] = options[i]
            val.Text = options[i] .. "  >"
            val.TextTransparency = 1; tween(val, 0.25, { TextTransparency = 0 })
            if callback then task.spawn(callback, options[i]) end
        end)
        row.MouseButton1Click:Connect(function() Setters[key](options[idx % #options + 1]) end)
        row.MouseButton2Click:Connect(function() Setters[key](options[(idx - 2) % #options + 1]) end)
        row.MouseEnter:Connect(function() tween(row, 0.2, { BackgroundColor3 = Color3.fromRGB(44, 39, 64) }) end)
        row.MouseLeave:Connect(function() tween(row, 0.2, { BackgroundColor3 = BG3 }) end)
    end
    return tab
end

local function fitScale()
    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    return math.min(1, (vp.X - 20) / 880, (vp.Y - 20) / 440)
end
local isOpen = false
local busy = false
local function openMenu()
    if busy or not UNLOCKED then return end
    busy = true; isOpen = true; main.Visible = true
    local fit = fitScale() * userScale
    scale.Scale = fit * 0.7
    main.GroupTransparency = 1
    tween(scale, 0.45, { Scale = fit }, Enum.EasingStyle.Back)
    tween(main, 0.3, { GroupTransparency = 0 })
    task.delay(0.45, function() busy = false end)
end
local function closeMenu()
    if busy then return end
    busy = true; isOpen = false
    tween(scale, 0.3, { Scale = fitScale() * userScale * 0.7 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    tween(main, 0.3, { GroupTransparency = 1 })
    task.delay(0.3, function() main.Visible = false busy = false end)
end
local function toggleMenu()
    if not UNLOCKED then return end
    if isOpen then closeMenu() else openMenu() end
end

local icon = Instance.new("TextButton")
icon.Size = UDim2.new(0, 56, 0, 56)
icon.Position = UDim2.new(0, 30, 0.5, -28)
icon.BackgroundColor3 = BG; icon.AutoButtonColor = false
icon.Text = ""; icon.ZIndex = 5; icon.Visible = false; icon.Parent = gui
corner(icon, 28)
local iconStroke = stroke(icon, ACC(), 2.5, 0); linkTheme(iconStroke, "Color")
local grad = Instance.new("UIGradient")
grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, PURPLE),
    ColorSequenceKeypoint.new(0.5, WHITE),
    ColorSequenceKeypoint.new(1, PURPLE),
})
grad.Parent = iconStroke
local iconText = Instance.new("TextLabel")
iconText.BackgroundTransparency = 1; iconText.Size = UDim2.new(1, 0, 1, 0)
iconText.Font = Enum.Font.GothamBlack; iconText.TextSize = 22
iconText.RichText = true
iconText.Text = '<b>L<font color="rgb(150,80,255)">X</font></b>'
iconText.TextColor3 = WHITE; iconText.ZIndex = 6; iconText.Parent = icon
local iconScale = Instance.new("UIScale"); iconScale.Parent = icon
task.spawn(function()
    local t = 0
    while gui.Parent do t += task.wait(); grad.Rotation = (t * 90) % 360 end
end)
task.spawn(function()
    while gui.Parent do
        tween(iconScale, 1.2, { Scale = 1.08 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.2)
        tween(iconScale, 1.2, { Scale = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.2)
    end
end)
makeDraggable(icon, icon, toggleMenu)
makeDraggable(top, main)

track(UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    local wantKey = Flags["Settings/Menu Key"] or "RightShift"
    if input.KeyCode == Enum.KeyCode[wantKey] then toggleMenu() end
end))

-- ============================================================
-- TABS (all defaults OFF)
-- ============================================================
local mainTab = createTab("Main")
mainTab:Label("luxxs v6.1")
mainTab:Text("Player: " .. LocalPlayer.Name)
mainTab:Text("Open: " .. (Flags["Settings/Menu Key"] or "RightShift"))
mainTab:Text("Preview: click body parts to select aim target")
mainTab:Text("All features start disabled")

local visTab = createTab("Visuals")
visTab:Label("Angel Wings")
visTab:Toggle("Wings", false, function(s) if s then buildWings() else destroyCos("wings") end end)
visTab:Choice("Wing Color", WING_COLORS, "White")
visTab:Slider("Wing Speed", 1, 10, 3)
visTab:Label("Chinese Hat (Cone)")
visTab:Toggle("Hat", false, function(s) if s then buildHat() else destroyCos("hat") end end)
visTab:Choice("Hat Color", COLOR_NAMES, "Rainbow")
visTab:Label("Trail")
visTab:Toggle("Trail", false, function(s) if s then buildTrail() else destroyCos("trail") end end)
visTab:Choice("Trail Color", COLOR_NAMES, "Rainbow")
visTab:Slider("Trail Length", 1, 30, 10)
visTab:Slider("Trail Width", 1, 10, 4)
visTab:Label("Skeleton (on yourself)")
visTab:Toggle("Skeleton", false, function(s) if s then buildSkeleton() else destroyCos("skeleton") end end)
visTab:Choice("Skeleton Color", COLOR_NAMES, "White")

local espTab = createTab("ESP")
espTab:Label("ESP")
espTab:Toggle("Enabled", false)
espTab:Toggle("2D Box", false)
espTab:Toggle("3D Box", false)
espTab:Toggle("Name", false)
espTab:Toggle("Distance", false)
espTab:Toggle("Enemy Skeleton", false)
espTab:Toggle("Team Check", false)
espTab:Slider("Max Distance", 20, 1000, 500)
espTab:Label("Chams (independent)")
espTab:Toggle("Chams", false)
espTab:Choice("Chams Color", COLOR_NAMES, "Red")
espTab:Slider("Chams Fill %", 0, 100, 60)

local aimTab = createTab("Aimbot")
aimTab:Label("Aimbot")
aimTab:Toggle("Enabled", false)
aimTab:Toggle("Team Check", false)
aimTab:Toggle("FOV Circle", false)
aimTab:Choice("Mode", AIM_MODE, "Smooth")
aimTab:Choice("Body Part", AIM_PARTS, "Head")
aimTab:Slider("FOV", 20, 400, 150)
aimTab:Slider("Smoothness", 1, 20, 5)
aimTab:Slider("Prediction %", 0, 100, 0)

local origZoom = { LocalPlayer.CameraMinZoomDistance, LocalPlayer.CameraMaxZoomDistance }
local chTab = createTab("Character")
chTab:Toggle("Third Person", false, function(s)
    if s then
        LocalPlayer.CameraMinZoomDistance = 8; LocalPlayer.CameraMaxZoomDistance = 20
    else
        LocalPlayer.CameraMinZoomDistance = origZoom[1]; LocalPlayer.CameraMaxZoomDistance = origZoom[2]
    end
end)
chTab:Toggle("Spin", false)
chTab:Slider("Spin Speed", 1, 100, 6)
chTab:Slider("Camera FOV", 50, 110, math.clamp(math.floor(workspace.CurrentCamera.FieldOfView + 0.5), 50, 110), function(v)
    workspace.CurrentCamera.FieldOfView = v
end)

local skTab = createTab("Skins")
skTab:Choice("Skin", SKIN_NAMES, "Off", function(n) applySkin(n) end)

local shTab = createTab("Shaders")
shTab:Choice("Preset", PRESET_NAMES, "Off", function() refreshShader(0.9) end)
shTab:Slider("Brightness", -50, 50, 0, function() refreshShader(0.15) end)
shTab:Slider("Contrast", -50, 50, 0, function() refreshShader(0.15) end)
shTab:Slider("Saturation", -100, 100, 0, function() refreshShader(0.15) end)
shTab:Slider("Bloom", 0, 100, 0, function() refreshShader(0.15) end)
shTab:Button("Reset Shaders", function()
    Setters["Shaders/Preset"]("Off"); Setters["Shaders/Brightness"](0)
    Setters["Shaders/Contrast"](0); Setters["Shaders/Saturation"](0); Setters["Shaders/Bloom"](0)
end)

local profTab = createTab("Profile")
local profName = profTab:Text("Name: " .. LocalPlayer.Name)
profTab:Text("Display: " .. (LocalPlayer.DisplayName or LocalPlayer.Name))
profTab:Text("ID: " .. tostring(LocalPlayer.UserId))
profTab:Button("Refresh", function()
    profName.Text = "   Name: " .. LocalPlayer.Name
end)

local setTab = createTab("Settings")
setTab:Label("Menu")
setTab:Slider("Menu Size (%)", 50, 150, 100, function(v)
    userScale = v / 100
    if isOpen then tween(scale, 0.25, { Scale = fitScale() * userScale }, Enum.EasingStyle.Quint) end
end)
setTab:Choice("Accent Color", ACCENT_NAMES, "Purple", function(n) applyAccent(PALETTE[n] or PURPLE) end)
setTab:Choice("Menu Key", MENU_KEYS, "RightShift")

setTab:Label("Configs")
local FOLDER = "luxxs"
local hasFS = type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function"
local SLOTS = { "1", "2", "3", "4", "5" }
local function cfgPath(slot) return FOLDER .. "/config_" .. slot .. ".json" end
local function isSettingsKey(k) return k:sub(1, 9) == "Settings/" end
local function ensureFolder()
    if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(FOLDER) then
        pcall(makefolder, FOLDER)
    end
end
local function saveConfig(slot)
    if not hasFS then notify("File system unavailable") return end
    ensureFolder()
    local data = {}
    for k, v in pairs(Flags) do if not isSettingsKey(k) then data[k] = v end end
    local ok = pcall(function() writefile(cfgPath(slot), HttpService:JSONEncode(data)) end)
    notify(ok and ("Saved: slot " .. slot) or "Save error")
end
local function loadConfig(slot, silent)
    if not hasFS then if not silent then notify("File system unavailable") end return end
    if not isfile(cfgPath(slot)) then if not silent then notify("Empty: slot " .. slot) end return end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(cfgPath(slot))) end)
    if not ok or type(data) ~= "table" then notify("Read error") return end
    for k, v in pairs(data) do
        if Setters[k] and not isSettingsKey(k) then Setters[k](v) end
    end
    notify("Loaded: slot " .. slot)
end
local function resetAll()
    for k, d in pairs(Defaults) do
        if not isSettingsKey(k) and Setters[k] then Setters[k](d) end
    end
    notify("All settings reset")
end
local function unload()
    for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
    pcall(function() RunService:UnbindFromRenderStep("luxxs_aimbot") end)
    destroyCos("wings"); destroyCos("hat"); destroyCos("trail"); destroyCos("skeleton")
    resetSkin()
    if origZoom then
        LocalPlayer.CameraMinZoomDistance = origZoom[1]
        LocalPlayer.CameraMaxZoomDistance = origZoom[2]
    end
    disableShader(true)
    if Aim.fovCircle then pcall(function() Aim.fovCircle.sg:Destroy() end) end
    if ESP.sg then pcall(function() ESP.sg:Destroy() end) end
    gui:Destroy()
end
setTab:Choice("Config Slot", SLOTS, "1")
setTab:Button("Save Config", function() saveConfig(Flags["Settings/Config Slot"]) end)
setTab:Button("Load Config", function() loadConfig(Flags["Settings/Config Slot"]) end)
setTab:Toggle("Autoload", false, function(state)
    if not hasFS then return end
    ensureFolder()
    pcall(function() writefile(FOLDER .. "/autoload.txt", state and Flags["Settings/Config Slot"] or "") end)
    notify(state and "Autoload ON" or "Autoload OFF")
end)
setTab:Button("Reset All", resetAll)
setTab:Button("Close Menu", closeMenu)
setTab:Button("Unload luxxs", unload)

-- ============================================================
-- PREVIEW (clickable body, flying aim dot)
-- ============================================================
local function solid(parentObj, x, y, w, h, color, z, r)
    local f = Instance.new("Frame")
    f.Position = UDim2.new(0, x, 0, y)
    f.Size = UDim2.new(0, w, 0, h)
    f.BackgroundColor3 = color; f.BorderSizePixel = 0
    f.ZIndex = z or 1; f.Parent = parentObj
    if r then corner(f, r) end
    return f
end
local function line(parentObj, x1, y1, x2, y2, thick, color, z)
    local dx, dy = x2 - x1, y2 - y1
    local f = Instance.new("Frame")
    f.AnchorPoint = Vector2.new(0.5, 0.5)
    f.Position = UDim2.new(0, (x1 + x2) / 2, 0, (y1 + y2) / 2)
    f.Size = UDim2.new(0, math.sqrt(dx * dx + dy * dy), 0, thick)
    f.Rotation = math.deg(math.atan2(dy, dx))
    f.BackgroundColor3 = color; f.BorderSizePixel = 0
    f.ZIndex = z or 1; f.Parent = parentObj
    return f
end

local function buildPreview(panel)
    panel.BackgroundColor3 = WHITE; panel.ClipsDescendants = true
    corner(panel, 10)
    local pStroke = stroke(panel, ACC(), 1, 0.6); linkTheme(pStroke, "Color")
    local bgGrad = Instance.new("UIGradient")
    bgGrad.Color = ColorSequence.new(Color3.fromRGB(28, 20, 46), Color3.fromRGB(10, 9, 15))
    bgGrad.Rotation = 90; bgGrad.Parent = panel

    local cap = Instance.new("TextLabel")
    cap.BackgroundTransparency = 1
    cap.Position = UDim2.new(0, 12, 0, 6)
    cap.Size = UDim2.new(0, 200, 0, 16)
    cap.Font = Enum.Font.GothamBold; cap.TextSize = 11
    cap.TextColor3 = GRAY; cap.TextXAlignment = Enum.TextXAlignment.Left
    cap.Text = "PREVIEW - click body"; cap.ZIndex = 20; cap.Parent = panel

    local fig = Instance.new("Frame")
    fig.AnchorPoint = Vector2.new(0.5, 0.5)
    fig.Position = UDim2.new(0.5, 0, 0, 205)
    fig.Size = UDim2.new(0, 90, 0, 170)
    fig.BackgroundTransparency = 1; fig.Parent = panel
    local figScale = Instance.new("UIScale"); figScale.Scale = 1.35; figScale.Parent = fig

    local body = Instance.new("Frame")
    body.Size = UDim2.new(1, 0, 1, 0)
    body.BackgroundTransparency = 1; body.Parent = fig

    -- TRAIL
    local trailF = {}
    for k = 1, 12 do
        local f = solid(body, 0, 0, 12, 10, WHITE, 1, 5)
        f.AnchorPoint = Vector2.new(0.5, 0.5)
        trailF[k] = f
    end

    -- WINGS
    local wingF = {}
    local lens = { 56, 52, 46, 40, 34 }
    for _, side in ipairs({ -1, 1 }) do
        for i = 1, 5 do
            local f = solid(body, 0, 0, lens[i], 9, WHITE, 1, 5)
            f.AnchorPoint = Vector2.new(0.5, 0.5)
            wingF[#wingF + 1] = { f = f, side = side, i = i, len = lens[i] }
        end
    end

    -- BODY PARTS (clickable)
    local bodyMap = {
        Head     = { x=32, y=14,  w=26, h=26, r=13 },
        Torso    = { x=25, y=44,  w=40, h=56, r=8 },
        LeftArm  = { x=10, y=46,  w=12, h=52, r=6 },
        RightArm = { x=68, y=46,  w=12, h=52, r=6 },
        LeftLeg  = { x=27, y=102, w=16, h=62, r=6 },
        RightLeg = { x=47, y=102, w=16, h=62, r=6 },
    }
    local AIM_POINT = {
        Head = { 45, 27 }, Torso = { 45, 72 }, UpperTorso = { 45, 55 },
        HumanoidRootPart = { 45, 92 }, LeftArm = { 16, 72 }, RightArm = { 74, 72 },
        LeftLeg = { 35, 130 }, RightLeg = { 55, 130 },
    }

    local bodyParts = {}
    local hovered = {}
    local flash = {}

    local function selectPart(name)
        if Setters["Aimbot/Body Part"] then
            Setters["Aimbot/Body Part"](name)
        end
        flash[name] = os.clock()
    end

    for name, d in pairs(bodyMap) do
        local f = solid(body, d.x, d.y, d.w, d.h, BODY_GRAY, 4, d.r)
        f.Active = true
        f.Selectable = true
        bodyParts[name] = f

        f.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                selectPart(name)
            end
        end)
        f.MouseEnter:Connect(function() hovered[name] = true end)
        f.MouseLeave:Connect(function() hovered[name] = nil end)
    end

    -- SKELETON
    local skel = Instance.new("Frame")
    skel.Size = UDim2.new(1, 0, 1, 0)
    skel.BackgroundTransparency = 1; skel.ZIndex = 6; skel.Parent = body
    local J = {
        head = { 45, 27 }, neck = { 45, 44 },
        shL = { 26, 50 }, shR = { 64, 50 },
        elL = { 16, 74 }, elR = { 74, 74 },
        haL = { 16, 98 }, haR = { 74, 98 },
        pel = { 45, 100 }, hipL = { 35, 102 }, hipR = { 55, 102 },
        knL = { 35, 133 }, knR = { 55, 133 },
        ftL = { 35, 164 }, ftR = { 55, 164 },
    }
    local BONES = {
        { "head", "neck" }, { "neck", "pel" }, { "neck", "shL" }, { "neck", "shR" },
        { "shL", "elL" }, { "elL", "haL" }, { "shR", "elR" }, { "elR", "haR" },
        { "pel", "hipL" }, { "pel", "hipR" },
        { "hipL", "knL" }, { "knL", "ftL" }, { "hipR", "knR" }, { "knR", "ftR" },
    }
    local skelParts = {}
    for _, b in ipairs(BONES) do
        local a, c = J[b[1]], J[b[2]]
        skelParts[#skelParts + 1] = line(skel, a[1], a[2], c[1], c[2], 2, WHITE, 6)
    end
    for _, p in pairs(J) do
        skelParts[#skelParts + 1] = solid(skel, p[1] - 3, p[2] - 3, 6, 6, WHITE, 7, 3)
    end

    -- HAT (cone)
    local hatS = {}
    local hatN = 24
    local hatMaxW = 74
    for i = 1, hatN do
        local t = (i - 1) / (hatN - 1)
        local w = hatMaxW * (t ^ 1.35)
        if w < 2 then w = 2 end
        local y = 2 + 28 * t
        hatS[i] = solid(body, 45 - w / 2, y, w, 1.6, WHITE, 5)
    end
    local brim = solid(body, 45 - hatMaxW/2, 30, hatMaxW, 2, WHITE, 5)

    -- AIM DOT (non-interactive overlay)
    local aimGlow = Instance.new("Frame")
    aimGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    aimGlow.Size = UDim2.new(0, 26, 0, 26)
    aimGlow.BackgroundColor3 = Color3.fromRGB(255, 40, 40)
    aimGlow.BackgroundTransparency = 0.75
    aimGlow.BorderSizePixel = 0; aimGlow.ZIndex = 12
    aimGlow.Active = false; aimGlow.Selectable = false
    aimGlow.Parent = body
    corner(aimGlow, 13)

    local aimDot = Instance.new("Frame")
    aimDot.AnchorPoint = Vector2.new(0.5, 0.5)
    aimDot.Size = UDim2.new(0, 7, 0, 7)
    aimDot.BackgroundColor3 = Color3.fromRGB(255, 30, 30)
    aimDot.BorderSizePixel = 0; aimDot.ZIndex = 13
    aimDot.Active = false; aimDot.Selectable = false
    aimDot.Parent = body
    corner(aimDot, 4)

    local currentX, currentY = 45, 27

    track(RunService.RenderStepped:Connect(function()
        if not isOpen then return end
        local t = os.clock()
        body.Position = UDim2.new(0, 0, 0, math.sin(t * 2) * 2)

        local selected = Flags["Aimbot/Body Part"] or "Head"
        local skelOn = Flags["Visuals/Skeleton"]
        local chamsOn = Flags["Chams/Enabled"]
        local skin = SKINS[Flags["Skins/Skin"] or ""]
        local baseCol = skin and skin[1] or BODY_GRAY

        for name, f in pairs(bodyParts) do
            local col = baseCol
            local trans = 0

            if chamsOn then
                col = PALETTE[Flags["Chams/Color"] or "Red"] or Color3.fromRGB(255,60,60)
                trans = 1 - (Flags["Chams/Fill"] or 60) / 100
            end

            if skelOn and not chamsOn then
                trans = 0.82
            end

            if name == selected and not chamsOn then
                col = ACC()
                trans = math.max(0, trans - 0.25)
            end

            if hovered[name] and not chamsOn then
                col = Color3.fromRGB(210, 210, 230)
                trans = 0
            end

            if flash[name] and os.clock() - flash[name] < 0.18 then
                col = Color3.fromRGB(255, 255, 255)
                trans = 0
            end

            f.BackgroundColor3 = col
            f.BackgroundTransparency = trans
        end

        skel.Visible = skelOn
        if skelOn then
            local scol = getColor(Flags["Visuals/Skeleton Color"], t, 0)
            for _, s in ipairs(skelParts) do s.BackgroundColor3 = scol end
        end

        if Flags["ESP/Enabled"] then
            local box = panel:FindFirstChild("espBox")
            if not box then
                box = Instance.new("Frame")
                box.Name = "espBox"
                box.BackgroundTransparency = 1
                box.Position = UDim2.new(0.5, -40, 0, 78)
                box.Size = UDim2.new(0, 80, 0, 190)
                box.ZIndex = 15; box.Parent = panel
                stroke(box, Color3.fromRGB(255, 60, 60), 1.5, 0)
            end
            box.Visible = Flags["ESP/2D Box"]
        else
            local box = panel:FindFirstChild("espBox")
            if box then box.Visible = false end
        end

        local hatOn = Flags["Visuals/Hat"]
        local hcol = Flags["Visuals/Hat Color"]
        for i, s in ipairs(hatS) do
            s.Visible = hatOn
            if hatOn then s.BackgroundColor3 = getColor(hcol, t, i * 0.05) end
        end
        brim.Visible = hatOn
        if hatOn then brim.BackgroundColor3 = getColor(hcol, t, 0.1) end

        local wingsOn = Flags["Visuals/Wings"]
        local wcol = Flags["Visuals/Wing Color"]
        local flap = math.sin(t * (Flags["Visuals/Wing Speed"] or 3)) * 0.2
        for _, w in ipairs(wingF) do
            w.f.Visible = wingsOn
            if wingsOn then
                local a = math.rad(12 + w.i * 13) + flap * (0.5 + w.i * 0.15)
                local dx, dy = w.side * math.cos(a), -math.sin(a)
                local sx = (w.side == -1) and 26 or 64
                w.f.Position = UDim2.new(0, sx + dx * w.len / 2, 0, 52 + dy * w.len / 2)
                w.f.Rotation = math.deg(math.atan2(dy, dx))
                w.f.BackgroundColor3 = getColor(wcol, t, w.i * 0.05)
                w.f.BackgroundTransparency = 0.08
            end
        end

        local trailOn = Flags["Visuals/Trail"]
        local tcol = Flags["Visuals/Trail Color"]
        local tlen = math.clamp(Flags["Visuals/Trail Length"] or 10, 1, 30)
        local count = math.clamp(math.floor(tlen / 30 * 12) + 2, 3, 12)
        local twidth = Flags["Visuals/Trail Width"] or 4
        for k, f in ipairs(trailF) do
            local show = trailOn and k <= count
            f.Visible = show
            if show then
                local fall = k / count
                f.Position = UDim2.new(0, 22 - k * 8, 0, 108 + math.sin(t * 4 + k * 0.6) * 4 * fall)
                f.Size = UDim2.new(0, 12, 0, math.max(2, twidth * 2.2 * (1 - fall * 0.8)))
                f.BackgroundTransparency = 0.1 + fall * 0.85
                f.BackgroundColor3 = getColor(tcol, t, -k * 0.04)
            end
        end

        -- AIM DOT: always visible, flies to selected part
        local goal = AIM_POINT[selected] or AIM_POINT.Head
        currentX = currentX + (goal[1] - currentX) * 0.25
        currentY = currentY + (goal[2] - currentY) * 0.25

        local aimOn = Flags["Aimbot/Enabled"]
        local pulse = 1 + math.sin(t * 6) * (aimOn and 0.15 or 0.05)
        aimGlow.Position = UDim2.new(0, currentX, 0, currentY)
        aimGlow.Size = UDim2.new(0, (aimOn and 26 or 18) * pulse, 0, (aimOn and 26 or 18) * pulse)
        aimGlow.BackgroundTransparency = aimOn and (0.72 + math.sin(t * 6) * 0.06) or 0.85
        aimDot.Position = UDim2.new(0, currentX, 0, currentY)
        aimDot.BackgroundTransparency = aimOn and 0 or 0.35
    end))
end

buildPreview(previewPanel)

selectTab(mainTab)
ensureESP()
buildKeyScreen()

task.spawn(function()
    while not UNLOCKED do task.wait(0.3) end
    icon.Visible = true
    if hasFS then
        pcall(function()
            local p = FOLDER .. "/autoload.txt"
            if isfile(p) then
                local slot = readfile(p)
                if slot ~= "" and table.find(SLOTS, slot) then
                    Setters["Settings/Config Slot"](slot)
                    loadConfig(slot, true)
                    Setters["Settings/Autoload"](true)
                end
            end
        end)
    end
    notify("loaded • " .. (Flags["Settings/Menu Key"] or "RightShift") .. " to open")
end)
