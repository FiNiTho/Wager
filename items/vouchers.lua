SMODS.Atlas {
    key = "vouchers",
    path = "vouchers.png",
    px = 72,
    py = 95,
}

-- bet voucher
SMODS.Voucher {
    key = 'bet',
    loc_txt = {
        name = 'Bet',
        text = {
            "{C:gamble}Gamble{} cards can be",
            "bought from the store"
        }
    },
    cost = 10,
    unlocked = true,
    available = true,
    -- requires = 'v_wager_gamble'

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

-- All-in voucher
SMODS.Voucher {
    key = 'allIn',
    loc_txt = {
        name = 'All-in',
        text = {
            "Doubles all {C:attention}listed{}",
            "{C:green,E:1}probabilities{}",
            "{inactive}(ex:{} {C:green}1 in 3{} {C:inactive}->{} {C:green}2 in 3{}{C:inactive}){}"
        }
    },
    cost = 10,
    unlocked = true,
    available = true,
    requires = {'v_wager_gamble'},

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

-- -- debt voucher
-- if (SMODS.Mods["Cryptid"] or {}).can_load then
--     SMODS.Voucher {
--     key = 'debt',
--     loc_txt = {
--         name = 'Debt',
--         text = {
--             "Nothing yet again >:)",
--             "aww man :("
--         }
--     },
--     cost = 10,
--     unlocked = true,
--     available = true,
--     requires = {'v_wager_gamble', 'v_wager_gamble2'},

--     atlas = 'vouchers', 
--     pos = { x = 2, y = 0 },

--     pools = { },

--     config = {
--         extra = { }
--     },

--     redeem = function(self, card)
--         G.E_MANAGER:add_event(Event({
--             func = function()
--                 return true
--             end
--         }))
--         G.GAME.pool_flags.gamble3_redeemed = true
--     end
--     } 
-- end