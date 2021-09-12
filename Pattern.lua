-- // Library
require ('lib.moonloader')
local ffi = require ('ffi')

-- // Variables
local PatternMod = {} -- // Return lib functions/variables etc.
local Pattern = {} -- // Pattern's massiv
local hook = {hooks = {}} -- // Hook's Massiv

--// Event
addEventHandler('onScriptTerminate', function(scr) -- // Event
    if scr == script.this then
        for i, hook in ipairs(hook.hooks) do
            if hook.status then
                hook.stop()
            end
        end
    end
end)

-- // Chat Hook
ffi.cdef [[ 
    int VirtualProtect(void* lpAddress, unsigned long dwSize, unsigned long flNewProtect, unsigned long* lpflOldProtect);
]]
lua_thread.create(function()
    wait(1000)
    sampChatHook = hook.new('void(__thiscall *)(void *this, uint32_t type, const char* text, const char* prefix, uint32_t color, uint32_t pcolor)', ChatHook, getModuleHandle('samp.dll') + 0x64010)
end)

function ChatHook(HOOKED_CHAT_THIS, HOOKED_CHAT_TYPE, HOOKED_CHAT_TEXT, HOOKED_CHAT_PREFIX, HOOKED_CHAT_COLOR, HOOKED_CHAT_PCOLOR) 
    local ReplaceText = ffi.string(HOOKED_CHAT_TEXT)
    for k,v in ipairs(Pattern) do
        if ReplaceText:match(v['name']) then
            ReplaceText = ReplaceText:gsub(v['name'],v['text'])
        end
    end
    return sampChatHook(HOOKED_CHAT_THIS, HOOKED_CHAT_TYPE, ReplaceText, HOOKED_CHAT_PREFIX, HOOKED_CHAT_COLOR, HOOKED_CHAT_PCOLOR)
end

function hook.new(cast, callback, hook_addr, size)
    local size = size or 5
    local new_hook = {}
    local detour_addr = tonumber(ffi.cast('intptr_t', ffi.cast('void*', ffi.cast(cast, callback))))
    local void_addr = ffi.cast('void*', hook_addr)
    local old_prot = ffi.new('unsigned long[1]')
    local org_bytes = ffi.new('uint8_t[?]', size)
    ffi.copy(org_bytes, void_addr, size)
    local hook_bytes = ffi.new('uint8_t[?]', size, 0x90)
    hook_bytes[0] = 0xE9
    ffi.cast('uint32_t*', hook_bytes + 1)[0] = detour_addr - hook_addr - 5
    new_hook.call = ffi.cast(cast, hook_addr)
    new_hook.status = false
    local function set_status(bool)
        new_hook.status = bool
        ffi.C.VirtualProtect(void_addr, size, 0x40, old_prot)
        ffi.copy(void_addr, bool and hook_bytes or org_bytes, size)
        ffi.C.VirtualProtect(void_addr, size, old_prot[0], old_prot)
    end
    new_hook.stop = function() set_status(false) end
    new_hook.start = function() set_status(true) end
    new_hook.start()
    table.insert(hook.hooks, new_hook)
    return setmetatable(new_hook, {
        __call = function(self, ...)
            self.stop()
            local res = self.call(...)
            self.start()
            return res
        end
    })
end

-- // Create Directory
if not doesDirectoryExist(getWorkingDirectory()..'\\Pattern') then  createDirectory(getWorkingDirectory()..'\\Pattern') end -- if we have not directory, it will be create

-- // Lib function
function PatternMod.registerPattern(name,text, result) -- // Registr Pattern
    for key, value in ipairs(Pattern) do
        if value['name'] == '%$'..name..'%$' then 
            Pattern[key] = { ['name'] = '%$'..name..'%$', ['text'] = result() }
            return false
        end
    end
    table.insert(Pattern, { ['name'] = '%$'..name..'%$', ['text'] = result() } )
end

function PatternMod.getPatternKey(name) -- // Get Pattern key
    local ReturnText = 'No Text'
    for key, value in ipairs(Pattern) do
        if value['name'] == '%$'..name..'%$' then 
            ReturnText = value['text']
        end
    end
    return ReturnText
end

-- // Local function
function registerPattern(name,text, result) -- // local Registr Pattern
    for key, value in ipairs(Pattern) do
        if value['name'] == '%$'..name..'%$' then 
            Pattern[key] = { ['name'] = '%$'..name..'%$', ['text'] = result() }
            return false
        end
    end
    table.insert(Pattern, { ['name'] = '%$'..name..'%$', ['text'] = result() } )
end

-- // Load Pattern
lua_thread.create(function()
    wait(5000)
	local search, file = findFirstFile("moonloader\\Pattern\\*.lua") 
	while file do
		local Reg = loadfile(getWorkingDirectory()..'\\Pattern\\'..file)
		Reg()
		--
		file = findNextFile(search)
	end
end)
-- // Return module
return PatternMod