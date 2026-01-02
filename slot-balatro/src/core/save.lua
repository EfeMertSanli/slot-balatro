------------------------------------------------------------
-- SAVE SYSTEM
-- Handles persistent data storage across sessions
------------------------------------------------------------

local json = nil  -- Will use love.filesystem for serialization

local Save = {}

-- Save file name
local SAVE_FILE = "slot_balatro_save.dat"
local BACKUP_FILE = "slot_balatro_save.bak"

-- References to systems that need persistence
local persistent_systems = {}

------------------------------------------------------------
-- SYSTEM REGISTRATION
------------------------------------------------------------

-- Register a system for persistence
-- System must implement get_save_data() and load_save_data(data)
function Save.register(name, system)
    if system.get_save_data and system.load_save_data then
        persistent_systems[name] = system
    end
end

------------------------------------------------------------
-- SAVE/LOAD
------------------------------------------------------------

-- Collect all data from registered systems
function Save.collect_data()
    local data = {
        version = 1,
        timestamp = os.time(),
        systems = {},
    }

    for name, system in pairs(persistent_systems) do
        local success, result = pcall(system.get_save_data)
        if success then
            data.systems[name] = result
        end
    end

    return data
end

-- Distribute loaded data to registered systems
function Save.distribute_data(data)
    if not data or not data.systems then return false end

    for name, system in pairs(persistent_systems) do
        if data.systems[name] then
            local success = pcall(system.load_save_data, data.systems[name])
            if not success then
                print("Warning: Failed to load data for system: " .. name)
            end
        end
    end

    return true
end

-- Serialize data to string (simple Lua table serialization)
local function serialize(tbl, indent)
    indent = indent or 0
    local result = "{"

    local first = true
    for k, v in pairs(tbl) do
        if not first then
            result = result .. ","
        end
        first = false

        -- Key
        if type(k) == "string" then
            result = result .. "[\"" .. k .. "\"]="
        else
            result = result .. "[" .. tostring(k) .. "]="
        end

        -- Value
        if type(v) == "table" then
            result = result .. serialize(v, indent + 1)
        elseif type(v) == "string" then
            result = result .. "\"" .. v:gsub("\"", "\\\""):gsub("\n", "\\n") .. "\""
        elseif type(v) == "boolean" then
            result = result .. tostring(v)
        elseif type(v) == "number" then
            result = result .. tostring(v)
        else
            result = result .. "nil"
        end
    end

    result = result .. "}"
    return result
end

-- Deserialize string to data (using Lua load)
local function deserialize(str)
    if not str or str == "" then return nil end

    local func, err = load("return " .. str)
    if not func then
        print("Deserialize error: " .. tostring(err))
        return nil
    end

    -- Run in sandbox for safety
    setfenv(func, {})
    local success, result = pcall(func)
    if not success then
        print("Deserialize execution error: " .. tostring(result))
        return nil
    end

    return result
end

-- Save to file
function Save.save()
    local data = Save.collect_data()
    local serialized = serialize(data)

    -- Try to use love.filesystem if available
    if love and love.filesystem then
        -- Backup existing save
        if love.filesystem.getInfo(SAVE_FILE) then
            local existing = love.filesystem.read(SAVE_FILE)
            if existing then
                love.filesystem.write(BACKUP_FILE, existing)
            end
        end

        -- Write new save
        local success, err = love.filesystem.write(SAVE_FILE, serialized)
        if not success then
            print("Save error: " .. tostring(err))
            return false
        end
        return true
    end

    return false
end

-- Load from file
function Save.load()
    if love and love.filesystem then
        -- Try main save file
        local content = love.filesystem.read(SAVE_FILE)
        if content then
            local data = deserialize(content)
            if data then
                return Save.distribute_data(data)
            end
        end

        -- Try backup
        content = love.filesystem.read(BACKUP_FILE)
        if content then
            local data = deserialize(content)
            if data then
                print("Loaded from backup save")
                return Save.distribute_data(data)
            end
        end
    end

    return false
end

-- Check if save exists
function Save.exists()
    if love and love.filesystem then
        return love.filesystem.getInfo(SAVE_FILE) ~= nil
    end
    return false
end

-- Delete save (for testing/reset)
function Save.delete()
    if love and love.filesystem then
        love.filesystem.remove(SAVE_FILE)
        love.filesystem.remove(BACKUP_FILE)
        return true
    end
    return false
end

-- Get save info
function Save.get_info()
    if love and love.filesystem then
        local info = love.filesystem.getInfo(SAVE_FILE)
        if info then
            return {
                exists = true,
                size = info.size,
                modtime = info.modtime,
            }
        end
    end
    return {exists = false}
end

------------------------------------------------------------
-- AUTO-SAVE
------------------------------------------------------------

local auto_save_timer = 0
local AUTO_SAVE_INTERVAL = 60  -- Save every 60 seconds

function Save.update(dt)
    auto_save_timer = auto_save_timer + dt
    if auto_save_timer >= AUTO_SAVE_INTERVAL then
        auto_save_timer = 0
        Save.save()
    end
end

-- Force immediate save (call on important events)
function Save.save_now()
    auto_save_timer = 0
    return Save.save()
end

return Save
