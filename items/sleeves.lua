if CardSleeves then
    SMODS.Atlas{
        key = 'sleeves',
        path = 'sleeves.png',
        px = 73,
        py = 95,
    }

    -- dog sleeve
    local dogsleeve = CardSleeves.Sleeve({
		key = "dog_deck_sleeve",
		name = "Dog Sleeve",
		atlas = "sleeves",
        loc_txt = {
        name = "Dog",
            text={
            "Start with {C:attention}5{} dog jokers",
            "create another one",
            "when boss blind is defeated",
            "{C:inactive}(must have room){}"
            },
        },
		pos = { x = 0, y = 0 },
		config = { hands = 0, discards = 0, joker = 'dog'},
		discovered = true,
        unlocked = true,
		apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    -- Add 5 jokers at apply-time if consumeables exist
                    if G.consumeables then
                        for i = 1, 5 do
                            local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_finnmod_dog", "finnmod_deck")
                            -- card:set_edition("e_negative", true)
                            card:add_to_deck()
                            G.jokers:emplace(card)
                        end
                    end
                    return true
                end
            }))
        end,

        calculate = function(self, back, context)
            if context.end_of_round
                and G.GAME.blind:get_type() == 'Boss'
                and not G.GAME.round_resets.dog_joker_given
            then
                G.GAME.round_resets.dog_joker_given = true

                G.E_MANAGER:add_event(Event({
                    func = function()
                        if #G.jokers.cards < G.jokers.config.card_limit then
                            local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_finnmod_dog", "finnmod_deck")
                            card:add_to_deck()
                            G.jokers:emplace(card)
                        end
                        G.GAME.round_resets.dog_joker_given = false
                        return true
                    end
                }))
            end
        end,
	})

    -- gamble sleeve
    local gamblesleeve = CardSleeves.Sleeve({
		key = "gamble_deck_sleeve",
		name = "Gamble Sleeve",
		atlas = "sleeves",
        loc_txt = {
            name = "Gamble",
            text={
            "Start run with",
            "one of the {C:gamble}Gamble{} jokers",
            "and a random {C:gamble}Gamble{} card"
            },
        },
		config = { },
        pos = { x = 1, y = 0 },
		discovered = true,
        unlocked = true,
		apply = function(self)
            G.E_MANAGER:add_event(Event({
                func = function()
                    if G.consumeables then
                        local card = create_card("gambleJoker", G.jokers, nil, nil, nil, nil)
                        card:add_to_deck()
                        G.jokers:emplace(card)
                    end
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                func = function()
                    local new_card = create_card("Gamble", G.consumeables, nil, nil, true, true, nil)
                    new_card.ability.extra.created_by_jackpot = true
                    G.consumeables:emplace(new_card)
                    return true
                end
            }))
        end,
	})
end