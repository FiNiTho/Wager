SMODS.Atlas{
    key = 'dogdeck',
    path = 'dogdeck.png',
    px = 71,
    py = 95,
}

SMODS.Back({
    key = "dog_deck",
    loc_txt = {
        name = "Dog",
        text={
        "Start with {C:attention}5{}",
        "dog jokers"
        },
        locked = {
        "Unlock by exploding the",
        "{C:attention}Dog{} Joker."
        },
    },
	
	config = { hands = 0, discards = 0, joker = 'dog'},
	pos = { x = 0, y = 0 },
	order = 1,
	atlas = "dogdeck",
    discovered = false,
    unlocked = false,

	apply = function(self)
        G.E_MANAGER:add_event(Event({
			func = function()
				if G.consumeables then
                        for i = 1, 5 do
                            local card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_finnmod_dog", "finnmod_deck")
                            -- card:set_edition("e_negative", true)
                            card:add_to_deck()
                            G.jokers:emplace(card)
                        end
                  end
                  return true
			end,
		}))
	end,

	check_for_unlock = function(self, args)
        if G.GAME.pool_flags and G.GAME.pool_flags.dog_exploded then
            unlock_card(self)
        end
    end,
})