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
    pools = {["finnmodJokers"] = true},

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

-- Pou joker/tomagachi joker
SMODS.Atlas {
    key = 'Pou',
    path = 'pou.png',
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = 'Pou',
    loc_txt = {
        name = 'Pou',
        text = {
                "{X:chips,C:white}X#1#{} Chips",
                "need to {C:attention}sell{} stuff to feed it",
                "else it will {C:attention}die{} of hunger",
                "{C:inactive}(Currently {}{C:attention}#2#{}{C:inactive} of #3#){}" }
    },
    atlas = 'Pou',
    rarity = 3,
    cost = 8,
    pools = {["finnmodJokers"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = {x = 0, y = 0},
    config = { extra = { Xchips =2, hunger = 1, maxHunger = 4}},

    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.Xchips, card.ability.extra.hunger, card.ability.extra.maxHunger}}
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
                x_chips = card.ability.extra.Xchips
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

-- gamble joker
SMODS.Atlas {
    key = 'gamble',
    path = 'pou.png',
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = 'gamble',
    loc_txt = {
        name = 'Gamble',
        text = {
                "If {C:attention}first hand{} of round countains",
                "{C:attention}three 7's{} create a {C:gamble}Gamble{} card",
                "{C:inactive}(Must have room){}"}
    },
    atlas = 'gamble',
    rarity = 1,
    cost = 4,
    pools = {["finnmodJokers"] = true, ["gambleJoker"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = {x = 0, y = 0},
    config = { extra = { }},

    loc_vars = function(self, info_queue, card)
        return {vars = { }}
    end,

    check_for_unlock = function(self, args)
        unlock_card(self)
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
                if #G.consumeables.cards >= G.consumeables.config.card_limit then
                else
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
                            return true
                        end
                    }))
                end
            end
        end
    end


}