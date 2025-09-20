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
    pools = {["wagerJokers"] = true},

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
                    sound = 'wager_arfBoom',
					message = 'arf, BOOM!'
				}
			else
				return {
                    sound = 'wager_arf',
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
                "{X:mult,C:white}X#1#{} Mult {C:attention}sell{} cards",
                "to up hunger, if hunger",
                "is 0 {C:red,E:1}self distruct{}",
                "{C:inactive}(Currently {}{C:attention}#2#{}{C:inactive}/#3#){}" }
    },
    atlas = 'jokers',
    rarity = 3,
    cost = 8,
    pools = {["wagerJokers"] = true},

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
        
        if context.selling_card and not context.blueprint then
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
                "If {C:attention}played hand{} contains",
                "{C:attention}three 7's{} create a {C:gamble}Gamble{} card",
                "{C:inactive}(Must have room){}"}
    },
    atlas = 'jokers',
    rarity = 1,
    cost = 4,
    pools = {["wagerJokers"] = true, ["gambleJoker"] = true},

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
                            SMODS.add_card({ set = 'Gamble' })
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
                "{C:attention}Reroll{} in the shop",
                "{C:inactive}(Must have room){}",
            }
    },
    atlas = 'jokers',
    rarity = 2,
    cost = 4,
    pools = {["wagerJokers"] = true, ["gambleJoker"] = true},

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
                            SMODS.add_card({ set = 'Gamble' })
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
        pools = {["wagerJokers"] = true},

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
    rarity = 2,
    cost = 6,
    pools = {["wagerJokers"] = true},

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
                "reduces by {C:red}#2#{} every {C:attention}#4#{} {C:inactive}[#3#]{}",
                "cards scored",
            }
    },
    atlas = 'jokers',
    pos = {x = 6, y = 0},
    rarity = 2,
    cost = 6,
    pools = {["wagerJokers"] = true, ["Food"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { d_size = 3, d_loss = 1, cards_remaining = 10, cards = 10  }},

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.d_size, card.ability.extra.d_loss, card.ability.extra.cards_remaining, card.ability.extra.cards } }
    end,

    calculate = function(self, card, context)
        -- Prevent multiple triggers
        if card.marked_for_removal then return end

        if card.ability.extra.d_size <= 0 then
            card.marked_for_removal = true  -- Mark for removal

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

            elseif context.individual then
                if card.ability.extra.cards_remaining <= 1 then
                    card.ability.extra.cards_remaining = card.ability.extra.cards
                    card.ability.extra.d_size = card.ability.extra.d_size - card.ability.extra.d_loss
                    G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.d_loss
                    if card.ability.extra.d_size <= 0 then
                    else
                        return {
                            message = "-" .. card.ability.extra.d_loss,
                            colour = G.C.RED
                        }
                    end
                else
                    card.ability.extra.cards_remaining = card.ability.extra.cards_remaining - 1
                    return nil, true -- This is for Joker retrigger purposes
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
                "reduces by {C:red}#2#{} every {C:attention}#4#{} {C:inactive}[#3#]{}",
                "cards discarded",
            }
    },
    atlas = 'jokers',
    pos = {x = 6, y = 1},
    rarity = 2,
    cost = 6,
    pools = {["wagerJokers"] = true, ["Food"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { h_size = 3, h_loss = 1, discards_remaining = 15, discards = 15 }},

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.h_size, card.ability.extra.h_loss, card.ability.extra.discards_remaining, card.ability.extra.discards } }
    end,

    calculate = function(self, card, context)
        -- Prevent multiple triggers
        if card.marked_for_removal then return end

        if card.ability.extra.h_size <= 0 then
            card.marked_for_removal = true  -- Mark for removal

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

            elseif context.discard and not context.blueprint then
                if card.ability.extra.discards_remaining <= 1 then
                    card.ability.extra.discards_remaining = card.ability.extra.discards
                    card.ability.extra.h_size = card.ability.extra.h_size - card.ability.extra.h_loss
                    G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.h_loss
                    if card.ability.extra.h_size <= 0 then
                    else
                        return {
                            message = "-" .. card.ability.extra.h_loss,
                            colour = G.C.BLUE
                        }
                    end
                else
                    card.ability.extra.discards_remaining = card.ability.extra.discards_remaining - 1
                    return nil, true -- This is for Joker retrigger purposes
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

-- @Joker
SMODS.Joker {
    key = '@Joker',
    loc_txt = {
        name = '@Joker',
        text = {
                "If {C:attention}first hand{} of round",
                "contains {C:attention}#1#{} of {V:1}#2#{}",
                "create a {C:attention}tag{}",
                "{s:0.8}Card changes every round{}"
            }
    },
    atlas = 'jokers',
    pos = {x = 7, y = 0},
    rarity = 2,
    cost = 6,
    pools = {["wagerJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { } },

    loc_vars = function(self, info_queue, card)
        local atJoker_card = G.GAME.current_round.vremade_atJoker_card or { rank = 'Ace', suit = 'Spades' }
        return { vars = { localize(atJoker_card.rank, 'ranks'), localize(atJoker_card.suit, 'suits_plural'), colours = { G.C.SUITS[atJoker_card.suit] } } }
    end,

    calculate = function(self, card, context)
        if G.GAME.current_round.hands_played == 0 then
            if context.individual and context.cardarea == G.play and
                context.other_card:get_id() == G.GAME.current_round.vremade_atJoker_card.id and
                context.other_card:is_suit(G.GAME.current_round.vremade_atJoker_card.suit) then
                local tag_pool = get_current_pool('Tag')
                local selected_tag = pseudorandom_element(tag_pool, pseudoseed('ortalab_hoarder'))
                local it = 1
                while selected_tag == 'UNAVAILABLE' do
                    it = it + 1
                    selected_tag = pseudorandom_element(tag_pool, pseudoseed('ortalab_hoarder_resample'..it))
                end
                add_tag(Tag(selected_tag, false, 'Small'))
                return {
                    message = "tag!",
                }
            end
        end
    end,
}

--- This changes vremade_atJoker_card every round so every instance of The atJoker shares the same card.
--- You could replace this with a context.end_of_round reset instead if you want the variables to be local.
--- See SMODS.current_mod.reset_game_globals at the bottom of this file for when this function is called.
local function reset_vremade_atJoker_card()
    G.GAME.current_round.vremade_atJoker_card = { rank = 'Ace', suit = 'Spades' }
    local valid_atJoker_cards = {}
    for _, playing_card in ipairs(G.playing_cards) do
        if not SMODS.has_no_suit(playing_card) and not SMODS.has_no_rank(playing_card) then
            valid_atJoker_cards[#valid_atJoker_cards + 1] = playing_card
        end
    end
    local atJoker_card = pseudorandom_element(valid_atJoker_cards, 'vremade_atJoker' .. G.GAME.round_resets.ante)
    if atJoker_card then
        G.GAME.current_round.vremade_atJoker_card.rank = atJoker_card.base.value
        G.GAME.current_round.vremade_atJoker_card.suit = atJoker_card.base.suit
        G.GAME.current_round.vremade_atJoker_card.id = atJoker_card.base.id
    end
end

-- prism joker
SMODS.Joker {
    key = 'prism',
    loc_txt = {
        name = 'Prism',
        text = {
                "If played hand is a {C:attention}Flush{}",
                "{C:attention}Change{} all scored cards to {V:1}#1#{}",
                "{s:0.8}Suit changes every round{}",
            }
    },
    atlas = 'jokers',
    pos = {x = 7, y = 1},
    rarity = 1,
    cost = 6,
    pools = {["wagerJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    config = {  },

    loc_vars = function(self, info_queue, card)
        local suit = (G.GAME.current_round.vremade_prism_card or {}).suit or 'Spades'
        return { vars = { localize(suit, 'suits_singular'), colours = { G.C.SUITS[suit] } } }
    end,

    calculate = function(self, card, context)
        if context.before and context.main_eval and not context.blueprint and next(context.poker_hands['Flush']) then
            for i, _card in ipairs(G.play.cards) do
                local percent = 1.15 - (i - 0.999) / (#G.play.cards - 0.998) * 0.3

                -- first flip each card
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.15,
                    func = function()
                        G.play.cards[i]:flip()
                        play_sound("card1", percent)
                        G.play.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end,
                }))
            end
            delay(0.2)

            for i, _card in ipairs(G.play.cards) do
                -- change the suit while it's "face-down"
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.1,
                    func = function()
                        SMODS.change_base(G.play.cards[i], G.GAME.current_round.vremade_prism_card.suit)
                        return true
                    end,
                }))
            end

            for i, _card in ipairs(G.play.cards) do
                local percent = 0.85 + (i - 0.999) / (#G.play.cards - 0.998) * 0.3

                -- Flip back to show the new ability
                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.15,
                    func = function()
                        G.play.cards[i]:flip()
                        play_sound('tarot2', percent, 0.6)
                        G.play.cards[i]:juice_up(0.3, 0.3)
                        return true
                    end,
                }))
            end
        end
    end,
}

--- This changes vremade_prism_card every round so every instance of prism Joker shares the same card.
--- You could replace this with a context.end_of_round reset instead if you want the variables to be local.
--- See SMODS.current_mod.reset_game_globals at the bottom of this file for when this function is called.
local function reset_vremade_prism_card()
    G.GAME.current_round.vremade_prism_card = G.GAME.current_round.vremade_prism_card or { suit = 'Spades' }
    local prism_suits = {}
    for k, v in ipairs({ 'Spades', 'Hearts', 'Clubs', 'Diamonds' }) do
        if v ~= G.GAME.current_round.vremade_prism_card.suit then prism_suits[#prism_suits + 1] = v end
    end
    local prism_card = pseudorandom_element(prism_suits, 'vremade_prism' .. G.GAME.round_resets.ante)
    G.GAME.current_round.vremade_prism_card.suit = prism_card
end

-- Stanley
SMODS.Joker {
    key = 'stanley',
    loc_txt = {
        name = 'Stanley',
        text = {
                "Copies the ability of",
                "the {C:attention}joker{} to the {C:attention}#2#{}",
                "{s:0.8}Side changes every round{}",
            }
    },
    atlas = 'jokers',
    pos = {x = 0, y = 1},
    rarity = 3,
    cost = 10,
    pools = {["wagerJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { copiesNumber = 1, copies = 'Right' } },

    loc_vars = function(self, info_queue, card)
        if card.area and card.area == G.jokers then
            local other_joker
            if card.ability.extra.copiesNumber == 1 then
                card.ability.extra.copies = 'Right'
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
                end
            else
                card.ability.extra.copies = 'Left'
                for i = 1, #G.jokers.cards do
                    if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i - 1] end
                end
            end
            local compatible = other_joker and other_joker ~= card and other_joker.config.center.blueprint_compat
            main_end = {
                {
                    n = G.UIT.C,
                    config = { align = "bm", minh = 0.4 },
                    nodes = {
                        {
                            n = G.UIT.C,
                            config = { ref_table = card, align = "m", colour = compatible and mix_colours(G.C.GREEN, G.C.JOKER_GREY, 0.8) or mix_colours(G.C.RED, G.C.JOKER_GREY, 0.8), r = 0.05, padding = 0.06 },
                            nodes = {
                                { n = G.UIT.T, config = { text = ' ' .. localize('k_' .. (compatible and 'compatible' or 'incompatible')) .. ' ', colour = G.C.UI.TEXT_LIGHT, scale = 0.32 * 0.8 } },
                            }
                        }
                    }
                }
            }
            return { main_end = main_end, 
                    vars = { card.ability.extra.copiesNumber, card.ability.extra.copies } }
        end
        return { vars = { card.ability.extra.copiesNumber, card.ability.extra.copies } }
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            card.ability.extra.copiesNumber = math.random(2)
        end

        local other_joker = nil
        if card.ability.extra.copiesNumber == 1 then
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i + 1] end
            end
            return SMODS.blueprint_effect(card, other_joker, context)
        else
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then other_joker = G.jokers.cards[i - 1] end
            end
            return SMODS.blueprint_effect(card, other_joker, context)
        end
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
    pools = {["wagerJokers"] = true, ["Food"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = false,
    eternal_compat = true,
    preishable_compat = true,

    config = { extra = { money = 10, moneyLoss = 1, playAmount = 10 }},

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

-- Charitable Joker
SMODS.Joker {
    key = 'charitableJoker',
    loc_txt = {
        name = 'Charitable Joker',
        text = {
            "Each {C:diamonds}#2#{} card",
            "held in hand",
            "gives {C:chips}+#1#{} chips",
        }
    },
    atlas = 'jokers',
    rarity = 1,
    cost = 5,
    pools = {["wagerJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    pos = { x = 0, y = 2 },
    config = { extra = { chips = 30, suit = 'Diamonds' } },

    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, localize(card.ability.extra.suit, 'suits_singular') } }
	end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:is_suit(card.ability.extra.suit) then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
	end,
}

-- Pure Joker
SMODS.Joker {
    key = 'pureJoker',
    loc_txt = {
        name = 'Pure Joker',
        text = {
            "Each {C:hearts}#2#{} card",
            "held in hand",
            "gives {C:chips}+#1#{} chips",
        }
    },
    atlas = 'jokers',
    rarity = 1,
    cost = 5,
    pools = {["wagerJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    pos = { x = 1, y = 2 },
    config = { extra = { chips = 30, suit = 'Hearts' } },

    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, localize(card.ability.extra.suit, 'suits_singular') } }
	end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:is_suit(card.ability.extra.suit) then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
	end,
}

-- Peaceful Joker
SMODS.Joker {
    key = 'peacefulJoker',
    loc_txt = {
        name = 'Peaceful Joker',
        text = {
            "Each {C:spades}#2#{} card",
            "held in hand",
            "gives {C:chips}+#1#{} chips",
        }
    },
    atlas = 'jokers',
    rarity = 1,
    cost = 5,
    pools = {["wagerJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    pos = { x = 2, y = 2 },
    config = { extra = { chips = 30, suit = 'Spades' } },

    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, localize(card.ability.extra.suit, 'suits_singular') } }
	end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:is_suit(card.ability.extra.suit) then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
	end,
}

-- Abstemious Joker
SMODS.Joker {
    key = 'abstemiousJoker',
    loc_txt = {
        name = 'Abstemious Joker',
        text = {
            "Each {C:clubs}#2#{} card",
            "held in hand",
            "gives {C:chips}+#1#{} chips",
        }
    },
    atlas = 'jokers',
    rarity = 1,
    cost = 5,
    pools = {["wagerJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compat = true,
    eternal_compat = true,
    preishable_compat = true,

    pos = { x = 3, y = 2 },
    config = { extra = { chips = 30, suit = 'Clubs' } },

    loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chips, localize(card.ability.extra.suit, 'suits_singular') } }
	end,

    calculate = function(self, card, context)
        if context.individual and context.cardarea == G.hand and not context.end_of_round and context.other_card:is_suit(card.ability.extra.suit) then
            if context.other_card.debuff then
                return {
                    message = localize('k_debuffed'),
                    colour = G.C.RED
                }
            else
                return {
                    chips = card.ability.extra.chips
                }
            end
        end
	end,
}

-- traffic joker
SMODS.Joker {
    key = "traffic",
    loc_txt = {
        name = 'Traffic',
        text = {
            "+X1 mult for each",
            "Joker above 5",
            "Currently X#1# mult",
        }
    },
    blueprint_compat = true,
    rarity = 1,
    cost = 4,
    atlas = 'jokers',
    pos = { x = 4, y = 2 },
    config = { extra = { total = 1 } },
    loc_vars = function(self, info_queue, card)
        -- makes sure that it doesnt crash when viewing it in the collection in the main menu
        local joker_count = (G and G.jokers and G.jokers.cards) and #G.jokers.cards or 0
        card.ability.extra.total = 1 + math.max(0, joker_count - 5)
        return { vars = { card.ability.extra.total } }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local joker_count = #G.jokers.cards
            local total = 1 + math.max(0, joker_count - 5)
            return {
                x_mult = total
            }
        end
    end,
    in_pool = function(self, args)
        return #G.jokers.cards > 5
    end
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
    pools = {["wagerJokers"] = true},

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

-- This changes variables globally each round
function SMODS.current_mod.reset_game_globals(run_start)
    reset_vremade_atJoker_card()
    reset_vremade_prism_card()
end