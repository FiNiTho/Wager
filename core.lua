--- STEAMODDED HEADER
--- MOD_NAME: Finnmod
--- MOD_ID: Finnmod
--- MOD_AUTHOR: FiNiTho
--- MOD_DESCRIPTION: Adds some random stuff.
--- PREFIX: finnmod
----------------------------------------------------------
----------- MOD CODE -------------------------------------

-- shoutouts cryptid & mathisfun --

if not Finnmod then
	Finnmod = {}
end

local mod_path = "" .. SMODS.current_mod.path
Finnmod.path = mod_path
Finnmod_config = SMODS.current_mod.config

SMODS.current_mod.optional_features = {
    retrigger_joker = true,
	post_trigger = true,
}

-- Finnmod joker pool
SMODS.ObjectType({
	key = "FinnmodAddition",
	default = "j_reserved_parking",
	cards = {},
	inject = function(self)
		SMODS.ObjectType.inject(self)
		-- insert base game food jokers
	end,
})

--Load item files
local files = NFS.getDirectoryItems(mod_path .. "items")
for _, file in ipairs(files) do
	print("[FINNMOD] Loading lua file " .. file)
	local f, err = SMODS.load_file("items/" .. file)
	if err then
    	error("[FINNMOD] Error loading " .. file .. ": " .. err)
	end
	f()
end

--Load lib files
local files = NFS.getDirectoryItems(mod_path .. "lib/")
for _, file in ipairs(files) do
	print("[FINNMOD] Loading lib file " .. file)
	local f, err = SMODS.load_file("lib/" .. file)
	if err then
		error(err) 
	end
	f()
end


----------------------------------------------------------
----------- MOD CODE END ----------------------------------