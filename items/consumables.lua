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
    collection_rows = { 3, 3 },
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
            G.GAME.gamble_shared = G.GAME.gamble_shared or {
                currentAmount = card.ability.extra.currentAmount or 2
            }
            local vars = {card.ability.extra.roundCount, card.ability.extra.maxroundCount, (G.GAME.probabilities.normal or 1), G.GAME.gamble_shared.currentAmount}
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

-- -- old Wager gamble card
-- create_gamble_card({
--     key = 'wager',
--     name = 'Wager',
--     text = {
--         "{C:green}#3# in #4#{} to gain {C:money}+$#6#{}",
--         "every time this card is used",
--         "currently {C:money}$#4#{}",
--         "{C:inactive}(Maxes out at {}{C:attention}#7#{}{C:inactive}){}"
--     },
--     pos = { x = 0, y = 0 },
--     config = {
--         roundCount = 1, 
--         maxroundCount = 1,
--         odds = 2,
--         gainAmount = 2,
--     },
--     loc_vars = {'odds', 'gainAmount'},
--     effect = function(card)
--         G.E_MANAGER:add_event(Event({
--             ease_dollars(G.GAME.gamble_shared.currentAmount)
--         }))
--         if pseudorandom('dog') < G.GAME.probabilities.normal / card.ability.extra.odds then
--             G.GAME.gamble_shared.currentAmount = G.GAME.gamble_shared.currentAmount + card.ability.extra.gainAmount
--         end
        
--         return {}
--     end
-- })

-- Wager gamble card
SMODS.Consumable {
    key = 'wager',
    loc_txt = {
        name = 'Wager',
        text = {
            "{C:green}#1# in #3#{} to gain {C:money}+$#4#{}",
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
        if pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.odds then
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
            "After {C:attention}#2# rounds{} it has a",
            "{C:green}#4#%{} chance to get {C:cry_exotic,E:1}exotic{}",
            "{C:green}#5#%{} chance to get {C:legendary,E:1}legendary{}",
            "{C:green}#6#%{} chance to get {C:cry_epic}epic{}",
            "{C:green}#7#%{} chance to get {C:rare}rare{}",
            "{C:green}#8#%{} chance to get {C:uncommon}uncommon{}",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
        },
        pos = { x = 1, y = 0 },
        config = {
            roundCount = 0,
            maxroundCount = 2, 
            odds = 100,
            exoticOdds = 2,
            legendaryOdds = 5,
            epicOdds = 20,
            rareOdds = 35,
            uncommenOdds = 40,
        },
        loc_vars = {'odds', 'exoticOdds', 'legendaryOdds', 'epicOdds', 'rareOdds', 'uncommenOdds'},
        effect = function(card)
            if #G.jokers.cards < G.jokers.config.card_limit then
                local number = math.random(card.ability.extra.odds)
                if number <= card.ability.extra.exoticOdds then
                    local card = create_card("Joker", G.jokers, nil, "cry_exotic", nil, nil, nil)
                    card:add_to_deck()
                    card:start_materialize()
                    G.jokers:emplace(card)
                elseif number <= card.ability.extra.exoticOdds + card.ability.extra.legendaryOdds then
                    local new_card = create_card("Joker", G.jokers, true, nil, nil, nil)
                    new_card:add_to_deck()
                    G.jokers:emplace(new_card)
                elseif number <= card.ability.extra.exoticOdds + card.ability.extra.legendaryOdds + card.ability.extra.epicOdds then
                    local new_card = create_card("Joker", G.jokers, nil, "cry_epic", nil, nil)
                    new_card:add_to_deck()
                    G.jokers:emplace(new_card)
                elseif number <= card.ability.extra.exoticOdds + card.ability.extra.legendaryOdds + card.ability.extra.epicOdds + card.ability.extra.rareOdds then
                    local new_card = create_card("Joker", G.jokers, nil, 1, nil, nil)
                    new_card:add_to_deck()
                    G.jokers:emplace(new_card)
                else
                    local new_card = create_card("Joker", G.jokers, nil, 0.8, nil, nil)
                    new_card:add_to_deck()
                    G.jokers:emplace(new_card)
                end
            end
        end
    })
else
    -- Normal roulette version
    create_gamble_card({
        key = 'roulette',
        name = 'Roulette',
        text = {
            "After {C:attention}#2# rounds{} it has a",
            "{C:green}#4#%{} chance to get {C:legendary,E:1}legendary{}",
            "{C:green}#5#%{} chance to get {C:rare}rare{}",
            "{C:green}#6#%{} chance to get {C:uncommon}uncommon{}",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
        },
        pos = { x = 1, y = 0 },
        config = {
            roundCount = 0, 
            maxroundCount = 2,
            odds = 100,
            legendaryOdds = 2,
            rareOdds = 35,
            uncommenOdds = 65,
        },
        loc_vars = {'odds', 'legendaryOdds', 'rareOdds', 'uncommenOdds'},
        effect = function(card)
            if #G.jokers.cards < G.jokers.config.card_limit then
                local number = math.random(card.ability.extra.odds)
                if number <= card.ability.extra.legendaryOdds then
                    local new_card = create_card("Joker", G.jokers, true, nil, nil, nil)
                    new_card:add_to_deck()
                    G.jokers:emplace(new_card)
                elseif number <= card.ability.extra.legendaryOdds + card.ability.extra.rareOdds then
                    local new_card = create_card("Joker", G.jokers, nil, 1, nil, nil)
                    new_card:add_to_deck()
                    G.jokers:emplace(new_card)
                else
                    local new_card = create_card("Joker", G.jokers, nil, 0.8, nil, nil)
                    new_card:add_to_deck()
                    G.jokers:emplace(new_card)
                end
            end
        end
    })
end

-- Cocktail gamble card
create_gamble_card({
    key = 'cocktail',
    name = 'Cocktail',
    text = {
        "After {C:attention}#2# rounds{} it has a",
        "{C:green}#4#%{} chance to get {C:spectral}spectral card{}",
        "{C:green}#5#%{} chance to get {C:tarot}tarot card{}",
        "{C:green}#6#%{} chance to get {C:planet}planet card{}",
        "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
    },
    pos = { x = 2, y = 0 },
    config = {
        roundCount = 0,
        maxroundCount = 1,
        odds = 100,
        spectralOdds = 25,
        tarotOdds = 35,
        planetOdds = 40,
    },
    loc_vars = {'odds', 'spectralOdds', 'tarotOdds', 'planetOdds'},
    effect = function(card)
        local number = math.random(card.ability.extra.odds)
        if number <= card.ability.extra.spectralOdds then
            local new_card = create_card("Spectral", G.consumeables, nil, nil, true, true, nil)
            new_card:add_to_deck()
            G.consumeables:emplace(new_card)
        elseif number <= card.ability.extra.spectralOdds + card.ability.extra.tarotOdds then
            local new_card = create_card("Tarot", G.consumeables, nil, nil, true, true, nil)
            G.consumeables:emplace(new_card)
        else
            local new_card = create_card("Planet", G.consumeables, nil, nil, true, true, nil)
            G.consumeables:emplace(new_card)
        end
    end
})

-- Slots gamble card
create_gamble_card({
    key = 'slots',
    name = 'Slots',
    text = {
        "After {C:attention}#2# rounds{} it has a",
        "{C:green}#4#%{} chance to give a joker {C:dark_edition,E:1}negetive{}",
        "{C:green}#5#%{} chance to give a joker {C:enhanced}polychrome{}",
        "{C:green}#6#%{} chance to give a joker {C:rare}holographic{}",
        "{C:green}#7#%{} chance to give a joker {C:spectral}foil{}",
        "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
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

        local number = math.random(card.ability.extra.odds)
        if #eligibleJokers > 0 then
            local target = pseudorandom_element(eligibleJokers, pseudoseed("finnmod_edition"))
            if number <= card.ability.extra.negetiveOdds then
                target:set_edition({ negative = true }, true)
            elseif number <= card.ability.extra.negetiveOdds + card.ability.extra.polychromeOdds then
                target:set_edition({ polychrome = true }, true)
            elseif number <= card.ability.extra.negetiveOdds + card.ability.extra.polychromeOdds + card.ability.extra.holographicOdds then
                target:set_edition({ holo = true }, true)
            else
                target:set_edition({ foil = true }, true)
            end
            target:juice_up(0.4, 0.6)
        end
    end
})

-- misc cryptid stuff gamble card
if (SMODS.Mods["Cryptid"] or {}).can_load then
    create_gamble_card({
        key = 'cryptid',
        name = 'Cryptid Shit',
        text = {
            "After {C:attention}#2# rounds{} it has a",
            "{C:green}#4#%{} chance to get {C:cry_cursed}cursed{}",
            "{C:green}#5#%{} chance to get {C:cry_meme}meme{}",
            "{C:green}#6#%{} chance to get {C:cry_candy}candy{}",
            "{C:green}#7#%{} chance to get {C:cry_m}m{}",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
        },
        pos = { x = 1, y = 0 },
        config = {
            roundCount = 0,
            maxroundCount = 2, 
            odds = 100,
            cursedOdds = 10,
            memedOdds = 15,
            candyOdds = 35,
            mOdds = 40,
        },
        loc_vars = {'odds', 'cursedOdds', 'memedOdds', 'candyOdds', 'mOdds'},
        effect = function(card)
            if #G.jokers.cards < G.jokers.config.card_limit then
                local number = math.random(card.ability.extra.odds)
                if number <= card.ability.extra.cursedOdds then
                    local card = create_card("Joker", G.jokers, nil, "cry_cursed", nil, nil, nil)
                    card:add_to_deck()
                    card:start_materialize()
                    G.jokers:emplace(card)
                elseif number <= card.ability.extra.cursedOdds + card.ability.extra.memedOdds then
                    local new_card = create_card("Meme", G.jokers, nil, nil, nil, nil)
                    new_card:add_to_deck()
                    card:start_materialize()
                    G.jokers:emplace(new_card)
                elseif number <= card.ability.extra.cursedOdds + card.ability.extra.memedOdds + card.ability.extra.candyOdds then
                    local new_card = create_card("Joker", G.jokers, nil, "cry_candy", nil, nil)
                    new_card:add_to_deck()
                    card:start_materialize()
                    G.jokers:emplace(new_card)
                else
                    local new_card = create_card("M", G.jokers, nil, nil, nil, nil)
                    new_card:add_to_deck()
                    card:start_materialize()
                    G.jokers:emplace(new_card)
                end
            end
        end
    })
end

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