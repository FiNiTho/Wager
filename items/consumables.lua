SMODS.Atlas {
    key = 'consumables',
    path = 'consumables.png',
    px = 71,
    py = 95
}

SMODS.Sound({key = "gambleWin", path = "gambleWin.ogg",})
SMODS.Sound({key = "gambleMiddleWin", path = "gambleMiddleWin.ogg",})
SMODS.Sound({key = "gambleSmallWin", path = "gambleSmallWin.ogg",})

-- Base gamble type
SMODS.ConsumableType {
    object_type = "ConsumableType",
    key = "Gamble",
    loc_txt = {
        name = "Gamble",
        collection = "Gamble Cards",
        
        undiscovered = {
            name = "Not Discovered",
            text = {
                "Purchase or use",
                "this card in an",
                "unseeded run to",
                "learn what it does",
            },
        },
    },
    primary_colour = G.C.SET.gamble2,
    secondary_colour = G.C.SET.gamble,
    collection_rows = { 2, 3 },
    shop_rate = 0.0,
    default = "c_wager_wager",
}

SMODS.UndiscoveredSprite{
    key = "Gamble",
    atlas = "consumables",
    pos = { x = 1, y = 2 },
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

        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = G.P_CENTERS[params.info1]
            info_queue[#info_queue+1] = G.P_CENTERS[params.info2]
            info_queue[#info_queue+1] = G.P_CENTERS[params.info3]
            info_queue[#info_queue+1] = G.P_CENTERS[params.info4]
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

            -- cards can have an calculate effect
            local result = params.calculateEffect and params.calculateEffect(card, context)

            if context.end_of_round and not context.repetition and context.game_over == false then
                card.ability.extra.roundCount = card.ability.extra.roundCount + 1

                if card.ability.extra.roundCount >= card.ability.extra.maxroundCount then
                    juice_card_until(card, function(c)
                        return c.ability.extra.roundCount >= c.ability.extra.maxroundCount
                    end, true)

                    if not card.ability.extra.active then
                        card.ability.extra.active = true
                        return {
                            message = "Active"
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
                local result = params.effect and params.effect(card)

                return {}
            else
                local t_card = copy_card(card)
                t_card:add_to_deck()
                G.consumeables:emplace(t_card)
            end
        end
    }
end

-- Base gamble card template
-- without rounds
local function create_gamble_card_ver2(params)
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
                return config
            end)()
        },

        loc_vars = function(self, info_queue, card)
            info_queue[#info_queue+1] = G.P_CENTERS[params.info1]
            info_queue[#info_queue+1] = G.P_CENTERS[params.info2]
            info_queue[#info_queue+1] = G.P_CENTERS[params.info3]

            if params.infoKey1 then info_queue[#info_queue+1] = { key = params.infoKey1, set = "Other", vars = {G.GAME.rental_rate or 1} } end
            if params.infoKey2 then info_queue[#info_queue+1] = { key = params.infoKey2, set = "Other" } end
            local vars = {(G.GAME.probabilities.normal or 1)}
            for _, v in ipairs(params.loc_vars or {}) do
                table.insert(vars, card.ability.extra[v])
            end
            return { vars = vars }
        end,

        calculate = function(self, card, context)
            -- cards can have an calculate effect
            local result = params.calculateEffect and params.calculateEffect(card, context)
        end,

        can_use = function(self, card)
            if params.can_use_addons and not params.can_use_addons(card) then
                return false
            end
            return true
        end,

        use = function(self, card, area, copier)
            -- Execute the card's effect and capture the return value
            local result = params.effect and params.effect(card)

            return {}
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
            maxAmount = 25,
        },     
    },

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
            play_sound("wager_gambleMiddleWin")
            G.GAME.pool_flags.gambleWin = true

            attention_text({
                text = "Upgraded",
                scale = 1.3,
                hold = 1.4,
                major = card,
                backdrop_colour = G.C.SET.gamble,
                align = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and
                    'tm' or 'cm',
                offset = { x = 0, y = (G.STATE == G.STATES.TAROT_PACK or G.STATE == G.STATES.SPECTRAL_PACK or G.STATE == G.STATES.SMODS_BOOSTER_OPENED) and -0.2 or 0 },
                silent = true
            })
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.06 * G.SETTINGS.GAMESPEED,
                blockable = false,
                blocking = false,
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
            "After {C:attention}#2#{} rounds {C:attention}choose{} out of a few jokers",
            "{C:green}#3# in #5#{} chance to get only {C:cry_epic}epic{}",
            "{C:green}#3# in #4#{} chance to get only {C:legendary,E:1}legendary{}",
            "{C:green}#3# in #6#{} chance to get only {C:cry_exotic,E:1}exotic{}",
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
                        play_sound("wager_gambleWin")
                        G.GAME.pool_flags.gambleWin = true

                        show_joker_menu(1, "cry_exotic")
                    elseif pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.legendaryOdds then
                        play_sound("wager_gambleMiddleWin")
                        G.GAME.pool_flags.gambleWin = true

                        show_joker_menu(2, nil, true)
                    elseif pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.epicOdds then
                        play_sound("wager_gambleSmallWin")
                        G.GAME.pool_flags.gambleWin = true

                        show_joker_menu(2, "cry_epic")
                    else
                        show_joker_menu(3, nil)
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
            "After {C:attention}#2#{} rounds {C:attention}choose{} out of a few jokers",
            "{C:green}#3# in #5#{} chance to get only {C:rare}rare{}",
            "{C:green}#3# in #4#{} chance to get only {C:legendary,E:1}legendary{}",
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
                        play_sound("wager_gambleWin")
                        G.GAME.pool_flags.gambleWin = true

                        show_joker_menu(2, nil, true)
                    elseif pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.rareOdds then
                        play_sound("wager_gambleSmallWin")
                        G.GAME.pool_flags.gambleWin = true

                        show_joker_menu(2, 1)
                    else
                        show_joker_menu(3, nil)
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
create_gamble_card_ver2({
    key = 'cocktail',
    name = 'Cocktail',
    text = {
        "{C:green}1 up to #2#{} selected cards randomly",
        "enhances to {C:attention}Stained{} cards",
    },
    pos = { x = 2, y = 0 },
    config = {
        maxAmount = 3,
    },
    info1 = 'm_wager_stained',
    loc_vars = { 'maxAmount' },
    effect = function(card)
        local max_selected = card.ability.extra.maxAmount or 3
        local highlighted = G.hand.highlighted
        local selected_count = math.min(#highlighted, max_selected)
        local amount_to_selected = math.random(1, selected_count)

        -- make a shallow copy and shuffle it
        local shuffled = {}
        for _, v in ipairs(highlighted) do table.insert(shuffled, v) end
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end

        if amount_to_selected == 3 then
            play_sound("wager_gambleMiddleWin")
            G.GAME.pool_flags.gambleWin = true
        end

        -- effect for the gamble card itself
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                return true
            end
        }))

        for i = 1, amount_to_selected do
            local percent = 1.15 - (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            local selected = shuffled[i]

            -- first flip each card
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    selected:flip()
                    play_sound("card1", percent)
                    selected:juice_up(0.3, 0.3)
                    return true
                end,
            }))
        end
        delay(0.2)

        for i = 1, amount_to_selected do
            local selected = shuffled[i]

            -- change the ability while it's "face-down"
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.1,
                func = function()
                    selected:set_ability("m_wager_stained")
                    return true
                end,
            }))
        end

        for i = 1, amount_to_selected do
            local percent = 0.85 + (i - 0.999) / (#G.hand.highlighted - 0.998) * 0.3
            local selected = shuffled[i]

            -- Flip back to show the new ability
            G.E_MANAGER:add_event(Event({
                trigger = "after",
                delay = 0.15,
                func = function()
                    selected:flip()
                    play_sound('tarot2', percent, 0.6)
                    selected:juice_up(0.3, 0.3)
                    return true
                end,
            }))
        end

        -- Unhighlight all afterwards
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.2,
            func = function()
                G.hand:unhighlight_all()
                return true
            end,
        }))
        delay(0.5)
    end,

    can_use_addons = function(card)
        return #G.hand.highlighted <= card.ability.extra.maxAmount and #G.hand.highlighted >= 1
    end
})

-- Slots gamble card (Cryptid version)
if (SMODS.Mods["Cryptid"] or {}).can_load then
    create_gamble_card({
        key = 'slots',
        name = 'Slots',
        text = {
            "After {C:attention}#2#{} rounds",
            "Add {C:dark_edition}foil{}, {C:dark_edition}holographic{},",
            "{C:dark_edition}polychrome{}, or {C:dark_edition}Mosaic{}",
            "effect to a random joker",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
        },
        pos = { x = 3, y = 0 },
        config = {
            roundCount = 0,
            maxroundCount = 2,
        },
        info1 = 'e_foil',
        info2 = 'e_holo',
        info3 = 'e_polychrome',
        info4 = 'e_cry_mosaic',
        loc_vars = {},
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
                        local edition = poll_edition('wager_slots', nil, true, true,
                            { 'e_polychrome', 'e_holo', 'e_foil', 'e_cry_mosaic' })
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
else -- Normal slots version
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
            maxroundCount = 2,
        },
        info1 = 'e_foil',
        info2 = 'e_holo',
        info3 = 'e_polychrome',
        loc_vars = {},
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
                        local edition = poll_edition('wager_slots', nil, true, true,
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
end

-- Black Jack gamble card
create_gamble_card_ver2({
    key = 'blackJack',
    name = 'Blackjack',
    text = {
        "{C:attention}#2#{} random cards in your hand",
        "permanently gain {C:chips}+#5#{} Chips",
        "{C:green}#1# in #4#{} chance to affect {C:attention}#3#{}"
    },
    pos = { x = 5, y = 0 },
    config = {
        smallUpgrade = 3,
        bigUpgrade = 5,
        bigUpgradeOdds = 3,
        chipsAmount = 20,
    },
    loc_vars = { 'smallUpgrade', 'bigUpgrade', 'bigUpgradeOdds', 'chipsAmount' },
    effect = function(card)
        local upgraded_cards = {}
        local temp_hand = {}

        for _, playing_card in ipairs(G.hand.cards) do
            temp_hand[#temp_hand + 1] = playing_card
        end

        table.sort(temp_hand,
            function(a, b)
                return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card
            end
        )

        pseudoshuffle(temp_hand, math.random(1000))

        if pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.bigUpgradeOdds then
            play_sound("wager_gambleWin")
            G.GAME.pool_flags.gambleWin = true
            for i = 1, card.ability.extra.bigUpgrade do
                upgraded_cards[#upgraded_cards + 1] = temp_hand[i]
            end
        else
            for i = 1, card.ability.extra.smallUpgrade do
                upgraded_cards[#upgraded_cards + 1] = temp_hand[i]
            end
        end

        for _, c in ipairs(upgraded_cards) do
            c.ability.perma_bonus = (c.ability.perma_bonus or 1) + card.ability.extra.chipsAmount
        end

         G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                -- Make each upgraded card do a little bounce
                for _, c in ipairs(upgraded_cards) do
                    if c.juice_up then
                        c:juice_up(0.2, 0.4)
                    end
                end
                return true
            end
        }))
    end,

    can_use_addons = function(card)
        return G.hand and #G.hand.cards > 0
    end
})

-- Orbit Pool/Orbital Pool gamble card
create_gamble_card({
    key = 'orbitalPool',
    name = 'Orbital Pool',
    text = {
        "After {C:attention}#2#{} round",
        "gain {C:attention}2{} {C:planet}Planet{} cards for",
        "last played hand{C:inactive} [#5#]{}",
        "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
    },
    pos = { x = 4, y = 0 },
    config = {
        roundCount = 0,
        maxroundCount = 1,
        maxAmount = 3,
        currentHand = 'None',
        currentPlanet = '',
    },
    loc_vars = { 'maxAmount', 'currentHand', 'currentPlanet' },
    effect = function(card)
        for i = 1, math.min(2, G.consumeables.config.card_limit - #G.consumeables.cards) do
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    if G.consumeables.config.card_limit > #G.consumeables.cards then
                        play_sound('timpani')
                        SMODS.add_card({ key = card.ability.extra.currentPlanet })
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end
        delay(0.6)
    end,

    calculateEffect = function(card, context)
        if context.before and context.main_eval then
            G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
            G.E_MANAGER:add_event(Event({
                trigger = 'before',
                delay = 0.0,
                func = function()
                    if G.GAME.last_hand_played then
                        local _planet = nil
                        for k, v in pairs(G.P_CENTER_POOLS.Planet) do
                            if v.config.hand_type == G.GAME.last_hand_played then
                                card.ability.extra.currentHand = v.config.hand_type
                                _planet = v.key
                                card.ability.extra.currentPlanet = _planet
                            end
                        end
                    end
                    return true
                end
            }))
        end
    end,

    can_use_addons = function(card)
        return card.ability.extra.currentPlanet
    end
})

-- craps gamble card
create_gamble_card_ver2({ 
    key = 'craps',
    name = 'Craps',
    text = {
        "{C:attention}#2#{} random cards in your hand",
        "permanently gain {C:mult}+#5#{} Mult",
        "{C:green}#1# in #4#{} chance to affect {C:attention}#3#{}"
    },
    pos = { x = 6, y = 0 },
    config = {
        smallUpgrade = 3,
        bigUpgrade = 5,
        bigUpgradeOdds = 3,
        multAmount = 2,
    },
    loc_vars = { 'smallUpgrade', 'bigUpgrade', 'bigUpgradeOdds', 'multAmount' },
    effect = function(card)
        local upgraded_cards = {}
        local temp_hand = {}

        for _, playing_card in ipairs(G.hand.cards) do
            temp_hand[#temp_hand + 1] = playing_card
        end

        table.sort(temp_hand,
            function(a, b)
                return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card
            end
        )

        pseudoshuffle(temp_hand, math.random(1000))

        if pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.bigUpgradeOdds then
            play_sound("wager_gambleWin")
            G.GAME.pool_flags.gambleWin = true
            for i = 1, card.ability.extra.bigUpgrade do
                upgraded_cards[#upgraded_cards + 1] = temp_hand[i]
            end
        else
            for i = 1, card.ability.extra.smallUpgrade do
                upgraded_cards[#upgraded_cards + 1] = temp_hand[i]
            end
        end

        for _, c in ipairs(upgraded_cards) do
            c.ability.perma_mult = (c.ability.perma_mult or 1) + card.ability.extra.multAmount
        end

         G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                play_sound('tarot1')
                card:juice_up(0.3, 0.5)
                -- Make each upgraded card do a little bounce
                for _, c in ipairs(upgraded_cards) do
                    if c.juice_up then
                        c:juice_up(0.2, 0.4)
                    end
                end
                return true
            end
        }))
    end,

    can_use_addons = function(card)
        return G.hand and #G.hand.cards > 0
    end
})

-- parlay gamble card
SMODS.Consumable {
    key = 'parlay',
    loc_txt = {
        name = 'Parlay',
        text = {
            "{C:green}#1# in #2#{} chance for {C:attention}selected{} joker",
            "to get a {V:1}investment{} sticker",
            "else get a {C:gold}rental{} sticker"
        },
    },
    pos = { x = 5, y = 1 },
    atlas = 'consumables',
    set = 'Gamble',
    cost = 4,
    pools = {},

    config = { extra = {
        odds = 6
        },     
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = { key = "wager_investment", set = "Other" }
        info_queue[#info_queue+1] = { key = "rental", set = "Other", vars = {G.GAME.rental_rate or 1} }
        probabilities = (G.GAME.probabilities.normal or 1) + 3

        return { vars = {  
                probabilities, card.ability.extra.odds, colours = { HEX('459373') }
        } }
    end,

    can_use = function(self, card)
        return #G.jokers.highlighted == 1
    end,

    use = function(self, card, area)
        local joker = G.jokers.highlighted[1]
        if pseudorandom('gamble') < probabilities / card.ability.extra.odds then
            play_sound("wager_gambleMiddleWin")
            G.GAME.pool_flags.gambleWin = true

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    joker:add_sticker("wager_investment", true)
                    joker:juice_up(0.3, 0.5)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        else
            G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.4,
            func = function()
                joker:add_sticker("rental", true)
                joker:juice_up(0.3, 0.5)
                card:juice_up(0.3, 0.5)
                return true
            end
        }))
        end
         -- Unhighlight all afterwards
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.5,
            func = function()
                G.jokers:unhighlight_all()
                return true
            end,
        }))
    end
}

-- hi-lo gamble card
SMODS.Consumable {
    key = 'hi-lo',
    loc_txt = {
        name = 'Hi-Lo',
        text = {
            "{C:attention}Selected{} joker gets {V:1}Ethernal{}",
            "sticker {C:green}#1# in #2#{} chance to",
            "also get {V:2}Guardian{} sticker",
        },
    },
    pos = { x = 4, y = 1 },
    atlas = 'consumables',
    set = 'Gamble',
    cost = 4,
    pools = {},

    config = { extra = {
        odds = 2
        },     
    },

    loc_vars = function(self, info_queue, card)
        info_queue[#info_queue+1] = { key = "eternal", set = "Other" }
        info_queue[#info_queue+1] = { key = "wager_guardian", set = "Other" }

        return { vars = {  
                (G.GAME.probabilities.normal or 1), card.ability.extra.odds, colours = { HEX('c75985'), HEX('cc4846') }
        } }
    end,

    can_use = function(self, card)
        return #G.jokers.highlighted == 1
    end,

    use = function(self, card, area)
        local joker = G.jokers.highlighted[1]
        if pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.odds then
            play_sound("wager_gambleSmallWin")
            G.GAME.pool_flags.gambleWin = true

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    joker:add_sticker("eternal", true)
                    joker:add_sticker("wager_guardian", true)
                    joker:juice_up(0.3, 0.5)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        else
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.4,
                func = function()
                    joker:add_sticker("eternal", true)
                    joker:juice_up(0.3, 0.5)
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
            -- Unhighlight all afterwards
        G.E_MANAGER:add_event(Event({
            trigger = "after",
            delay = 0.5,
            func = function()
                G.jokers:unhighlight_all()
                return true
            end,
        }))
    end
}

-- lammer gamble card
create_gamble_card({
    key = 'lammer',
    name = 'Lammer',
    text = {
        "After {C:attention}#2#{} rounds",
        "get a random {C:attention}tag{}",
        "{C:green}#3# in #4#{} to get 2 {C:attention}tags{}",
        "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive}/#2#){}"
    },
    pos = { x = 6, y = 1 },
    config = {
        roundCount = 0,
        maxroundCount = 1,
        odds = 4,
    },
    loc_vars = { 'odds'},
    effect = function(card)
        if pseudorandom('gamble') < G.GAME.probabilities.normal / card.ability.extra.odds then
            play_sound("wager_gambleSmallWin")
            G.GAME.pool_flags.gambleWin = true
            for i = 1, 2 do
                local tag_pool = get_current_pool('Tag')
                local selected_tag = pseudorandom_element(tag_pool, pseudoseed('ortalab_hoarder'))
                local it = 1
                while selected_tag == 'UNAVAILABLE' do
                    it = it + 1
                    selected_tag = pseudorandom_element(tag_pool, pseudoseed('ortalab_hoarder_resample'..it))
                end
                add_tag(Tag(selected_tag, false, 'Small'))
            end
        else
            local tag_pool = get_current_pool('Tag')
            local selected_tag = pseudorandom_element(tag_pool, pseudoseed('ortalab_hoarder'))
            local it = 1
            while selected_tag == 'UNAVAILABLE' do
                it = it + 1
                selected_tag = pseudorandom_element(tag_pool, pseudoseed('ortalab_hoarder_resample'..it))
            end
            add_tag(Tag(selected_tag, false, 'Small'))
        end
    end,
    can_use_addons = function(card)
        return true
    end
})

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
-- gamble seal/Martingale
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
            extra = 'wager_auburnSeal', },

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
						highlighted:set_seal("wager_auburnSeal")
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

-- jackpot
SMODS.Consumable {
    key = 'jackpot',
    loc_txt = {
        name = 'Jackpot',
        text = {
            "{C:legendary,E:1}Every card{} held in hand",
            "permanently gains",
            "{X:mult,C:white}X2{} Mult",
        }
    },
    atlas = 'consumables',
    set = 'Spectral',
    soul_set = 'Gamble',
    hidden = true,
    cost = 4,
    pools = {},

    pos = { x = 1, y = 1 },
    config = { extra = { x_mult = 1 } },

    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.x_mult } }
    end,

    use = function(self, card, area)
		for i, c in ipairs(G.hand.cards) do
            local percent = 0.85 + (i - 0.999) / (#G.hand.cards - 0.998) * 0.3
            c.ability.perma_x_mult = (c.ability.perma_x_mult or 1) + card.ability.extra.x_mult

            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.15,
                func = function()
                    play_sound("card1", percent)
                    c:juice_up(0.3, 0.3)
                    return true
                end,
            }))
        end
    end,

    can_use = function(self, card)
        return G.hand and #G.hand.cards > 0
    end,
}