-- Gamble
SMODS.Atlas {
    key = 'gamble',
    path = 'gamble.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'gamble',
    loc_txt = {
        name = 'Gamble',
        text = {
            "After {C:attention}#1# rounds{} it has a",
            "{C:green}#5#%{} chance to get {C:uncommon}uncommon{}",
            "{C:green}#4#%{} chance to get {C:rare}rare{}",
            "{C:green}#3#%{} chance to get {C:legendary,E:1}legendary{}",
        }
    },
    atlas = 'gamble',
    rarity = 2,
    cost = 6,
    pools = { ["FinnmodAddition"] = true },
    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = { x = 0, y = 0 },
    config = {
        extra = {
            roundCount = 2, 
            odds = 100,
            legendaryOdds = 2,
            rareOdds = 35,
            uncommenOdds = 63
        }
    },

    check_for_unlock = function(self, args)
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.roundCount, 
                card.ability.extra.odds,
                card.ability.extra.legendaryOdds,
                card.ability.extra.rareOdds,
                card.ability.extra.uncommenOdds
            }
        }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            card.ability.extra.roundCount = card.ability.extra.roundCount - 1

            if card.ability.extra.roundCount <= 0 then
                local number = math.random(card.ability.extra.odds)
                if number <= card.ability.extra.legendaryOdds then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        blockable = false,
                        func = function()
                            
                            -- Create and add the Joker card
                            local new_card = create_card("Joker", G.jokers, true, nil, nil, nil)
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        return true
                        end,
                    }))
                elseif number <= card.ability.extra.rareOdds then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        blockable = false,
                        func = function()
                            -- Create and add the Joker card
                            local new_card = create_card("Joker", G.jokers, nil, 1, nil, nil)
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        return true
                        end,
                    }))
                else
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1, 
                        blockable = false,
                        func = function()
                            local new_card = create_card("Joker", G.jokers, nil, 0.8, nil, nil)
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        return true
                        end,
                    }))
                end
                G.E_MANAGER:add_event(Event({
                    ease_dollars(amount)
                }))
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
                return {  }
            end
            if card.ability.extra.roundCount > 0 then
                return { message = card.ability.extra.roundCount .. "/2"}
            else
                return {  }
            end
        end
    end
}

-- GambleMoney
SMODS.Atlas {
    key = 'wager',
    path = 'wager.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'wager',
    loc_txt = {
        name = 'Wager',
        text = {
            "After {C:attention}#1# round{} it has a",
            "{C:green}#8#%{} chance to get {C:money,E:1}$#3#{}",
            "{C:green}#10#%{} chance to get {C:money}$#5#{}",
            "{C:green}#11#%{} chance to get {C:money}$#6#{}",
            "{C:green}#12#%{} chance to get {C:money}$#7#{}",
            "{C:green}#9#%{} chance to get {C:red}$#4#{}",
        }
    },
    atlas = 'wager',
    rarity = 1,
    cost = 5,
    pools = { ["FinnmodAddition"] = true },
    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = { x = 0, y = 0 },
    config = {
        extra = {
            roundCount = 1, 
            odds = 100,
            jackpotMoney = 100, lossMoney = -10, hugeWinMoney = 25, 
            bigWinMoney = 15, smallWinMoney = 8,
            jackpot = 2,
            loss = 10,
            hugeWin = 15, 
            bigWin = 30,
            smallWin = 40,
        }
    },

    check_for_unlock = function(self, args)
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.roundCount, 
                card.ability.extra.odds,
                card.ability.extra.jackpotMoney, card.ability.extra.lossMoney, card.ability.extra.hugeWinMoney, 
                card.ability.extra.bigWinMoney, card.ability.extra.smallWinMoney,
                card.ability.extra.jackpot,
                card.ability.extra.loss,
                card.ability.extra.hugeWin,
                card.ability.extra.bigWin,
                card.ability.extra.smallWin
            }
        }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            card.ability.extra.roundCount = card.ability.extra.roundCount - 1

            if card.ability.extra.roundCount <= 0 then
                local number = math.random(1, card.ability.extra.odds)
                local amount = 0

                if number <= card.ability.extra.jackpot then
                    amount = card.ability.extra.jackpotMoney
                elseif number <= card.ability.extra.loss then
                    amount = card.ability.extra.lossMoney
                elseif number <= card.ability.extra.hugeWin then
                    amount = card.ability.extra.hugeWinMoney
                elseif number <= card.ability.extra.bigWin then
                    amount = card.ability.extra.bigWinMoney
                else
                    amount = card.ability.extra.smallWinMoney
                end
                G.E_MANAGER:add_event(Event({
                    ease_dollars(amount)
                }))
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
                return { message = "$" .. amount }
            end
        end
    end
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

-- Happy Pou joker
-- SMODS.Atlas {
--     key = 'HappyPou',
--     path = 'happyPou.png',
--     px = 71,
--     py = 95,
-- }

-- SMODS.Joker {
--     key = 'HappyPou',
--     loc_txt = {
--         name = 'Happy Pou',
--         text = { 'awww :)',
--                 "{X:mult,C:white}x#2#{} Mult",
--                 "if played hand",
--                 "contains a {C:attention}Flush{}",
--                 'Currently {X:mult,C:white}X#1#{} Mult' }
--     },
--     atlas = 'HappyPou',
--     rarity = 1,
--     cost = 5,
--     pools = {["FinnmodAddition"] = true},

--     unlocked = true,
--     discovered = false,
--     blueprint_compact = true,
--     eternal_compact = false,
--     preishable_compact = false,

--     pos = {x = 0, y = 0},
--     config = { extra = { Xmult = 1, gain = 2 }},

--     loc_vars = function(self, info_queue, center)
--         return {vars = {center.ability.extra.Xmult, center.ability.extra.gain}}
--     end,

--     check_for_unlock = function(self, args)
--         if args.type == 'test' then --not a real type, just a joke
--             unlock_card(self)
--         end
--         unlock_card(self) --unlocks the card if it isnt unlocked
--     end,

--     calculate = function(self, card, context)
--         if context.joker_main then
--             return {
--                 Xmult_mod = card.ability.extra.Xmult,
--                 message = 'X' .. card.ability.extra.Xmult,
--                 colour = G.C.MULT
--             }
--         end

--         if context.before and next(context.poker_hands['Flush']) and not context.blueprint then
--             card.ability.extra.Xmult = card.ability.extra.Xmult * card.ability.extra.gain
--             return {
--                 message = 'Upgraded!',
--                 colour = G.C.MULT,
--                 card = card
--             }
--         end
--     end,
-- }



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