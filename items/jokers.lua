-- Sad Pou jocker
SMODS.Atlas {
    key = 'sadPou',
    path = 'sadPou.png',
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = 'sadPou',
    loc_txt = {
        name = 'Sad Pou',
        text = { 'awww :(',
                "{X:mult,C:white}x#2#{} Mult",
                "if played hand",
                "contains a {C:attention}Flush{}",
                'Currently {X:mult,C:white}X#1#{} Mult' }
    },
    atlas = 'sadPou',
    rarity = 1,
    cost = 4,
    pools = {["FinnmodAddition"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = {x = 0, y = 0},
    config = { extra = { Xmult = 1, gain = 2 }},

    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult, center.ability.extra.gain}}
    end,

    check_for_unlock = function(self, args)
        if args.type == 'test' then --not a real type, just a joke
            unlock_card(self)
        end
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult,
                colour = G.C.MULT
            }
        end

        if context.before and next(context.poker_hands['Flush']) and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult * card.ability.extra.gain
            return {
                message = 'Upgraded!',
                colour = G.C.MULT,
                card = card
            }
        end
    end,
}

-- Happy Pou joker
SMODS.Atlas {
    key = 'HappyPou',
    path = 'happyPou.png',
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = 'HappyPou',
    loc_txt = {
        name = 'Happy Pou',
        text = { 'awww :)',
                "{X:mult,C:white}x#2#{} Mult",
                "if played hand",
                "contains a {C:attention}Flush{}",
                'Currently {X:mult,C:white}X#1#{} Mult' }
    },
    atlas = 'HappyPou',
    rarity = 1,
    cost = 5,
    pools = {["FinnmodAddition"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = {x = 0, y = 0},
    config = { extra = { Xmult = 1, gain = 2 }},

    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult, center.ability.extra.gain}}
    end,

    check_for_unlock = function(self, args)
        if args.type == 'test' then --not a real type, just a joke
            unlock_card(self)
        end
        unlock_card(self) --unlocks the card if it isnt unlocked
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult,
                colour = G.C.MULT
            }
        end

        if context.before and next(context.poker_hands['Flush']) and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult * card.ability.extra.gain
            return {
                message = 'Upgraded!',
                colour = G.C.MULT,
                card = card
            }
        end
    end,
}

-- Dog
SMODS.Atlas {
    key = 'dog',
    path = 'dog.png',
    px = 71,
    py = 95,
}

SMODS.Sound({key = "arf", path = "arf.ogg",})
SMODS.Sound({key = "arfBoom", path = "arfBoom.ogg",})


SMODS.Joker {
    key = 'dog',
    loc_txt = {
        name = 'Dog',
        text = {
            "arf!",
            "Played {C:attention}cards{} gain {C:mult}+#1#{} mult",
            "{C:green}#2# in #3#{} chance to explode",
            "at end of the round"
        }
    },
    atlas = 'dog',
    rarity = 2,
    cost = 5,
    pools = {["FinnmodAddition"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = {x = 0, y = 0},
    config = { extra = { mult = 2, odds = 5 } },

    check_for_unlock = function(self, args)
        if args.type == 'test' then
            unlock_card(self)
        end
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult, (G.GAME.probabilities.normal or 1), card.ability.extra.odds } }
	end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.play then
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult or 0
            context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.mult
            return {
                extra = { message = localize('k_upgrade_ex'), colour = G.C.MULT },
                card = card
            }
        end
        -- Checks to see if it's end of round, and if context.game_over is false.
		-- Also, not context.repetition ensures it doesn't get called during repetitions.
		if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
			-- Another pseudorandom thing, randomly generates a decimal between 0 and 1, so effectively a random percentage.
			if pseudorandom('dog') < G.GAME.probabilities.normal / card.ability.extra.odds then
				-- This part plays the animation.
				G.E_MANAGER:add_event(Event({
					func = function()
						play_sound('tarot1')
						card.T.r = -0.2
						card:juice_up(0.3, 0.4)
						card.states.drag.is = true
						card.children.center.pinch.x = true
						-- This part destroys the card.
						G.E_MANAGER:add_event(Event({
							trigger = 'after',
							delay = 0.3,
							blockable = false,
							func = function()
								G.jokers:remove_card(card)
								card:remove()
								card = nil
								return true;
							end
						}))
						return true
					end
				}))
				return {
                    sound = 'finnmod_arfBoom',
					message = 'arf, BOOM!'
				}
			else
				return {
                    sound = 'finnmod_arf',
                    message = 'arf'
				}
			end
		end
	end,
}

-- -- Dog bones
-- SMODS.Atlas {
--     key = 'dogBones',
--     path = 'dogBones.png',
--     px = 71,
--     py = 95,
-- }

-- SMODS.Joker {
--     key = 'dogBones',
--     loc_txt = {
--         name = 'Dog Remains',
--         text = { 'arf',
--                 "{C:mult}+#1# {} extra Mult", }
--     },
--     -- This also searches G.GAME.pool_flags to see if dog went extinct. If so, enables the ability to show up in shop.
-- 	yes_pool_flag = 'dog_extinct',
--     atlas = 'dogBones',
--     rarity = 1,
--     cost = 5,
--     pools = {["FinnmodAddition"] = true},

--     unlocked = true,
--     discovered = false,
--     blueprint_compact = true,
--     eternal_compact = false,
--     preishable_compact = false,

--     pos = {x = 0, y = 0},
--     config = { extra = { odds = 10 } },

--     check_for_unlock = function(self, args)
--         if args.type == 'test' then
--             unlock_card(self)
--         end
--         unlock_card(self)
--     end,

--     loc_vars = function(self, info_queue, card)
-- 		return { vars = { card.ability.extra.odds } }
-- 	end,

--      calculate = function(self, card, context)
--         if context.individual and context.cardarea == G.play then
--             context.other_card.ability.perma_mult = context.other_card.ability.perma_mult or 0
--             context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.odds
--             return {
--                 extra = { message = localize('k_upgrade_ex'), colour = G.C.MULT },
--                 card = card
--             }
--         end
--     end
-- }