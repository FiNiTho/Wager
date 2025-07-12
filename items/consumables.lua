SMODS.Atlas {
    key = 'consumables',
    path = 'consumables.png',
    px = 70,
    py = 95
}

-- Base gamble type
SMODS.ConsumableType {
    object_type = "ConsumableType",
    key = "Gamble",
    loc_txt = {
        name = "Gamble",
        collection = "Gamble Cards",
    },
    primary_colour = G.C.SET.gamble2,
    secondary_colour = G.C.SET.gamble,
    collection_rows = { 3, 4 },
    shop_rate = 0.0,
    default = "c_finnmod_wager",
}

-- Base gamble card template
local function create_gamble_card(params)
    return SMODS.Consumable {
        key = params.key,
        loc_txt = {
            name = params.name,
            text = params.text
        },
        atlas = 'consumables',
        set = 'Gamble',
        cost = params.cost or 4,
        pos = params.pos,
        config = {
            extra = (function()
                local config = params.config or {}
                config.active = config.active or false
                config.hasDone = config.hasDone or false
                return config
            end)()
        },

        check_for_unlock = function(self, args)
            unlock_card(self)
        end,

        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = G.P_CENTERS[params.info1]
            info_queue[#info_queue+1] = G.P_CENTERS[params.info2]
            info_queue[#info_queue+1] = G.P_CENTERS[params.info3]
            local vars = {card.ability.extra.roundCount, card.ability.extra.maxroundCount, (G.GAME.probabilities.normal or 1)}
            for _, v in ipairs(params.loc_vars or {}) do
                table.insert(vars, card.ability.extra[v])
            end
            return { vars = vars }
        end,

        calculate = function(self, card, context)
            -- Handle round counting and max round increase if created by jackpot
            if G.consumeables and G.consumeables.cards then
                if card.ability.extra.created_by_jackpot and not card.ability.extra.hasDone then
                    card.ability.extra.maxroundCount = card.ability.extra.maxroundCount + 1
                    card.ability.extra.hasDone = true
                end
            end

            if context.end_of_round and not context.repetition and context.game_over == false then
                card.ability.extra.roundCount = card.ability.extra.roundCount + 1

                if card.ability.extra.roundCount >= card.ability.extra.maxroundCount then
                    juice_card_until(card, function(c)
                        return c.ability.extra.roundCount >= c.ability.extra.maxroundCount
                    end, true)

                    card.ability.extra.active = true

                    if card.ability.extra.active == false then
                        return {
                            message = "Active",
                        }
                    end
                end
                
                if card.ability.extra.roundCount < 2 then
                    return { message = card.ability.extra.roundCount .. "/" .. card.ability.extra.maxroundCount }
                else
                    return {}
                end
            end
        end,

        can_use = function(self, card)
            if card.ability.extra.active then
                if params.can_use_addons and not params.can_use_addons(card) then
                    return false
                end
                return true
            end

            if G.consumeables and G.consumeables.cards then
                for _, c in ipairs(G.consumeables.cards) do
                    if c == card then return false end
                end
                if #G.consumeables.cards >= G.consumeables.config.card_limit then
                    return false
                end
            end
            return true
        end,

        use = function(self, card, area, copier)
            if card.ability.extra.active == true then
                -- Execute the card's effect and capture the return value
                local result = params.effect and params.effect(card) or nil

                return {}
            else
                local new_card = create_card("Consumable", G.consumeables, nil, nil, true, true, "c_finnmod_"..params.key)
                new_card:start_materialize()
                new_card:add_to_deck()
                G.consumeables:emplace(new_card)
            end
        end
    }
end

-- Wager gamble card
SMODS.Consumable {
    key = 'wager',
    loc_txt = {
        name = 'Wager',
        text = {
            "{C:green}#1# in #3#{} chance to gain {C:money}$#4#{}",
            "every time this card is",
            "used {C:inactive}(Max of {}{C:money}$#5#{}{C:inactive}){}",
            "{C:inactive}(Currently {}{C:money}$#2#{}{C:inactive}){}",
        }
    },
    atlas = 'consumables',
    set = 'Gamble',
    cost = 4,
    pools = {},

    pos = { x = 0, y = 0 },
    config = { extra = {
            odds = 2,
            currentAmount = 5,
            gainAmount = 5,
            maxAmount = 30,
        },     
    },

    check_for_unlock = function(self, args)
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
        G.GAME.gamble_shared = G.GAME.gamble_shared or {
            currentAmount = card.ability.extra.currentAmount
        }
        return { vars = {  
                (G.GAME.probabilities.normal or 1),
                G.GAME.gamble_shared.currentAmount,
                card.ability.extra.odds,
                card.ability.extra.gainAmount,
                card.ability.extra.maxAmount,
                } }
    end,

    can_use = function(self, card)
        return true
    end,

    use = function(self, card, area)
        if G.GAME.gamble_shared.currentAmount < card.ability.extra.maxAmount and pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.odds then
            card_eval_status_text(card, "extra", nil, nil, nil, {
                message = "Upgraded",
                colour = G.C.SET.gamble
            })
            G.E_MANAGER:add_event(Event({
                ease_dollars(G.GAME.gamble_shared.currentAmount)
            }))
            G.GAME.gamble_shared.currentAmount = G.GAME.gamble_shared.currentAmount + card.ability.extra.gainAmount
        else
            G.E_MANAGER:add_event(Event({
                ease_dollars(G.GAME.gamble_shared.currentAmount)
            }))
        end
    end
}

-- Roulette gamble card (Cryptid version)
if (SMODS.Mods["Cryptid"] or {}).can_load then
    create_gamble_card({
        key = 'roulette',
        name = 'Roulette',
        text = {
            "After {C:attention}#2#{} round create a random Joker",
            "{C:green}#3# in #5#{} chance to get {C:cry_epic}epic{}",
            "{C:green}#3# in #4#{} chance to get {C:legendary,E:1}legendary{}",
            "{C:green}#3# in #6#{} chance to get {C:cry_exotic,E:1}exotic{}",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
        },
        pos = { x = 1, y = 0 },
        config = {
            roundCount = 0, 
            maxroundCount = 1,
            legendaryOdds = 30,
            epicOdds = 10,
            exoticOdds = 50,
        },
        loc_vars = {'legendaryOdds', 'epicOdds', 'exoticOdds'},
        effect = function(card)
            if #G.jokers.cards < G.jokers.config.card_limit then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound("tarot1")
                    if pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.exoticOdds then
                        local new_card = create_card("Joker", G.jokers, nil, "cry_exotic", nil, nil)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                    elseif pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.legendaryOdds then
                        local new_card = create_card("Joker", G.jokers, true, nil, nil, nil)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                    elseif pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.epicOdds then
                        local new_card = create_card("Joker", G.jokers, nil, "cry_epic", nil, nil)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                    else
                        local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                    end
                return true
                end }))
                delay(0.6)
            end
        end,
        can_use_addons = function(card)
            return #G.jokers.cards < G.jokers.config.card_limit
        end
    })
else-- Normal roulette version
    create_gamble_card({
        key = 'roulette',
        name = 'Roulette',
        text = {
            "After {C:attention}#2#{} round create a random Joker",
            "{C:green}#3# in #5#{} chance to get {C:rare}rare{}",
            "{C:green}#3# in #4#{} chance to get {C:legendary,E:1}legendary{}",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
        },
        pos = { x = 1, y = 0 },
        config = {
            roundCount = 0, 
            maxroundCount = 1,
            legendaryOdds = 30,
            rareOdds = 10,
        },
        loc_vars = {'legendaryOdds', 'rareOdds'},
        effect = function(card)
            if #G.jokers.cards < G.jokers.config.card_limit then
                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.4, func = function()
                    play_sound("tarot1")
                    if pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.legendaryOdds then
                        local new_card = create_card("Joker", G.jokers, true, nil, nil, nil)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                    elseif pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.rareOdds then
                        local new_card = create_card("Joker", G.jokers, nil, 1, nil, nil)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                    else
                        local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                    end
                return true
                end }))
                delay(0.6)
            end
        end,

        can_use_addons = function(card)
            return #G.jokers.cards < G.jokers.config.card_limit
        end
    })
end

-- Cocktail gamble card
create_gamble_card({
    key = 'cocktail',
    name = 'Cocktail',
    text = {
        "After {C:attention}#2#{} round {C:green}1 to #4#{}",
        "selected cards randomly",
        "enhances to {C:attention}Stained{} cards",
        "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
    },
    pos = { x = 2, y = 0 },
    config = {
        roundCount = 0,
        maxroundCount = 1,
        maxAmount = 3,
    },
    info1 = 'm_finnmod_stained',
    loc_vars = { 'maxAmount' },
    effect = function(card)
        local max_seals = card.ability.extra.maxAmount or 3
        local highlighted = G.hand.highlighted
        local seal_count = math.min(#highlighted, max_seals)
        local amount_to_seal = math.random(1, seal_count)

        -- Make a shallow copy and shuffle it
        local shuffled = {}
        for _, v in ipairs(highlighted) do table.insert(shuffled, v) end
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end

        for i = 1, amount_to_seal do
            local selected = shuffled[i]
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound("tarot1")
                    selected:juice_up(0.3, 0.5)
                    return true
                end,
            }))
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.1,
                func = function()
                    if selected then
                        selected:set_ability("m_finnmod_stained")
                    end
                    return true
                end,
            }))
        end

        -- Unhighlight all afterwards
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.5,
            func = function()
                G.hand:unhighlight_all()
                return true
            end,
        }))
    end,

    can_use_addons = function(card)
        return #G.hand.highlighted <= card.ability.extra.maxAmount and #G.hand.highlighted >= 1
    end
})

-- Slots gamble card
create_gamble_card({
    key = 'slots',
    name = 'Slots',
    text = {
        "After {C:attention}#2#{} rounds",
        "Add {C:dark_edition}foil{}, {C:dark_edition}holographic{},",
        "or {C:dark_edition}polychrome{} effect to",
        "{C:attention}1{} random joker",
        "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
    },
    pos = { x = 3, y = 0 },
    config = {
        roundCount = 0,
        maxroundCount = 3,
        odds = 100,
        negetiveOdds = 5,
        polychromeOdds = 10,
        holographicOdds = 35,
        foilOdds = 40,
    },
    info1 = 'e_foil',
    info2 = 'e_holo',
    info3 = 'e_polychrome',
    loc_vars = {'odds', 'negetiveOdds', 'polychromeOdds', 'holographicOdds', 'foilOdds'},
    effect = function(card)
        local eligibleJokers = {}
        for i = 1, #G.jokers.cards do
            local joker = G.jokers.cards[i]
            if joker.ability.name ~= card.ability.name
                and joker.ability.set == "Joker"
                and not joker.edition then
                    eligibleJokers[#eligibleJokers + 1] = joker
            end
        end

        if #eligibleJokers > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    local edition = poll_edition('finnmod_slots', nil, true, true,
                        { 'e_polychrome', 'e_holo', 'e_foil' })
                    local selected_card = pseudorandom_element(eligibleJokers)
                    selected_card:set_edition(edition, true)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end,
    can_use_addons = function(card)
        local count = 0
        for i = 1, #G.jokers.cards do
            local joker = G.jokers.cards[i]
            if joker.ability.name ~= card.ability.name
                and joker.ability.set == "Joker"
                and not joker.edition then
                count = count + 1
            end
        end
        return count > 0
    end
})

-- -- planet card upgrades
-- create_gamble_card({
--     key = 'planet',
--     name = 'Planet',
--     text = {
--         "After {C:attention}#2#{} round {C:green}1 to #4#{}",
--         "selected cards randomly",
--         "enhances to {C:attention}Stained{} cards",
--         "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
--     },
--     pos = { x = 4, y = 0 },
--     config = {
--         roundCount = 0,
--         maxroundCount = 1,
--         maxAmount = 3,
--     },
--     loc_vars = { 'maxAmount' },
--     effect = function(card)
        
--     end
-- })

-- -- chips forever
-- create_gamble_card({
--     key = 'chipsForever',
--     name = 'Chips Forever',
--     text = {
--         "After {C:attention}#2#{} round {C:green}1 to #4#{}",
--         "selected cards randomly",
--         "enhances to {C:attention}Stained{} cards",
--         "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
--     },
--     pos = { x = 4, y = 0 },
--     config = {
--         roundCount = 0,
--         maxroundCount = 1,
--         maxAmount = 3,
--     },
--     loc_vars = { 'maxAmount' },
--     effect = function(card)
        
--     end
-- })

-- -- mult forever
-- create_gamble_card({
--     key = 'multForever',
--     name = 'Mult Forever',
--     text = {
--         "After {C:attention}#2#{} round {C:green}1 to #4#{}",
--         "selected cards randomly",
--         "enhances to {C:attention}Stained{} cards",
--         "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
--     },
--     pos = { x = 4, y = 0 },
--     config = {
--         roundCount = 0,
--         maxroundCount = 1,
--         maxAmount = 3,
--     },
--     loc_vars = { 'maxAmount' },
--     effect = function(card)
        
--     end
-- })

-- -- misc cryptid stuff gamble card
-- if (SMODS.Mods["Cryptid"] or {}).can_load then
--     create_gamble_card({
--         key = 'cryptid',
--         name = 'Cryptid Shit',
--         text = {
--             "After {C:attention}#2# rounds{} it has a",
--             "{C:green}#4#%{} chance to get {C:cry_cursed}cursed{}",
--             "{C:green}#5#%{} chance to get {C:cry_meme}meme{}",
--             "{C:green}#6#%{} chance to get {C:cry_candy}candy{}",
--             "{C:green}#7#%{} chance to get {C:cry_m}m{}",
--             "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
--         },
--         pos = { x = 4, y = 0 },
--         config = {
--             roundCount = 0,
--             maxroundCount = 2, 
--             odds = 100,
--             cursedOdds = 10,
--             memedOdds = 15,
--             candyOdds = 35,
--             mOdds = 40,
--         },
--         loc_vars = {'odds', 'cursedOdds', 'memedOdds', 'candyOdds', 'mOdds'},
--         effect = function(card)
--             if #G.jokers.cards < G.jokers.config.card_limit then
--                 local number = math.random(card.ability.extra.odds)
--                 if number <= card.ability.extra.cursedOdds then
--                     local card = create_card("Joker", G.jokers, nil, "cry_cursed", nil, nil, nil)
--                     card:add_to_deck()
--                     card:start_materialize()
--                     G.jokers:emplace(card)
--                 elseif number <= card.ability.extra.cursedOdds + card.ability.extra.memedOdds then
--                     local new_card = create_card("Meme", G.jokers, nil, nil, nil, nil)
--                     new_card:add_to_deck()
--                     card:start_materialize()
--                     G.jokers:emplace(new_card)
--                 elseif number <= card.ability.extra.cursedOdds + card.ability.extra.memedOdds + card.ability.extra.candyOdds then
--                     local new_card = create_card("Joker", G.jokers, nil, "cry_candy", nil, nil)
--                     new_card:add_to_deck()
--                     card:start_materialize()
--                     G.jokers:emplace(new_card)
--                 else
--                     local new_card = create_card("M", G.jokers, nil, nil, nil, nil)
--                     new_card:add_to_deck()
--                     card:start_materialize()
--                     G.jokers:emplace(new_card)
--                 end
--             end
--         end
--     })
-- end

-- {spectral cards}
-- gamble seal
SMODS.Consumable {
    key = 'martingale',
    loc_txt = {
        name = 'Martingale',
        text = {
            "Add a {C:gamble}Auburn Seal{}",
            "to {C:attention}1{} selected",
            "card in your hand"
        }
    },
    atlas = 'consumables',
    set = 'Spectral',
    cost = 4,
    pools = {},

    pos = { x = 0, y = 1 },
    config = { 
            max_highlighted = 1,
            extra = 'finnmod_auburnSeal', },

    check_for_unlock = function(self, args)
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = G.P_SEALS[(card.ability or self.config).extra]
        return { vars = { card.ability.max_highlighted } }
    end,

    use = function(self, card, area)
		for i = 1, #G.hand.highlighted do
			local highlighted = G.hand.highlighted[i]
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound("tarot1")
					highlighted:juice_up(0.3, 0.5)
					return true
				end,
			}))
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.1,
				func = function()
					if highlighted then
						highlighted:set_seal("finnmod_auburnSeal")
					end
					return true
				end,
			}))
			delay(0.5)
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.2,
				func = function()
					G.hand:unhighlight_all()
					return true
				end,
			}))
		end
    end
}