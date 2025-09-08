-- version 1.0.3, source: https://github.com/Litttlefish/teardown_slimeutils
-- please do not rename slimegcfunc.lua, thanks.

--{
    -- Ensure a safe global upongc exists to avoid nil-call errors when proxy GC fires
    if type(upongc) ~= "function" then
        -- provide a wrapper that will call module-specific handlers if they exist
        upongc = function(self)
            -- Call IBSIT handler if available
            if type(upongc_ibsit) == "function" then
                pcall(upongc_ibsit)
            end
            -- Call MBCS handler if available
            if type(upongc_mbcs) == "function" then
                pcall(upongc_mbcs)
            end
            -- no-op otherwise
        end
    end

    getmetatable(newproxy(true)).__gc = function(self) upongc(self) return newproxy(self) end
--}

--[[
    proxy is a lua 5.1 built-in zero-size userdata which can call __gc metamethod when being recycled
    newproxy(true) creates a proxy with a blank metatable
    newproxy(false) creates one without metatable
    newproxy(proxy) creates another proxy that shares the metatable with the original one
    so what's happening here is:
        calls upongc() function when being recycled
        then revive the metatable with a new proxy so it can be recycled again
--]]