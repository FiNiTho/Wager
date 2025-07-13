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
    weight = 1,
    pos = { x = 0, y = 0 },
    draw_hand = false,
    kind = "Gamble",

    loc_txt = {
        name = 'Gamble Pack',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:gamble} Gamble{} cards",
        },
        group_name = {"Gamble Pack"},
    },

    config = { extra = 2, choose = 1 },

    loc_vars = function(self, info_queue, card)
        return { 
                vars = { card.ability.choose, card.ability.extra, colours = G.C.SET.gamble },
            }
    end,

    create_card = function(self, card)
		return create_card("Gamble", G.pack_cards, nil, nil, true, true, nil, "gambleSmall")
	end,

    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.gamble)
        ease_background_colour({ new_colour = G.C.SET.gamble, special_colour = G.C.SET.gamble, contrast = 3 })
    end
}

-- small gamble pack
SMODS.Booster {
    key = "gambleSmall2",
    cost = 4,
    atlas = "boosters",
    weight = 1,
    pos = { x = 1, y = 0 },
    draw_hand = false,
    kind = "Gamble",

    loc_txt = {
        name = 'Gamble Pack',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:gamble} Gamble{} cards",
        },
        group_name = {"Gamble Pack"},
    },

    config = { extra = 2, choose = 1 },

    loc_vars = function(self, info_queue, card)
        return { 
                vars = { card.ability.choose, card.ability.extra, colours = G.C.SET.gamble },
            }
    end,

    create_card = function(self, card)
		return create_card("Gamble", G.pack_cards, nil, nil, true, true, nil, "gambleSmall2")
	end,

    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.gamble)
        ease_background_colour({ new_colour = G.C.SET.gamble, special_colour = G.C.SET.gamble, contrast = 3 })
    end
}

-- big gamble pack
SMODS.Booster {
    key = "gambleBig",
    cost = 6,
    atlas = "boosters",
    weight = 0.8,
    pos = { x = 2, y = 0 },
    draw_hand = false,
    kind = "Gamble",

    loc_txt = {
        name = 'Big Gamble Pack',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:gamble} Gamble{} cards",
        },
        group_name = {"Big Gamble Pack"},
    },

    config = { extra = 3, choose = 1 },

    loc_vars = function(self, info_queue, card)
        return { 
                vars = { card.ability.choose, card.ability.extra, colours = G.C.SET.gamble },
            }
    end,

    create_card = function(self, card)
		return create_card("Gamble", G.pack_cards, nil, nil, true, true, nil, "gambleBig")
	end,

    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.gamble)
        ease_background_colour({ new_colour = G.C.SET.gamble, special_colour = G.C.SET.gamble2, contrast = 3 })
    end
}

-- mega gamble pack
SMODS.Booster {
    key = "gambleMega",
    cost = 6,
    atlas = "boosters",
    weight = 0.4,
    pos = { x = 3, y = 0 },
    draw_hand = false,
    kind = "Gamble",

    loc_txt = {
        name = 'Mega Gamble Pack',
        text = {
            "Choose {C:attention}#1#{} of up to",
            "{C:attention}#2#{C:gamble} Gamble{} cards",
        },
        group_name = {"Mega Gamble Pack"},
    },

    config = { extra = 4, choose = 1 },

    loc_vars = function(self, info_queue, card)
        return { 
                vars = { card.ability.choose, card.ability.extra, colours = G.C.SET.gamble },
            }
    end,

    create_card = function(self, card)
		return create_card("Gamble", G.pack_cards, nil, nil, true, true, nil, "gambleMega")
	end,

    ease_background_colour = function(self)
        ease_colour(G.C.DYN_UI.MAIN, G.C.SET.gamble)
        ease_background_colour({ new_colour = G.C.SET.gamble, special_colour = G.C.SET.gamble2, contrast = 3 })
    end
}