SMODS.Atlas{
    key = 'decks',
    path = 'decks.png',
    px = 71,
    py = 95,
}

-- dog deck
SMODS.Back{
    key = "dog_deck",
    loc_txt = {
        name = "Dog",
        text={
        "Start with {C:attention}5{} {C:attention,T:j_finnmod_dog}dog{} jokers",
        "create another {C:attention,T:j_finnmod_dog}Dog{} Joker",
        "when boss blind is defeated",
        "{C:inactive}(must have room){}"
        },
        unlock = {
        "Unlock by exploding the",
        "{C:attention}Dog{} Joker."
        },
    },
	
	config = { hands = 0, discards = 0, joker = 'dog'},
	pos = { x = 0, y = 0 },
	order = 1,
	atlas = "decks",
    discovered = false,
    unlocked = false,

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


	check_for_unlock = function(self, args)
        if G.GAME.pool_flags and G.GAME.pool_flags.dog_exploded then
            unlock_card(self)
        end
    end,
}

-- gamble deck
SMODS.Back{
    key = "gamble_deck",
    loc_txt = {
        name = "Gamble",
        text={
        "Start run with",
        "one of the {C:gamble}Gamble{} jokers",
        "and the {C:gamble,T:v_finnmod_bet}Bet{} voucher",
        },
        unlock = {
        "Unlock by exploding the",
        "{C:attention}Dog{} Joker."
        },
    },
	
	config = { vouchers = { "v_finnmod_bet", "v_retcon" } },
	pos = { x = 1, y = 0 },
	order = 1,
	atlas = "decks",
    discovered = false,
    unlocked = false,

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
    end,


	check_for_unlock = function(self, args)
        if G.GAME.pool_flags and G.GAME.pool_flags.dog_exploded then
            unlock_card(self)
        end
    end,
}