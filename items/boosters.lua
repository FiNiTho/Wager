SMODS.Atlas {
    key = "boosters",
    path = "boosters.png",
    px = 72,
    py = 95,
}

-- small gamble pack
SMODS.Booster {
    key = "gambleSmall",
    cost = 4,
    atlas = "boosters",
    weight = 10,
    pos = { x = 0, y = 0 },
    draw_hand = false,
    kind = "Gamble",

    loc_txt = {
        name = 'Gamble',
        text = {
            "Choose {C:attention}#1# out of #2#{}",
            "{C:gamble}Gamble{} cards"
        }
    },

    config = { extra = 2, choose = 1 },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra, colours = G.C.SET.gamble } }
    end,

    create_card = function(self, card)
		return create_card("Gamble", G.pack_cards, nil, nil, true, true, nil, "gambleSmall")
	end,

    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.gamble)
        ease_background_colour({ new_colour = G.C.SET.Gamble, special_colour = G.C.SET.gamble2, contrast = 3 })
    end
}

-- big gamble pack
SMODS.Booster {
    key = "gambleBig",
    cost = 4,
    atlas = "boosters",
    weight = 100,
    pos = { x = 1, y = 0 },
    draw_hand = false,
    kind = "Gamble",

    loc_txt = {
        name = 'Wager',
        text = {
            "Choose {C:attention}#1# out of #2#{}",
            "{C:gamble}Gamble{} cards"
        }
    },

    config = { extra = 3, choose = 1 },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.choose, card.ability.extra, colours = G.C.SET.gamble } }
    end,

    create_card = function(self, card)
		return create_card("Gamble", G.pack_cards, nil, nil, true, true, nil, "gambleBig")
	end,

    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.gamble)
        ease_background_colour({ new_colour = G.C.SET.gamble, special_colour = G.C.SET.gamble2, contrast = 3 })
    end
}