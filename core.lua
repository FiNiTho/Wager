--- STEAMODDED HEADER
--- MOD_NAME: wager
--- MOD_ID: wager
--- MOD_AUTHOR: FiNiTho
--- MOD_DESCRIPTION: Adds some random stuff.
--- PREFIX: wager
----------------------------------------------------------
----------- MOD CODE -------------------------------------

-- shoutout to
-- https://github.com/nh6574/VanillaRemade/
-- https://discord.com/channels/1116389027176787968/1224362333208444989
-- cryptid
-- for helping me understand how to do things with SMODS

if not wager then
	wager = {}
end

local mod_path = "" .. SMODS.current_mod.path
wager.path = mod_path
wager_config = SMODS.current_mod.config


-- COLOURS
G.C.SET.gamble = G.C.SET.gamble or HEX("ca6972")
G.C.SET.gamble2 = G.C.SET.gamble2 or HEX("56a786")


SMODS.current_mod.optional_features = {
    retrigger_joker = true,
	post_trigger = true,
}

-- wager joker pool
SMODS.ObjectType({
	key = "wagerJokers",
	default = "j_wager_dog",
	cards = {},
	inject = function(self)
		SMODS.ObjectType.inject(self)
	end,
})

-- gamble joker pool
SMODS.ObjectType({
	key = "gambleJoker",
	default = "j_wager_gamble",
	cards = {},
	inject = function(self)
		SMODS.ObjectType.inject(self)
	end,
})

--Load item files
local files = NFS.getDirectoryItems(mod_path .. "items")
for _, file in ipairs(files) do
	print("[wager] Loading lua file " .. file)
	local f, err = SMODS.load_file("items/" .. file)
	if err then
    	error("[wager] Error loading " .. file .. ": " .. err)
	end
	f()
end

--Load lib files
local files = NFS.getDirectoryItems(mod_path .. "lib/")
for _, file in ipairs(files) do
	print("[wager] Loading lib file " .. file)
	local f, err = SMODS.load_file("lib/" .. file)
	if err then
		error(err) 
	end
	f()
end

SMODS.Atlas({
	key = "modicon",
	path = "modicon.png",
	px = 34,
	py = 34,
})


----------------------------------------------------------
----------- MOD CODE END ----------------------------------