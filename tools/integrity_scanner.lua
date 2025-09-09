-- tools/integrity_scanner.lua
--
-- Implements the Structural Integrity Scanner tool.

-- Tool state
local toolActive = false
local scannerEnabled = false
local showScanner = false

-- Visualization settings
local STRESS_COLOR_LOW = {r=0, g=1, b=0, a=0.5}
local STRESS_COLOR_MEDIUM = {r=1, g=1, b=0, a=0.5}
local STRESS_COLOR_HIGH = {r=1, g=0, b=0, a=0.5}

-- Structure data
local structuralGraph = {}
local bodyStress = {}

-- working buffers
local bodyCenter = {}
local bodyMass = {}
local bodyLoad = {}
local bodyLastBreakTime = {}

-- Tunable scanner parameters (can be exposed to options.lua)
local SCANNER_PAD = 0.02
local SCANNER_CELL = 1.0 -- spatial hash cell size (meters)
local SCANNER_ITER = 6
local STRESS_FACTOR = 5.0
local DESTRUCTION_THRESHOLD = 0.9
local BREAK_COOLDOWN = 8.0 -- seconds between automated breaks per body

function integrity_scanner_init()
    -- Register the tool
    RegisterTool("integrity_scanner", "Structural Integrity Scanner", "")
    -- Also mark the tool as enabled in the global game.tool registry so it shows up in the tool menu
    SetBool("game.tool.integrity_scanner.enabled", true)
    DebugPrint("integrity_scanner: registered and enabled in game.tool registry")
    -- If UMF's tool loader is available, register via that as well so it integrates with other UMF tools
    if RegisterToolUMF then
        RegisterToolUMF("integrity_scanner", { printname = "Structural Integrity Scanner", model = "" })
        DebugPrint("integrity_scanner: also registered via RegisterToolUMF")
    end
    -- Respect saved setting for scanner behavior
    scannerEnabled = GetBool("savegame.mod.combined.tool.integrity_scanner.enabled")
end

function integrity_scanner_tick(dt)
    -- read tunables from registry so UI controls affect behavior immediately
    SCANNER_CELL = (GetFloat("savegame.mod.combined.scanner_cell") or SCANNER_CELL)
    SCANNER_ITER = (GetInt("savegame.mod.combined.scanner_iter") or SCANNER_ITER)
    STRESS_FACTOR = (GetFloat("savegame.mod.combined.scanner_factor") or STRESS_FACTOR)
    SCANNER_PAD = (GetFloat("savegame.mod.combined.scanner_pad") or SCANNER_PAD)
    DESTRUCTION_THRESHOLD = (GetFloat("savegame.mod.combined.scanner_threshold") or DESTRUCTION_THRESHOLD)
    BREAK_COOLDOWN = (GetFloat("savegame.mod.combined.scanner_cooldown") or BREAK_COOLDOWN)
    local autoBreak = GetBool("savegame.mod.combined.scanner_autobreak")
    local showLegend = GetBool("savegame.mod.combined.scanner_show_legend")
    local showNumbers = GetBool("savegame.mod.combined.scanner_show_numbers")
    local maxBreaks = GetInt("savegame.mod.combined.scanner_max_breaks_per_tick")

    -- Track whether the scanner is the currently selected tool (detect selection even if scanner disabled)
    local currentTool = GetTool()
    toolActive = (currentTool == "integrity_scanner")

    -- Update scannerEnabled (saved preference) but do NOT early-return if the tool is actively selected.
    scannerEnabled = GetBool("savegame.mod.combined.tool.integrity_scanner.enabled")
    if not scannerEnabled and not toolActive then return end

    -- Only build the graph / compute stress when the tool is active or the overlay is already shown
    if toolActive or showScanner then
        buildStructuralGraph()
        calculateStress(autoBreak, maxBreaks)
    end

    -- Toggle visualization with LMB while the tool is active
    -- Toggle visualization with LMB while the tool is active
    -- Also accept 'g' as a fallback hotkey in case LMB is consumed by UI
    if toolActive and (InputPressed("lmb") or InputPressed("g")) then
        SetBool("savegame.mod.combined.tool.integrity_scanner.enabled", true)
        DebugPrint("Scanner: LMB or G pressed, toggling overlay")
        -- showScanner = not showScanner
        showScanner = GetBool("savegame.mod.combined.tool.integrity_scanner.enabled")
        if showScanner then
            buildStructuralGraph()
            calculateStress(false, maxBreaks)
        end
    end
end

function integrity_scanner_draw()
    if toolActive then
        -- small debug/status overlay for troubleshooting
        UiPush()
        UiFont("regular.ttf", 14)
        UiAlign("left top")
        UiTranslate(10, 10)
        UiColor(1,1,1)
        UiText("Integrity Scanner")
        UiTranslate(0, 18)
        UiText("Enabled: " .. tostring(scannerEnabled))
        UiTranslate(0, 18)
        UiText("Overlay: " .. tostring(showScanner) .. "  (toggle: LMB or 'G')")
        UiPop()
    end

    if toolActive and showScanner then
        drawStressVisuals()
    end
end

function buildStructuralGraph()
    -- Build an adjacency graph by AABB overlap (expanded slightly to catch contacts)
    structuralGraph = {}
    bodyCenter = {}
    bodyMass = {}
    local bodies = FindBodies()
    -- gather bounds/centers/mass
    local boundsCache = {}
    for i, body in ipairs(bodies) do
        local minb, maxb = GetBodyBounds(body)
        boundsCache[body] = {min = minb, max = maxb}
        local tx, rx = GetBodyTransform(body)
        -- GetBodyTransform returns pos, rot; store pos as center fallback
        local center = tx or GetBodyCenterOfMass(body)
        bodyCenter[body] = center
        -- try to read mass, fall back to voxel count or 1
        local m = 1
        local ok, massv = pcall(function() return GetBodyMass(body) end)
        if ok and massv then m = massv else
            local ok2, vox = pcall(function() return GetBodyVoxelCount(body) end)
            if ok2 and vox and vox > 0 then m = vox end
        end
        bodyMass[body] = math.max(0.001, m)
    end

    -- helper to compute AABB overlap volume
    local function aabbOverlapVolume(aMin, aMax, bMin, bMax)
        local dx = math.max(0, math.min(aMax.x, bMax.x) - math.max(aMin.x, bMin.x))
        local dy = math.max(0, math.min(aMax.y, bMax.y) - math.max(aMin.y, bMin.y))
        local dz = math.max(0, math.min(aMax.z, bMax.z) - math.max(aMin.z, bMin.z))
        return dx * dy * dz
    end
    -- build neighbor lists using a simple spatial hash to speed up lookups
    local pad = SCANNER_PAD
    local cellSize = SCANNER_CELL
    local grid = {}
    local function cellKey(x,y,z)
        return tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(z)
    end

    local function insertCell(k, body)
        if not grid[k] then grid[k] = {} end
        table.insert(grid[k], body)
    end

    -- populate grid with bodies
    for _, body in ipairs(bodies) do
        local b = boundsCache[body]
        if b then
            local minc = b.min
            local maxc = b.max
            local xmin = math.floor(minc.x / cellSize)
            local ymin = math.floor(minc.y / cellSize)
            local zmin = math.floor(minc.z / cellSize)
            local xmax = math.floor(maxc.x / cellSize)
            local ymax = math.floor(maxc.y / cellSize)
            local zmax = math.floor(maxc.z / cellSize)
            for xi = xmin, xmax do for yi = ymin, ymax do for zi = zmin, zmax do
                insertCell(cellKey(xi,yi,zi), body)
            end end end
        end
    end

    -- for each body, gather candidate neighbors from surrounding cells
    for _, a in ipairs(bodies) do
        structuralGraph[a] = {neighbors = {}, isStatic = IsBodyStatic(a)}
        local aB = boundsCache[a]
        if aB then
            local aMin = Vec(aB.min.x - pad, aB.min.y - pad, aB.min.z - pad)
            local aMax = Vec(aB.max.x + pad, aB.max.y + pad, aB.max.z + pad)
            local xmin = math.floor(aMin.x / cellSize)
            local ymin = math.floor(aMin.y / cellSize)
            local zmin = math.floor(aMin.z / cellSize)
            local xmax = math.floor(aMax.x / cellSize)
            local ymax = math.floor(aMax.y / cellSize)
            local zmax = math.floor(aMax.z / cellSize)
            local seen = {}
            for xi = xmin, xmax do for yi = ymin, ymax do for zi = zmin, zmax do
                local k = cellKey(xi,yi,zi)
                local list = grid[k]
                if list then
                    for _, b in ipairs(list) do
                        if a ~= b and not seen[b] then
                            seen[b] = true
                            local bB = boundsCache[b]
                            if bB then
                                local vol = aabbOverlapVolume(aMin, aMax, bB.min, bB.max)
                                if vol > 0 then
                                    table.insert(structuralGraph[a].neighbors, {id = b, strength = vol})
                                end
                            end
                        end
                    end
                end
            end end end
        end
    end
end

function calculateStress(autoBreak)
    -- First-pass stress propagation: treat body mass as weight and propagate downward
    bodyStress = {}
    bodyLoad = {}

    -- initialize loads as each body's own weight (mass)
    for body, data in pairs(structuralGraph) do
        local m = bodyMass[body] or 1
        bodyLoad[body] = m
    end

    -- iterative propagation: push load to neighbors below each body
    local iterations = SCANNER_ITER
    for it = 1, iterations do
        local newLoad = {}
        for body, _ in pairs(structuralGraph) do newLoad[body] = 0 end

        for body, data in pairs(structuralGraph) do
            local load = bodyLoad[body] or 0
            -- static bodies absorb (sink) load
            if data.isStatic then
                newLoad[body] = newLoad[body] + load
            else
                -- find neighbors that are below this body (y smaller)
                local below = {}
                local totalStrength = 0
                local bc = bodyCenter[body]
                for _, nb in ipairs(data.neighbors) do
                    local nid = nb.id
                    local nc = bodyCenter[nid]
                    if nc and bc and nc.y < bc.y - 0.05 then
                        table.insert(below, nb)
                        totalStrength = totalStrength + nb.strength
                    end
                end

                if #below == 0 then
                    -- no clear downward neighbor; try any neighbor as fallback
                    for _, nb in ipairs(data.neighbors) do
                        table.insert(below, nb)
                        totalStrength = totalStrength + nb.strength
                    end
                end

                if #below == 0 then
                    -- nowhere to send load; keep it here
                    newLoad[body] = newLoad[body] + load
                else
                    -- distribute most of the load to below neighbors, keep small remainder
                    local retained = load * 0.1
                    local toDistribute = load - retained
                    newLoad[body] = newLoad[body] + retained
                    for _, nb in ipairs(below) do
                        local frac = (nb.strength / (totalStrength + 1e-9))
                        newLoad[nb.id] = newLoad[nb.id] + toDistribute * frac
                    end
                end
            end
        end

        bodyLoad = newLoad
    end

    -- Convert load into a normalized stress value [0..1]
    for body, load in pairs(bodyLoad) do
        local m = bodyMass[body] or 1
        local stress = load / (m * STRESS_FACTOR + 1e-6)
        bodyStress[body] = math.max(0, math.min(1, stress))
    end

    -- Trigger progressive destruction for bodies above threshold if enabled
    if autoBreak == nil then autoBreak = GetBool("savegame.mod.combined.scanner_autobreak") end
    -- allow caller to pass in a cap for max breaks per tick
    local maxPerTick = 3
    if GetInt then maxPerTick = GetInt("savegame.mod.combined.scanner_max_breaks_per_tick") or maxPerTick end
    if autoBreak then
        local now = GetTime()
        local breaksThisTick = 0
        -- iterate bodies in descending stress order so highest stress break first
        local list = {}
        for b,s in pairs(bodyStress) do table.insert(list, {id=b, stress=s}) end
        table.sort(list, function(a,b) return a.stress > b.stress end)
        for _, entry in ipairs(list) do
            if breaksThisTick >= maxPerTick then break end
            local body = entry.id
            local stress = entry.stress
            if stress >= DESTRUCTION_THRESHOLD then
                local last = bodyLastBreakTime[body] or -9999
                if now - last >= BREAK_COOLDOWN then
                    local center = bodyCenter[body]
                    if center then
                        SetTag(body, "scanner_stress", tostring(stress))
                        SetTag(body, "scanner_center", string.format("%f,%f,%f", center.x, center.y, center.z))
                        SetTag(body, "scanner_last", tostring(now))
                        bodyLastBreakTime[body] = now
                        breaksThisTick = breaksThisTick + 1
                    end
                end
            end
        end
    end
end

function drawStressVisuals()
    local showLegend = GetBool("savegame.mod.combined.scanner_show_legend")
    local showNumbers = GetBool("savegame.mod.combined.scanner_show_numbers")
    for body, stress in pairs(bodyStress) do
        local bounds = GetBodyBounds(body)
        local color = STRESS_COLOR_LOW
        if stress > 0.8 then
            color = STRESS_COLOR_HIGH
        elseif stress > 0.5 then
            color = STRESS_COLOR_MEDIUM
        end
        DebugBox(bounds, Vec(color.r, color.g, color.b), color.a)
        if showNumbers then
            local center = GetBodyCenterOfMass(body)
            if center then
                UiPush()
                -- draw small 3D text at center of mass
                DebugText(string.format("%.2f", stress), center)
                UiPop()
            end
        end
    end
    if showLegend then
        -- Draw a simple 2D legend in corner
        UiPush()
        UiFont("regular.ttf", 18)
        UiTranslate(20, 20)
        UiText("Scanner Legend:")
        UiTranslate(0, 22)
        UiColor(STRESS_COLOR_HIGH.r, STRESS_COLOR_HIGH.g, STRESS_COLOR_HIGH.b)
        UiText("High (>0.8)")
        UiTranslate(0, 18)
        UiColor(STRESS_COLOR_MEDIUM.r, STRESS_COLOR_MEDIUM.g, STRESS_COLOR_MEDIUM.b)
        UiText("Medium (>0.5)")
        UiTranslate(0, 18)
        UiColor(STRESS_COLOR_LOW.r, STRESS_COLOR_LOW.g, STRESS_COLOR_LOW.b)
        UiText("Low (<=0.5)")
        UiColor(1,1,1)
        UiPop()
    end
end
