-- version 1.0.2, source: https://github.com/Litttlefish/teardown_slimeutils
-- please do not rename slimerand.lua, thanks.
--init {
    math.randomseed(tonumber(tostring(newproxy(false)):sub(19, -2), 16))
    local random = math.random
    local samples, cbrs = {}, {} -- pre-calculated data
	for i = 128, 1, -1 do
		local r = random()
		samples[i], cbrs[i] = (r ^ 0.135 - (1 - r) ^ 0.135) / 0.1975, r ^ (1 / 3) -- fast standard normal distribution
	end
--}

local function fast_std_norm_distr()
    local r = random()
    return (r ^ 0.135 - (1 - r) ^ 0.135) / 0.1975
end

local function fast_raw_vec() return VecNormalize({samples[random(128)], samples[random(128)], samples[random(128)]}) end
local function true_raw_vec() return VecNormalize({fast_std_norm_distr(), fast_std_norm_distr(), fast_std_norm_distr()}) end

Fastrnd = {
    Sphere = {
        UnitVec = fast_raw_vec,
        RangedVec = function(r)
            return VecScale(fast_raw_vec(), r)
        end
    },
    IterateSphere = {
        UnitVec = function(v)
            local a = fast_raw_vec()
            v[1], v[2], v[3] = a[1] + v[1], a[2] + v[2], a[3] + v[3]
            return v
        end,
        RangedVec = function(v, r)
            local a = fast_raw_vec()
            v[1], v[2], v[3] = a[1] * r + v[1], a[2] * r + v[2], a[3] * r + v[3]
            return v
        end
    },
    AddNewSphere = {
        UnitVec = function(v)
            local a = fast_raw_vec()
            return {a[1] + v[1], a[2] + v[2], a[3] + v[3]}
        end,
        RangedVec = function(v, r)
            local a = fast_raw_vec()
            return {a[1] * r + v[1], a[2] * r + v[2], a[3] * r + v[3]}
        end
    },
    Ball = {
        UnitVec = function()
            return VecScale(fast_raw_vec(), cbrs[random(128)])
        end,
        RangedVec = function(r)
            return VecScale(fast_raw_vec(), cbrs[random(128)] * r)
        end
    },
    IterateBall = {
        UnitVec = function(v)
            local a, r = fast_raw_vec(), cbrs[random(128)]
            v[1], v[2], v[3] = a[1] * r + v[1], a[2] * r + v[2], a[3] * r + v[3]
            return v
        end,
        RangedVec = function(v, r)
            local a = fast_raw_vec()
            r = cbrs[random(128)] * r
            v[1], v[2], v[3] = a[1] * r + v[1], a[2] * r + v[2], a[3] * r + v[3]
            return v
        end
    },
    AddNewBall = {
        UnitVec = function(v)
            local a, r = fast_raw_vec(), cbrs[random(128)]
            return {a[1] * r + v[1], a[2] * r + v[2], a[3] * r + v[3]}
        end,
        RangedVec = function(v, r)
            local a = fast_raw_vec()
            r = cbrs[random(128)] * r
            return {a[1] * r + v[1], a[2] * r + v[2], a[3] * r + v[3]}
        end
    },
    ConcBall = {
        UnitVec = function()
            return VecScale(fast_raw_vec(), random())
        end,
        RangedVec = function (r)
            return VecScale(fast_raw_vec(), random() * r)
        end
    },
    Quat={
        Raw = function()
            return Quat(samples[random(128)], samples[random(128)], samples[random(128)], samples[random(128)]) -- the game will normalize it automatically so no worries!
        end,
        AxisAngle = function(d)
            return QuatAxisAngle({samples[random(128)], samples[random(128)], samples[random(128)]}, d)
        end,
        RangedAxisAngle = function(d)
            return QuatAxisAngle({samples[random(128)], samples[random(128)], samples[random(128)]}, random() * d)
        end
    }
}

Truernd={
    Sphere = {
        UnitVec = true_raw_vec,
        RangedVec = function(r)
            return VecScale(true_raw_vec(), r)
        end
    },
    Ball = {
        UnitVec = function()
            return VecScale(true_raw_vec(), random() ^ (1 / 3))
        end,
        RangedVec = function (r)
            return VecScale(true_raw_vec(), random() ^ (1 / 3) * r)
        end
    },
    ConcBall = {
        UnitVec = function()
            return VecScale(true_raw_vec(), random())
        end,
        RangedVec = function (r)
            return VecScale(true_raw_vec(), random() * r)
        end
    },
    Quat={
        Raw = function()
            return Quat(fast_std_norm_distr(), fast_std_norm_distr(), fast_std_norm_distr(), fast_std_norm_distr()) -- the game will normalize it automatically so no worries!
        end,
        AxisAngle = function(d)
            return QuatAxisAngle({fast_std_norm_distr(), fast_std_norm_distr(), fast_std_norm_distr()}, d)
        end,
        RangedAxisAngle = function(d)
            return QuatAxisAngle({fast_std_norm_distr(), fast_std_norm_distr(), fast_std_norm_distr()}, random() * d)
        end
    }
}