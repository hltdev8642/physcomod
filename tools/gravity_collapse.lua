-- tools/gravity_collapse.lua
-- Prototype gravity-collapse module

-- Prototype gravity-collapse module (globals exposed for inclusion)

-- Tunables (registry-backed)
local enabled_key = "savegame.mod.combined.ibsit_gravity_collapse"
local threshold_key = "savegame.mod.combined.ibsit_collapse_threshold"
local sample_count_key = "savegame.mod.combined.gravitycollapse_sample_count"
local check_interval_key = "savegame.mod.combined.gravitycollapse_check_interval"
local min_mass_key = "savegame.mod.combined.gravitycollapse_min_mass"
local debug_key = "savegame.mod.combined.gravitycollapse_debug"

-- Defaults (only applied if keys are missing)
local DEFAULTS = {
    sample_count = 24,
    check_interval = 0.6,
    min_mass = 50,
}

-- Internal state
local lastCheck = 0
local bodyState = {} -- body -> {lastChecked, supportedFrac, unstableSince}
local nextCheck = {} -- body -> next allowed check timestamp
-- Raycast cache to avoid duplicate raycasts in tight clusters
local raycastCache = {} -- key -> {time=ts, hit=bool, hitShape=shape, hitBody=body}

-- Profiling counters
local raycastCount = 0
local raycastCacheHits = 0
local bodiesChecked = 0
local lastProfileReset = 0
local profileInterval = 1.0
local lastProfileSnapshot = {raycasts=0, cacheHits=0, bodies=0}

-- Helpers
-- local helpers
local function getFloatOr(key, fallback)
    if HasKey(key) then return GetFloat(key) end
    return fallback
end

local function getIntOr(key, fallback)
    if HasKey(key) then return GetInt(key) end
    return fallback
end

local function isEnabled()
    return GetBool(enabled_key)
end

local function getBoolOr(key, fallback)
    if HasKey(key) then return GetBool(key) end
    return fallback
end

-- Joint-aware support traversal: BFS through shape joints looking for static or large-mass bodies
local function isSupportedViaJoints(startBody, depthLimit, massThreshold)
    if not IsHandleValid(startBody) then return false end
    local visited = {}
    local queue = {startBody}
    local qi = 1
    local depth = 0
    local maxDepth = depthLimit or 6
    while qi <= #queue and depth <= maxDepth do
        local b = queue[qi]
        qi = qi + 1
        if not visited[b] then
            visited[b] = true
            if IsBodyStatic(b) then return true end
            local mass = GetBodyMass(b) or 0
            if mass >= (massThreshold or 100) then return true end
            local shapes = GetBodyShapes(b)
            for i = 1, #shapes do
                local sh = shapes[i]
                local joints = GetShapeJoints(sh)
                for j = 1, #joints do
                    local joint = joints[j]
                    local other = GetJointOtherShape(joint, sh)
                    if other and other ~= 0 then
                        local otherBody = GetShapeBody(other)
                        if otherBody and not visited[otherBody] then
                            table.insert(queue, otherBody)
                        end
                    end
                end
            end
        end
        depth = depth + 1
    end
    return false
end

-- Evaluate support fraction for a body by underside sampling
-- Utility: returns true if two points are approximately horizontally neighboring (within 'eps' laterally)
local function isHorizNeighbor(a, b, eps)
    local dx = math.abs(a[1] - b[1])
    local dz = math.abs(a[3] - b[3])
    local dy = math.abs(a[2] - b[2])
    return dy < 0.05 and ((dx <= eps and dz < eps*0.5) or (dz <= eps and dx < eps*0.5))
end

-- Utility: 2D grid hash key (x,z) for footprint clustering
local function gridKey2D(x, z, cell)
    return math.floor(x / cell) .. ":" .. math.floor(z / cell)
end

-- Evaluate support using three signals:
-- 1) sampleHitFrac: fraction of underside samples with downward ray hit to other bodies/static
-- 2) comBelowHit: whether a vertical ray from COM hits support close beneath
-- 3) edgeHitFrac: fraction of samples near footprint edge that hit (helps detect only-corner contacts)
local function evaluateSupportFraction(body, samples)
    if not IsHandleValid(body) then return 0 end
    local mi, ma = GetBodyBounds(body)
    local supported = 0
    local edgeSupported = 0
    local totalEdgeSamples = 0
    local baseSamples = samples or getIntOr(sample_count_key, DEFAULTS.sample_count)
    -- adaptive sampling: fewer samples when previously very stable
    local st = bodyState[body]
    local adaptFactor = 1.0
    if st and st.supportedFrac then adaptFactor = 0.5 + (st.supportedFrac * 0.5) end
    local minS = getIntOr("savegame.mod.combined.gravitycollapse_min_samples", 6)
    local maxS = getIntOr("savegame.mod.combined.gravitycollapse_max_samples", 64)
    local s = math.floor(math.max(minS, math.min(maxS, baseSamples * adaptFactor)))
    -- Precompute footprint extents
    local widthX = ma[1] - mi[1]
    local widthZ = ma[3] - mi[3]
    local edgeBand = 0.08 * math.max(0.25, math.min(1.0, math.max(widthX, widthZ)))

    -- Collect sample hits for simple neighbor connectivity hinting
    local footprintCell = getFloatOr("savegame.mod.combined.gravitycollapse_cache_grid", 0.25)
    local hitCells = {}

    for i = 1, s do
        local rx = mi[1] + (math.random() * widthX)
        local rz = mi[3] + (math.random() * widthZ)
        local ry = mi[2] + 0.05
        local origin = Vec(rx, ry + 0.02, rz)
        -- raycast caching: grid key
        local grid = getFloatOr("savegame.mod.combined.gravitycollapse_cache_grid", 0.25)
        local function cacheKey(pt)
            return string.format("%.2f:%.2f:%.2f", math.floor(pt[1]/grid), math.floor(pt[2]/grid), math.floor(pt[3]/grid))
        end
        local key = cacheKey(origin)
        local now = GetTime()
        local ttl = getFloatOr("savegame.mod.combined.gravitycollapse_cache_ttl", 1.0)
        local cached = raycastCache[key]
        local hit, dist, normal, hitShape
        if cached and (now - cached.time) <= ttl then
            hit = cached.hit
            hitShape = cached.hitShape
            raycastCacheHits = raycastCacheHits + 1
        else
            hit, dist, normal, hitShape = QueryRaycast(origin, Vec(0, -1, 0), 0.6)
            raycastCount = raycastCount + 1
            raycastCache[key] = {time = now, hit = hit, hitShape = hitShape}
        end
        if hit and hitShape ~= 0 then
            local hitBody = GetShapeBody(hitShape)
            if hitBody ~= body and IsHandleValid(hitBody) then
                if getBoolOr("savegame.mod.combined.gravitycollapse_joint_credit", true) then
                    local jointDepth = getIntOr("savegame.mod.combined.gravitycollapse_joint_depth", 6)
                    local massThreshold = getIntOr("savegame.mod.combined.gravitycollapse_joint_mass_threshold", 100)
                    if isSupportedViaJoints(hitBody, jointDepth, massThreshold) or isSupportedViaJoints(body, jointDepth, massThreshold) then
                        supported = supported + 1
                    else
                        local mass = GetBodyMass(hitBody)
                        if mass and mass > 1 then supported = supported + 1 end
                    end
                else
                    if IsBodyJointedToStatic(hitBody) or IsBodyJointedToStatic(body) then
                        supported = supported + 1
                    else
                        local mass = GetBodyMass(hitBody)
                        if mass and mass > 1 then supported = supported + 1 end
                    end
                end

                -- Mark footprint cell as supported to hint connectivity
                local hkey = gridKey2D(rx, rz, footprintCell)
                hitCells[hkey] = (hitCells[hkey] or 0) + 1
            end
        else
            -- if no direct hit, optionally credit via joints
            if getBoolOr("savegame.mod.combined.gravitycollapse_joint_credit", true) then
                local jointDepth = getIntOr("savegame.mod.combined.gravitycollapse_joint_depth", 6)
                local massThreshold = getIntOr("savegame.mod.combined.gravitycollapse_joint_mass_threshold", 100)
                if isSupportedViaJoints(body, jointDepth, massThreshold) then supported = supported + 1 end
            end
        end
    end
    bodiesChecked = bodiesChecked + 1

    -- COM vertical projection support
    local com = GetBodyCenterOfMass(body)
    local comHit = false
    if com then
        local hit, dist, nrm, sh = QueryRaycast(VecAdd(com, Vec(0, 0.05, 0)), Vec(0,-1,0), 1.0)
        if hit and sh ~= 0 then
            local hb = GetShapeBody(sh)
            if hb ~= body then comHit = true end
        end
    end

    -- Edge sampling: prioritize detecting only-corner contacts
    local edgeSamples = math.max(4, math.floor(s * 0.25))
    for i = 1, edgeSamples do
        local rx = (math.random() < 0.5) and (mi[1] + math.random() * edgeBand) or (ma[1] - math.random() * edgeBand)
        local rz = (math.random() < 0.5) and (mi[3] + math.random() * edgeBand) or (ma[3] - math.random() * edgeBand)
        local origin = Vec(rx, mi[2] + 0.07, rz)
        local hit, dist, normal, hitShape = QueryRaycast(origin, Vec(0,-1,0), 0.6)
        totalEdgeSamples = totalEdgeSamples + 1
        if hit and hitShape ~= 0 then
            local hb = GetShapeBody(hitShape)
            if hb ~= body then edgeSupported = edgeSupported + 1 end
        end
    end

    local sampleHitFrac = supported / math.max(1, s)
    local edgeHitFrac = edgeSupported / math.max(1, totalEdgeSamples)

    -- Connectivity hint: count distinct neighbor cells hit; if very low but edgeHitFrac high, treat as weak
    local cellCount = 0
    for _ in pairs(hitCells) do cellCount = cellCount + 1 end

    return sampleHitFrac, comHit, edgeHitFrac, cellCount
end

-- Collapse action (safe default: apply impulse and mark tag)
local function triggerCollapse(body, severity)
    if not IsHandleValid(body) then return end
    local mass = GetBodyMass(body) or 1
    local center = GetBodyCenterOfMass(body)
    local forceScale = getFloatOr("savegame.mod.combined.ibsit_gravity_force", 9.81)
    local sev = math.max(0, math.min(1, severity or 1))
    local impulse = VecScale(Vec(0, -1, 0), forceScale * sev * mass * 0.5)
    ApplyBodyImpulse(body, center, impulse)
    SetTag(body, "gravity_collapsed", tostring(GetTime()))
end

-- Main tick for module
function gravity_collapse_tick(dt)
    if not isEnabled() then return end
    local now = GetTime()
    local interval = getFloatOr(check_interval_key, DEFAULTS.check_interval)
    if now - lastCheck < interval then return end
    lastCheck = now
    -- profile snapshot/reset
    profileInterval = getFloatOr("savegame.mod.combined.gravitycollapse_profile_interval", 1.0)
    if now - lastProfileReset >= profileInterval then
        lastProfileSnapshot = {raycasts = raycastCount, cacheHits = raycastCacheHits, bodies = bodiesChecked}
        raycastCount = 0
        raycastCacheHits = 0
        bodiesChecked = 0
        lastProfileReset = now
    end

    -- gather candidate bodies near player
    local cam = GetPlayerTransform()
    local r = 120
    local mi = VecAdd(cam.pos, Vec(-r, -r, -r))
    local ma = VecAdd(cam.pos, Vec(r, r, r))
    QueryRequire("physical dynamic")
    local bodies = QueryAabbBodies(mi, ma)
    local minMass = getIntOr(min_mass_key, DEFAULTS.min_mass)
    local samp = getIntOr(sample_count_key, DEFAULTS.sample_count)
    for i = 1, #bodies do
        local b = bodies[i]
        -- guard conditions: validity, mass, active, scheduling
        if IsHandleValid(b) and GetBodyMass(b) >= minMass and IsBodyActive(b) and (not nextCheck[b] or now >= nextCheck[b]) then
            local state = bodyState[b] or {lastChecked = 0, supportedFrac = 1, unstableSince = nil}
            local frac, comHit, edgeFrac, cellCount = evaluateSupportFraction(b, samp)

            -- optionally clear old cache entries around this body to avoid stale hits
            if getBoolOr("savegame.mod.combined.gravitycollapse_cache_invalidate_on_check", false) then
                local mi2, ma2 = GetBodyBounds(b)
                -- remove cache entries inside bounds expanded slightly
                local pad = getFloatOr("savegame.mod.combined.gravitycollapse_cache_invalidate_pad", 0.05)
                for k, v in pairs(raycastCache) do
                    -- cheap string decode to coords
                    local x,y,z = k:match("([%d%-%.]+):([%d%-%.]+):([%d%-%.]+)")
                    if x and y and z then
                        local gx = tonumber(x) * getFloatOr("savegame.mod.combined.gravitycollapse_cache_grid", 0.25)
                        local gy = tonumber(y) * getFloatOr("savegame.mod.combined.gravitycollapse_cache_grid", 0.25)
                        local gz = tonumber(z) * getFloatOr("savegame.mod.combined.gravitycollapse_cache_grid", 0.25)
                        if gx >= mi2[1]-pad and gx <= ma2[1]+pad and gy >= mi2[2]-pad and gy <= ma2[2]+pad and gz >= mi2[3]-pad and gz <= ma2[3]+pad then
                            raycastCache[k] = nil
                        end
                    end
                end
            end

            state.lastChecked = now
            state.supportedFrac = frac
            state.comSupported = comHit
            state.edgeFrac = edgeFrac
            state.cellCount = cellCount

            local thresh = getFloatOr(threshold_key, 0.5)

            -- Combined heuristic:
            -- - Primary: frac below threshold
            -- - OR COM not supported AND edge-only support (high edgeFrac but low cellCount) -> likely corner contact
            local edgeOnlyWeak = (not comHit) and (edgeFrac >= math.max(0.2, thresh * 0.5)) and (cellCount <= 2)
            if frac < thresh or edgeOnlyWeak then
                if not state.unstableSince then state.unstableSince = now end
                if now - state.unstableSince > (interval * 1.5) then
                    local sevPrimary = (thresh - frac) / math.max(0.0001, thresh)
                    local sevEdge = edgeOnlyWeak and math.min(1.0, edgeFrac + (0.3 - math.min(0.3, frac))) or 0
                    triggerCollapse(b, math.max(sevPrimary, sevEdge))
                    state.unstableSince = nil
                end
            else
                state.unstableSince = nil
            end

            bodyState[b] = state
            -- schedule next check adaptively (so stable bodies are checked less frequently)
            local stability = math.max(0, math.min(1, state.supportedFrac or 0))
            local schedule = interval * (1 + (1 - stability) * 2)
            nextCheck[b] = now + schedule
        end
    end
end

function gravity_collapse_draw()
    local dbg = GetBool(debug_key)
    local showProfiler = getBoolOr("savegame.mod.combined.gravitycollapse_profiler", true)
    if not dbg and not showProfiler then return end
    for body, s in pairs(bodyState) do
        if IsHandleValid(body) then
            local com = GetBodyCenterOfMass(body)
            if com then
                if dbg then
                    DebugText(string.format("S: %.2f COM:%s EDGE:%.2f CELLS:%d",
                        s.supportedFrac or 0,
                        tostring(s.comSupported),
                        s.edgeFrac or 0,
                        s.cellCount or 0), Transform(com, QuatEuler(0,0,0)))
                end
                local mi, ma = GetBodyBounds(body)
                DebugBox({mi, ma}, Vec(1-s.supportedFrac, s.supportedFrac, 0), 0.15)
            end
        end
    end
    -- profiler overlay
    if showProfiler then
        local now = GetTime()
        local r = lastProfileSnapshot.raycasts or 0
        local c = lastProfileSnapshot.cacheHits or 0
        local b = lastProfileSnapshot.bodies or 0
        UiPush()
        UiFont("regular.ttf", 16)
        UiTranslate(20, 60)
        UiColor(1,1,1)
        UiText(string.format("GC Profiler (%.1fs): raycasts=%d cacheHits=%d bodies=%d", profileInterval, r, c, b))
        UiPop()
    end
end

function gravity_collapse_update(dt) end

function gravity_collapse_init() end
