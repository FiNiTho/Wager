-- joker atlas
SMODS.Atlas {
    key = 'jokers',
    path = 'jokers.png',
    px = 71,
    py = 95,
}

-- sounds
SMODS.Sound({key = "arf", path = "arf.ogg",})
SMODS.Sound({key = "arfBoom", path = "arfBoom.ogg",})

-- Dog joker
SMODS.Joker {
    key = 'dog',
    loc_txt = {
        name = 'Dog',
        text = {
            "Played {C:attention}cards{} gain {C:mult}+#1#{} mult",
            "{C:green}#2# in #3#{} chance to explode",
            "at end of the round"
        }
    },
    atlas = 'jokers',
    rarity = 2,
    cost = 6,
    pools = {["finnmodJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    pos = {x = 0, y = 0},
    config = { extra = { mult = 2, odds = 5 } },

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
                G.GAME.pool_flags.dog_exploded = true
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

-- tomagachi joker
SMODS.Joker {
    key = 'tomagotchi',
    loc_txt = {
        name = 'Tomagotchi',
        text = {
                "{X:mult,C:white}X#1#{} Mult need to",
                "{C:attention}sell{} stuff to feed it",
                "else it will {C:attention}die{} of hunger",
                "{C:inactive}(Currently {}{C:attention}#2#{}{C:inactive} of #3#){}" }
    },
    atlas = 'jokers',
    rarity = 3,
    cost = 8,
    pools = {["finnmodJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    pos = {x = 1, y = 0},
    pixel_size = { w = 54, h = 64 },
    config = { extra = { Xmult = 3, hunger = 1, maxHunger = 4}},

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.Xmult, card.ability.extra.hunger, card.ability.extra.maxHunger}}
    end,

    calculate = function(self, card, context)
        if context.joker_main then
            return {
                x_mult = card.ability.extra.Xmult
            }
        end
        
        if context.selling_card then
            if card.ability.extra.hunger < card.ability.extra.maxHunger then
                card.ability.extra.hunger = card.ability.extra.hunger + 1
                return {
                    message = card.ability.extra.hunger .. "/" .. card.ability.extra.maxHunger
                }
            end
        end

        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            card.ability.extra.hunger = card.ability.extra.hunger - 1

            if card.ability.extra.hunger == 0 then
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
            end
            return { message = card.ability.extra.hunger .. "/" .. card.ability.extra.maxHunger }
        end
    end,
}

-- jackpot joker
SMODS.Joker {
    key = 'jackpot',
    loc_txt = {
        name = 'Jackpot',
        text = {
                "If {C:attention}first hand{} of round countains",
                "{C:attention}three 7's{} create a {C:gamble}Gamble{} card",
                "{C:inactive}(Must have room){}"}
    },
    atlas = 'jokers',
    rarity = 2,
    cost = 4,
    pools = {["finnmodJokers"] = true, ["gambleJoker"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    pos = {x = 2, y = 0},
    config = { extra = { }},

    loc_vars = function(self, info_queue, card)
        return {vars = { }}
    end,

    calculate = function(self, card, context)
        if context.after then
            local count7 = 0
            for i = 1, #context.full_hand do
                local this_card = context.full_hand[i]
                if this_card:get_id() == 7 then
                    count7 = count7 + 1
                end
            end

            if count7 >= 3 then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    card_eval_status_text(
                        card,
                        "extra",
                        nil,
                        nil,
                        nil,
                        { message = "Jackpot!", colour = G.C.SET.gamble }
                    )

                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.2,
                        func = function()
                            local new_card = create_card("Gamble", G.consumeables, nil, nil, true, true, nil)
                            new_card.ability.extra.created_by_jackpot = true
                            G.consumeables:emplace(new_card)
                            return true
                        end
                    }))
                end
                G.GAME.consumeable_buffer = 0
            end
        end
    end


}

-- gambler joker
SMODS.Joker {
    key = 'gambler',
    loc_txt = {
        name = 'Gambler joker',
        text = {
                "{C:green}#1# in #2#{} chance to create",
                "a {C:gamble}Gamble{} card for each",
                "{C:attention}Rerole{} in the shop",
                "{C:inactive}(Must have room){}",
            }
    },
    atlas = 'jokers',
    rarity = 2,
    cost = 4,
    pools = {["finnmodJokers"] = true, ["gambleJoker"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    pos = {x = 3, y = 0},
    config = { extra = { odds = 3 }},

    loc_vars = function(self, info_queue, card)
        return {vars = { (G.GAME.probabilities.normal or 1), card.ability.extra.odds }}
    end,

    calculate = function(self, card, context)
        if context.reroll_shop then
            if pseudorandom('gambler') < G.GAME.probabilities.normal / card.ability.extra.odds then
                if #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    card_eval_status_text(
                        card,
                        "extra",
                        nil,
                        nil,
                        nil,
                        { message = "Jackpot!", colour = G.C.SET.gamble }
                    )

                    G.E_MANAGER:add_event(Event({
                        trigger = "after",
                        delay = 0.2,
                        func = function()
                            local new_card = create_card("Gamble", G.consumeables, nil, nil, true, true, nil)
                            G.consumeables:emplace(new_card)
                            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer - 1
                            return true
                        end
                    }))
                end
            end
        end
    end
}

-- Gold joker
if (SMODS.Mods["Cryptid"] or {}).can_load then 
else
    SMODS.Joker {
        key = 'goldJoker',
        loc_txt = {
            name = 'Gold Joker',
            text = {
                    "Gives {C:money}+#1#{}",
                    "for each {C:attention}Gold Card{}",
                    "in your {C:attention}full deck{}",
                    "{C:inactive}(Currently{} {C:money}$#2#{}{C:inactive}){}"
                }
        },
        atlas = 'jokers',
        pos = {x = 4, y = 0},
        rarity = 2,
        cost = 6,
        pools = {["finnmodJokers"] = true},

        unlocked = true,
        discovered = false,
        blueprint_compat = false,
        eternal_compat = true,
        preishable_compat = true,

        config = { extra = { money = 1 }},

        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue + 1] = G.P_CENTERS.m_gold

            local gold_tally = 0
            if G.playing_cards then
                for _, playing_card in ipairs(G.playing_cards) do
                    if SMODS.has_enhancement(playing_card, 'm_gold') then gold_tally = gold_tally + 1 end
                end
            end
            return { vars = { card.ability.extra.money, card.ability.extra.money * gold_tally } }
        end,

        calculate = function(self, card, context)
            if context.joker_main then
                local gold_tally = 0
                for _, playing_card in ipairs(G.playing_cards) do
                    if SMODS.has_enhancement(playing_card, 'm_gold') then gold_tally = gold_tally + 1 end
                end
            end
        end,

        calc_dollar_bonus = function(self, card)
            local gold_tally = 0
            for _, playing_card in ipairs(G.playing_cards) do
                if SMODS.has_enhancement(playing_card, 'm_gold') then gold_tally = gold_tally + 1 end
            end
            return gold_tally > 0 and card.ability.extra.money * gold_tally or nil
        end,

        in_pool = function(self, args)
            for _, playing_card in ipairs(G.playing_cards or {}) do
                if SMODS.has_enhancement(playing_card, 'm_gold') then
                    return true
                end
            end
            return false
        end
    }
end

-- The House joker
SMODS.Joker {
    key = 'house',
    loc_txt = {
        name = 'The House',
        text = {
                "This Joker gains {X:mult,C:white}X#2#{} Mult",
                "every time you {C:attention}win{} a",
                "chance in a {C:gamble}Gamble{} card",
                "{C:inactive}(Currently{} {X:mult,C:white}X#1#{} {C:inactive}Mult){}",
            },
        
    },
    atlas = 'jokers',
    pos = {x = 5, y = 1},
    rarity = 3,
    cost = 8,
    pools = {["finnmodJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { x_mult = 1, gain = 0.25 }},

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.x_mult, card.ability.extra.gain }}
    end,

    calculate = function(self, card, context)
        if G.GAME.pool_flags.gambleWin == true then
            card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.gain
            G.GAME.pool_flags.gambleWin = false
        end

        if context.joker_main then
            return {
                x_mult = card.ability.extra.x_mult
            }
        end
    end,
}

-- Sweet Pepper
SMODS.Joker {
    key = 'sweetPepper',
    loc_txt = {
        name = 'Sweet Pepper',
        text = {
                "{C:red}+#1#{} Discards each round",
                "reduces by",
                "{C:red}#2#{} every round",
            }
    },
    atlas = 'jokers',
    pos = {x = 6, y = 0},
    rarity = 2,
    cost = 6,
    pools = {["finnmodJokers"] = true, ["Food"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { d_size = 3, d_loss = 1 }},

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.d_size, card.ability.extra.d_loss } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if card.ability.extra.d_size - card.ability.extra.d_loss <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                card:remove()
                                return true
                            end
                        }))
                        return true
                    end
                }))
                return {
                    message = "Eaten",
                    colour = G.C.RED
                }
            else
                card.ability.extra.d_size = card.ability.extra.d_size - card.ability.extra.d_loss
                G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_loss
                ease_discard(-card.ability.extra.d_size)
                return {
                    message = "-" .. card.ability.extra.d_loss,
                    colour = G.C.RED
                }
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards + card.ability.extra.d_size
        ease_discard(card.ability.extra.d_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_size
        ease_discard(-card.ability.extra.d_size)
    end,
}

-- Blue berry
SMODS.Joker {
    key = 'blueBerry',
    loc_txt = {
        name = 'Blue Berry',
        text = {
                "{C:blue}+#1#{} Hands each round",
                "reduces by",
                "{C:red}#2#{} every round",
            }
    },
    atlas = 'jokers',
    pos = {x = 6, y = 1},
    rarity = 2,
    cost = 6,
    pools = {["finnmodJokers"] = true, ["Food"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { h_size = 3, h_loss = 1 }},

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size, card.ability.extra.h_loss } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if card.ability.extra.h_size - card.ability.extra.h_loss <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                card:remove()
                                return true
                            end
                        }))
                        return true
                    end
                }))
                return {
                    message = "Eaten",
                    colour = G.C.RED
                }
            else
                card.ability.extra.h_size = card.ability.extra.h_size - card.ability.extra.h_loss
                G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.h_loss
                ease_hands_played(-card.ability.extra.h_size)
                return {
                    message = "-" .. card.ability.extra.h_loss,
                    colour = G.C.RED
                }
            end
        end
    end,

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.h_size
        ease_hands_played(card.ability.extra.h_size)
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.h_size
        ease_hands_played(-card.ability.extra.h_size)
    end,
}

-- Golden Apple
SMODS.Joker {
    key = 'goldenApple',
    loc_txt = {
        name = 'Golden Apple',
        text = {
                "Earn {C:money}$#1#{}",
                "at end of round",
                "{C:money}-$#2#{} per {C:attention}hand played{}",
            }
    },
    atlas = 'jokers',
    pos = {x = 5, y = 0},
    rarity = 2,
    cost = 6,
    pools = {["finnmodJokers"] = true, ["Food"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { money = 10, moneyLoss = 1 }},

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.money, card.ability.extra.moneyLoss }}
    end,

    calculate = function(self, card, context)
        if context.end_of_round and context.game_over == false and context.main_eval and not context.blueprint then
            if card.ability.extra.money - card.ability.extra.moneyLoss <= 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.3,
                            blockable = false,
                            func = function()
                                card:remove()
                                return true
                            end
                        }))
                        return true
                    end
                }))
                return {
                    message = "Eaten",
                    colour = G.C.RED
                }
            end
        end
        if context.before and context.main_eval and not context.blueprint then
            card.ability.extra.money = card.ability.extra.money - card.ability.extra.moneyLoss
            return {
                message = "-$" .. card.ability.extra.moneyLoss,
                colour = G.C.MONEY
            }
        end
    end,

    calc_dollar_bonus = function(self, card)
        return card.ability.extra.money
    end,
}

-- Till/Till Eulenspiegel
SMODS.Joker {
    key = 'till',
    loc_txt = {
        name = 'Till',
        text = {
                "This joker gains {C:attention}+#2#{} {C:green,E:1}Probabilities{}",
                "When any {C:attention}Booster Pack{} is skipped",
                "{C:inactive}(Currently{} {C:attention}+#1#{} {C:inactive}Probabilities){}"
            },
        unlock = {
            "{E:1,s:1.3}?????",
        },
    },
    atlas = 'jokers',
    pos = {x = 3, y = 1},
    soul_pos = { x = 4, y = 1 },
    rarity = 4,
    cost = 20,
    pools = {["finnmodJokers"] = true},

    unlocked = false,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { currentProb = 0, addedProbs = 1 }},

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.currentProb, card.ability.extra.addedProbs }}
    end,

    calculate = function(self, card, context)
        if context.skipping_booster and not context.blueprint then
            card.ability.extra.currentProb = card.ability.extra.currentProb + card.ability.extra.addedProbs
            for k, v in pairs(G.GAME.probabilities) do
                G.GAME.probabilities[k] = v + card.ability.extra.addedProbs
            end
            return {
                message = "+" .. card.ability.extra.addedProbs,
                colour = G.C.GREEN,
            }
        end
    end,

    remove_from_deck = function(self, card, from_debuff)
        for k, v in pairs(G.GAME.probabilities) do
            G.GAME.probabilities[k] = v - card.ability.extra.currentProb
        end
    end,
}