-- Enhanced IBSIT v2.0 - Impact Based Structural Integrity Test
-- Features: Advanced shape manipulation, haptic feedback, enhanced particles, sounds, and performance optimizations

#include "slimerand.lua"
#include "slimegcfunc.lua"

-- Enhanced prelude with new API features
local random, sqrt, log = math.random, math.sqrt, math.log
local co_create, co_resume, co_yield = coroutine.create, coroutine.resume, coroutine.yield
math.randomseed(tonumber(tostring(newproxy(false)):sub(19, -2), 16))
local addrndVec, addrangedVec = Fastrnd.AddNewBall.UnitVec, Fastrnd.IterateBall.RangedVec
local sratio = 3 / 4096

-- Material damage multipliers for new shape manipulation
local materialMultipliers = {
    foliage = 2.0,
    glass = 1.5,
    ice = 1.3,
    wood = 1.0,
    dirt = 0.8,
    masonry = 0.6,
    plaster = 0.7,
    hardmasonry = 0.4,
    plastic = 1.2,
    metal = 0.5,
    hardmetal = 0.3
}

function init()
    -- Enhanced initialization with new registry features
    if not HasKey("savegame.mod.ibsit") then
        -- Core settings
        SetInt("savegame.mod.ibsit.dust_amt", 50)
        SetInt("savegame.mod.ibsit.wood_size", 100)
        SetInt("savegame.mod.ibsit.stone_size", 75)
        SetInt("savegame.mod.ibsit.metal_size", 50)
        SetInt("savegame.mod.ibsit.momentum", 12)

        -- New features
        SetBool("savegame.mod.ibsit.haptic", true)
        SetBool("savegame.mod.ibsit.sounds", true)
        SetBool("savegame.mod.ibsit.particles", true)
        SetBool("savegame.mod.ibsit.vehicle", false)
        SetBool("savegame.mod.ibsit.joint", false)
        SetBool("savegame.mod.ibsit.protection", false)
        SetFloat("savegame.mod.ibsit.volume", 0.7)
        SetInt("savegame.mod.ibsit.particle_quality", 2) -- 0=low, 1=medium, 2=high

        -- New gravity collapse features
        SetBool("savegame.mod.ibsit.gravity_collapse", true)
        SetFloat("savegame.mod.ibsit.collapse_threshold", 0.3) -- 30% structural integrity
        SetFloat("savegame.mod.ibsit.gravity_force", 2.0)

        -- New debris cleanup features
        SetBool("savegame.mod.ibsit.debris_cleanup", true)
        SetFloat("savegame.mod.ibsit.cleanup_delay", 30.0) -- 30 seconds
        SetBool("savegame.mod.ibsit.fps_optimization", true)
        SetInt("savegame.mod.ibsit.target_fps", 30)
        SetFloat("savegame.mod.ibsit.performance_scale", 1.0)
    end

    -- Load enhanced sound effects
    if GetBool("savegame.mod.ibsit.sounds") then
        LoadSound("MOD/sounds/collapse_heavy.ogg")
        LoadSound("MOD/sounds/collapse_light.ogg")
        LoadSound("MOD/sounds/structure_stress.ogg")
    end

    -- Load haptic effects
    if GetBool("savegame.mod.ibsit.haptic") then
        LoadHaptic("MOD/haptic/impact_light.xml")
        LoadHaptic("MOD/haptic/impact_heavy.xml")
    end
end

-- Enhanced options with new UI features
local wb, mb, hb = GetInt("savegame.mod.ibsit.wood_size") / 100, GetInt("savegame.mod.ibsit.stone_size") / 100, GetInt("savegame.mod.ibsit.metal_size") / 100
local threshold = 2 ^ GetInt("savegame.mod.ibsit.momentum")
local rthreshold = 5 / threshold
local dust = 4096 / GetInt("savegame.mod.ibsit.dust_amt")
local fdust = GetInt("savegame.mod.ibsit.dust_amt")
local rdust = 1 / dust
local vehicle = not GetBool("savegame.mod.ibsit.vehicle")
local joint = not GetBool("savegame.mod.ibsit.joint")
local protect = not GetBool("savegame.mod.ibsit.protection")
local haptic = GetBool("savegame.mod.ibsit.haptic")
local sounds = GetBool("savegame.mod.ibsit.sounds")
local particles = GetBool("savegame.mod.ibsit.particles")
local volume = GetFloat("savegame.mod.ibsit.volume")
local particleQuality = GetInt("savegame.mod.ibsit.particle_quality")

-- Enhanced variables with new tracking
local triggered, name = false, "IBSIT v2.0 Enabled"
local vel, pos, time, breaklist, gcl = {}, {}, {}, {}, {}
local ind = nil
local cached_breaksize, cached_breakpoint, last_frame
local performanceStats = {bodies_processed = 0, holes_created = 0, particles_spawned = 0}

-- New gravity collapse variables
local gravityCollapse = GetBool("savegame.mod.ibsit.gravity_collapse")
local collapseThreshold = GetFloat("savegame.mod.ibsit.collapse_threshold")
local gravityForce = GetFloat("savegame.mod.ibsit.gravity_force")
local structuralIntegrity = {} -- Track integrity per body

-- New debris cleanup variables
local debrisCleanup = GetBool("savegame.mod.ibsit.debris_cleanup")
local cleanupDelay = GetFloat("savegame.mod.ibsit.cleanup_delay")
local fpsOptimization = GetBool("savegame.mod.ibsit.fps_optimization")
local targetFPS = GetInt("savegame.mod.ibsit.target_fps")
local performanceScale = GetFloat("savegame.mod.ibsit.performance_scale")
local debrisTimers = {} -- Track cleanup timers
local lastFrameTime = 0
local currentFPS = 60

local function GetBodyVoxelCount(body)
    local count = 0
    body = GetBodyShapes(body)
    for i = #body, 1, -1 do
        count = count + GetShapeVoxelCount(body[i])
    end
    return count
end

local function rndPnt(a, b)
    return {a[1] + (b[1] - a[1]) * random(), a[2] + (b[2] - a[2]) * random(), a[3] + (b[3] - a[3]) * random()}
end

-- Calculate structural integrity percentage
local function calculateStructuralIntegrity(body)
    if not IsHandleValid(body) then return 0 end

    local originalVoxelCount = GetBodyVoxelCount(body)
    local currentVoxelCount = 0

    -- Count remaining voxels in all shapes
    local shapes = GetBodyShapes(body)
    for i = 1, #shapes do
        currentVoxelCount = currentVoxelCount + GetShapeVoxelCount(shapes[i])
    end

    -- Store original count if not already stored
    if not structuralIntegrity[body] then
        structuralIntegrity[body] = {original = originalVoxelCount, current = currentVoxelCount}
    else
        structuralIntegrity[body].current = currentVoxelCount
    end

    local integrity = currentVoxelCount / structuralIntegrity[body].original
    return math.max(0, math.min(1, integrity)) -- Clamp between 0 and 1
end

-- Apply gravity collapse forces
local function applyGravityCollapse(body, integrity)
    if not gravityCollapse or integrity > collapseThreshold then return end

    local collapseSeverity = (collapseThreshold - integrity) / collapseThreshold
    local force = VecScale({0, -1, 0}, gravityForce * collapseSeverity * 1000)

    -- Apply force at multiple points for realistic collapse
    local bounds = GetBodyBounds(body)
    local center = GetBodyCenterOfMass(body)

    -- Apply force at center and corners for structural failure simulation
    ApplyBodyImpulse(body, center, force)

    -- Additional forces at structural weak points
    local corners = {
        {bounds[1], bounds[2], bounds[3]},
        {bounds[4], bounds[2], bounds[3]},
        {bounds[1], bounds[5], bounds[3]},
        {bounds[4], bounds[5], bounds[3]}
    }

    for i = 1, #corners do
        local cornerForce = VecScale(force, 0.3) -- Reduced force at corners
        ApplyBodyImpulse(body, corners[i], cornerForce)
    end

    -- Add cascading damage for severe structural failure
    if integrity < collapseThreshold * 0.5 then
        SetTag(body, "cascade_damage", "true")
    end
end

-- Debris cleanup system
local function cleanupDebris()
    if not debrisCleanup then return end

    local currentTime = GetTime()

    -- Find and tag debris for cleanup
    local debrisBodies = FindBodies(nil, true)
    for i = 1, #debrisBodies do
        local body = debrisBodies[i]
        if IsHandleValid(body) and not IsBodyActive(body) then
            if not debrisTimers[body] then
                debrisTimers[body] = currentTime
            elseif currentTime - debrisTimers[body] > cleanupDelay then
                -- Mark for removal
                SetTag(body, "cleanup", "true")
                debrisTimers[body] = nil
            end
        end
    end

    -- Remove marked debris
    local cleanupBodies = FindBodies("cleanup", true)
    for i = 1, #cleanupBodies do
        if IsHandleValid(cleanupBodies[i]) then
            Delete(cleanupBodies[i])
        end
    end
end

-- FPS-based performance optimization
local function optimizePerformance()
    if not fpsOptimization then return end

    local frameTime = GetTime() - lastFrameTime
    currentFPS = 1 / frameTime
    lastFrameTime = GetTime()

    -- Adjust performance scale based on FPS
    if currentFPS < targetFPS then
        performanceScale = math.max(0.1, performanceScale * 0.95) -- Reduce performance
    elseif currentFPS > targetFPS + 5 then
        performanceScale = math.min(1.0, performanceScale * 1.02) -- Increase performance
    end

    -- Apply performance scaling
    if performanceScale < 0.8 then
        -- Reduce particle effects
        particleQuality = math.max(0, particleQuality - 1)
    elseif performanceScale > 0.9 then
        -- Restore particle effects
        particleQuality = math.min(2, particleQuality + 1)
    end
end

-- Enhanced garbage collection with performance tracking
function upongc()
    local activeCount = 0
    for body = #gcl, 1, -1 do
        body = gcl[body]
        if IsHandleValid(body) then
            if not IsBodyActive(body) then
                SetTag(body, "spd", "gc")
                activeCount = activeCount + 1
            end
        elseif time[-body] then
            vel[body], vel[-body], time[body], time[-body], pos[body], pos[-body] = nil, nil, nil, nil, nil, nil
        end
    end
    performanceStats.bodies_processed = performanceStats.bodies_processed + activeCount
end

-- Enhanced particle system with new API features
local function createEnhancedParticles(material, position, velocity, intensity)
    if not particles then return end

    ParticleReset()

    if material == "metal" or material == "hardmetal" then
        ParticleType("plain")
        ParticleColor(1, 0.4, 0.3)
        ParticleAlpha(1, 0, "easein")
        ParticleRadius(0.03, 0.08, "easeout")
        ParticleEmissive(5, 0, "easeout")
        ParticleGravity(-15)
        ParticleSticky(0.3)
        ParticleStretch(0)
        intensity = intensity * 0.25
    elseif material == "wood" or material == "foliage" then
        ParticleType("smoke")
        ParticleColor(0.4, 0.3, 0.2)
        ParticleAlpha(0.8, 0, "easein")
        ParticleRadius(0.1, 0.3, "easeout")
        ParticleGravity(-0.2)
        ParticleDrag(0, 1, "easeout")
        ParticleStretch(1, 0, "easein")
    else
        ParticleType("smoke")
        ParticleColor(0.6, 0.55, 0.5)
        ParticleAlpha(1, 0, "easein")
        ParticleRadius(0.1, 0.25, "easeout")
        ParticleGravity(-0.1)
        ParticleDrag(0, 1, "easeout")
        ParticleStretch(1, 0, "easein")
    end

    -- Quality-based particle count
    local particleCount = intensity * (particleQuality + 1)
    for i = 1, particleCount do
        SpawnParticle(
            VecAdd(position, addrangedVec(0.5)),
            velocity,
            random() * 2
        )
    end

    performanceStats.particles_spawned = performanceStats.particles_spawned + particleCount
end

-- Enhanced sound system
local function playStructuralSound(intensity, material)
    if not sounds then return end

    local soundType
    if intensity > 1000 then
        soundType = "collapse_heavy"
    elseif intensity > 500 then
        soundType = "structure_stress"
    else
        soundType = "collapse_light"
    end

    PlaySound("MOD/sounds/" .. soundType .. ".ogg", volume)
end

-- Enhanced haptic feedback
local function triggerHapticFeedback(intensity)
    if not haptic then return end

    if intensity > 1000 then
        PlayHaptic("MOD/haptic/impact_heavy.xml", 1.0)
    else
        PlayHaptic("MOD/haptic/impact_light.xml", 0.7)
    end
end

-- Enhanced breaking function with new shape manipulation
local function enhancedBreaks(body, c, s, a)
    local sr, sg, sb, sa, tc, shape
    local totalHoles = 0

    for i = sqrt(a), 0, -5 do
        _, tc = GetBodyClosestPoint(body, tc and addrangedVec(tc, 5.5) or c)

        -- Use new shape material detection
        shape, sr, sg, sb, sa = GetShapeMaterialAtPosition(GetBodyShapes(body)[1], tc)

        -- Enhanced hole creation with material-specific damage
        local materialMult = materialMultipliers[shape] or 1.0
        local holeSize = MakeHole(tc, wb * i * materialMult, mb * i * materialMult, hb * i * materialMult)

        if holeSize > dust then
            local x
            if holeSize < 4096 then
                x = holeSize * rdust
            else
                x = fdust
            end

            -- Enhanced particle effects
            createEnhancedParticles(shape, tc, s, x)

            -- Play appropriate sound
            playStructuralSound(holeSize, shape)

            -- Trigger haptic feedback
            triggerHapticFeedback(holeSize)
        end

        totalHoles = totalHoles + 1
        performanceStats.holes_created = performanceStats.holes_created + 1

        if not IsHandleValid(body) then return end
        if holeSize < 128 and i > 1.5 then return end

        if i > 5 then
            co_yield(true)
            s = GetBodyVelocity(body)
        end
    end
end

function tick()
    if PauseMenuButton(name) then
        triggered = not triggered
        name = triggered and "IBSIT v2.0 Disabled" or "IBSIT v2.0 Enabled"
        SetPaused(false)
    end

    if triggered then return end

    if last_frame then
        cached_breaksize, cached_breakpoint, last_frame = nil, nil, false
    end

    if HasKey("game.explosion") then
        cached_breaksize, cached_breakpoint, last_frame = GetFloat("game.explosion.strength") * 2.2, {GetFloat("game.explosion.x"), GetFloat("game.explosion.y"), GetFloat("game.explosion.z")}, true
    end

    if not HasKey("game.break") then return end

    local breaksize, breakpoint = GetFloat("game.break.size")
    if cached_breaksize then
        if cached_breaksize > breaksize then
            breaksize, breakpoint = cached_breaksize, cached_breakpoint
        else
            breakpoint = {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}
        end
        cached_breaksize = nil
    else
        breakpoint = {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}
    end

    -- Enhanced query system
    if vehicle then
        local vehList = GetPlayerVehicle()
        if vehList ~= 0 then
            vehList = GetVehicleBodies(vehList)
            for i = #vehList, 1, -1 do
                QueryRequire("physical dynamic large")
                vehList[i] = QueryAabbBodies(GetBodyBounds(vehList[i]))
            end
            for i = #vehList, 1, -1 do
                QueryRejectBodies(vehList[i])
            end
        end
        vehList = FindVehicles(nil, true)
        for i = #vehList, 1, -1 do
            QueryRejectVehicle(vehList[i])
        end
    end

    if protect then QueryRejectBodies(FindBodies("leave_me_alone", true)) end

    -- Update object list with enhanced bounds
    QueryRequire("physical dynamic large")
    local bodies = QueryAabbBodies(
        {breakpoint[1] - breaksize, breakpoint[2] - breaksize, breakpoint[3] - breaksize},
        {breakpoint[1] + breaksize, breakpoint[2] + breaksize, breakpoint[3] + breaksize}
    )

    for body = #bodies, 1, -1 do
        body = bodies[body]
        if not time[body] and IsBodyBroken(body) and IsBodyActive(body) then
            local dist = GetBodyVoxelCount(body)
            local tr = GetBodyTransform(body)
            local lp = TransformToLocalPoint(tr, breakpoint)
            dist = VecLength(VecSub(lp, GetBodyCenterOfMass(body))) < dist

            if dist or VecLength(GetBodyVelocity(body)) * GetBodyMass(body) > threshold then
                SetTag(body, "spd")
                pos[body], pos[-body], vel[-body], time[body], time[-body], ind = lp, dist and tr.pos or breakpoint, dist, true, 1, true
            end
        end
    end
end

function update()
    if not ind then return end

    gcl = FindBodies("spd", true)
    if #gcl == 0 then
        vel, pos, time, ind = {}, {}, {}, false
        return
    end

    for i = #gcl, 1, -1 do
        local body = gcl[i]
        if IsHandleValid(body) then
            local val = GetTagValue(body, "spd")
            if val == "uninit" then
                val = vel[-body] and GetBodyTransform(body).pos or TransformToParentPoint(GetBodyTransform(body), pos[body])
                if VecLength(VecSub(val, pos[-body])) > 0.125 then
                    vel[body] = vel[-body] and GetBodyVelocity(body) or GetBodyVelocityAtPos(body, val)
                    SetTag(body, "spd", "calc")
                end
            elseif val == "" then
                SetTag(body, "spd", "uninit")
            elseif val == "gc" then
                vel[body], vel[-body], time[body], time[-body], pos[body], pos[-body], val = RemoveTag(body, "spd"), nil, nil, nil, nil, nil, #gcl
                gcl[i] = gcl[val]
                gcl[val] = nil
            end
        else
            vel[body], vel[-body], time[body], time[-body], pos[body], pos[-body] = nil, nil, nil, nil, nil, nil
        end
    end

    -- Process coroutines
    for co = #breaklist, 1, -1 do
        local _, ret = co_resume(breaklist[co])
        if ret ~= true then
            ret = #breaklist
            breaklist[co] = breaklist[ret]
            breaklist[ret] = nil
        end
    end
end

function postUpdate()
    if not ind then return end

    -- Run performance optimization
    optimizePerformance()

    -- Run debris cleanup
    cleanupDebris()

    for body = #gcl, 1, -1 do
        body = gcl[body]
        if IsHandleValid(body) then
            local val = GetTagValue(body, "spd")
            if val == "calc" then
                local c, s
                if vel[-body] then
                    c, s = GetBodyTransform(body).pos, GetBodyVelocity(body)
                else
                    c = TransformToParentPoint(GetBodyTransform(body), pos[body])
                    s = GetBodyVelocityAtPos(body, c)
                end

                if VecLength(s) < 32 then
                    local a = VecSub(vel[body], s)
                    if VecDot(a, vel[body]) > 0.0678 then
                        local sa = GetBodyMass(body)
                        a, val = VecLength(a) * sa, GetBodyVoxelCount(body)

                        if sa < val * 0.5 or val * 10 < sa then
                            a = a * 0.015625
                        end

                        if pos[-body] then
                            sa = VecLength(VecSub(c, pos[-body]))
                            if sa < 0.5 then
                                a = a * sa * 2
                            else
                                pos[-body] = nil
                            end
                        end

                        if a > threshold then
                            if vel[-body] then
                                c = TransformToParentPoint(GetBodyTransform(body), pos[body])
                            end

                            sa = co_create(enhancedBreaks)
                            _, val = co_resume(sa, body, c, s, a * rthreshold - 4)
                            if val == true then
                                breaklist[#breaklist + 1] = sa
                                val = GetBodyVoxelCount(body)
                                if val > 1024 * time[-body] or VecLength(s) * GetBodyMass(body) > threshold * time[-body] then
                                    sa = VecLerp(c, rndPnt(GetBodyBounds(body)), random())
                                    val = log(val + 1)
                                    c = GetBodyTransform(body)
                                    s = TransformToLocalPoint(c, sa)
                                    val = VecLength(VecSub(s, GetBodyCenterOfMass(body))) < val
                                    pos[body], pos[-body], vel[-body], time[body], time[-body] = s, val and c.pos or sa, val, true, time[-body] + 1
                                    SetTag(body, "spd", "uninit")
                                    sa = nil
                                end
                            end
                            if sa then
                                SetTag(body, "spd", "gc")
                            end
                        else
                            vel[body] = s
                        end
                    else
                        vel[body], time[body] = s, false
                    end
                else
                    SetTag(body, "autobreak")
                    SetTag(body, "spd", "hs")
                    vel[body] = s
                end

                -- Apply gravity collapse effects
                local integrity = calculateStructuralIntegrity(body)
                applyGravityCollapse(body, integrity)

            elseif val == "hs" then
                val = vel[-body] and GetBodyVelocity(body) or GetBodyVelocityAtPos(body, TransformToParentPoint(GetBodyTransform(body), pos[body]))
                if VecLength(val) < 32 then
                    RemoveTag(body, "autobreak")
                    SetTag(body, "spd", "calc"