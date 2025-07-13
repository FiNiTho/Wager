SMODS.Atlas {
    key = "vouchers",
    path = "vouchers.png",
    px = 72,
    py = 95,
}

-- first gamble voucher
SMODS.Voucher {
    key = 'gamble',
    loc_txt = {
        name = 'Gamble',
        text = {
            "{C:gamble}Gamble{} cards can be",
            "bought from the store"
        }
    },
    cost = 10,
    unlocked = true,
    available = true,
    -- requires = 'v_finnmod_gamble'

    atlas = 'vouchers', 
    pos = { x = 0, y = 0 },

    pools = { },

    config = {
        extra = { }
    },

    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
			func = function()
				G.GAME.gamble_rate = (G.GAME.gamble_rate or 0) + 3
				return true
			end,
		}))
        G.GAME.pool_flags.gamble_redeemed = true
    end,

}

-- second gamble voucher
SMODS.Voucher {
    key = 'gamble2',
    loc_txt = {
        name = 'Gamble2',
        text = {
            "Doubles all {C:attention}listed{}",
            "{C:green,E:1}probabilities{}",
            "{inactive}(ex:{} {C:green1 in 3{} {C:inactive}->{} {C:green}2 in 3{}{C:inactive}){}"
        }
    },
    cost = 10,
    unlocked = true,
    available = true,
    requires = {'v_finnmod_gamble'},

    atlas = 'vouchers', 
    pos = { x = 1, y = 0 },

    pools = { },

    config = {
        extra = { }
    },

    redeem = function(self, card)
        for k, v in pairs(G.GAME.probabilities) do
            G.GAME.probabilities[k] = v * 2
        end

        G.GAME.pool_flags.gamble2_redeemed = true

        G.E_MANAGER:add_event(Event({
            func = function()
                return true
            end,
        }))
    end
}

-- third gamble voucher
if (SMODS.Mods["Cryptid"] or {}).can_load then
    SMODS.Voucher {
    key = 'gamble3',
    loc_txt = {
        name = 'Gamble3',
        text = {
            "Nothing yet again >:)",
        }
    },
    cost = 10,
    unlocked = true,
    available = true,
    requires = {'v_finnmod_gamble', 'v_finnmod_gamble2'},

    atlas = 'vouchers', 
    pos = { x = 2, y = 0 },

    pools = { },

    config = {
        extra = { }
    },

    redeem = function(self, card)
        G.E_MANAGER:add_event(Event({
            func = function()
                return true
            end
        }))
        G.GAME.pool_flags.gamble3_redeemed = true
    end
    } 
end