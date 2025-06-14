SMODS.Atlas {
    key = 'consumables',
    path = 'consumables.png',
    px = 70,
    py = 95
}

-- {gamble cards}
-- gamble type
SMODS.ConsumableType {
	object_type = "ConsumableType",
	key = "Gamble",
    loc_txt = {
            name = "Gamble",
            collection = "Gamble Cards",
        },
	primary_colour = G.C.SET.gamble2,
    secondary_colour = G.C.SET.gamble,
	collection_rows = { 4, 4 },
	shop_rate = 0.0,
	default = "c_finnmod_wager",
}

-- Wager gamble card
SMODS.Consumable {
    key = 'wager',
    loc_txt = {
        name = 'Wager',
        text = {
            "After {C:attention}#2# round{} it has a",
            "{C:green}#9#%{} chance to get {C:money,E:1}$#4#{}",
            "{C:green}#11#%{} chance to get {C:money}$#8#{}",
            "{C:green}#12#%{} chance to get {C:money}$#7#{}",
            "{C:green}#13#%{} chance to get {C:money}$#6#{}",
            "{C:green}#10#%{} chance to get {C:red}$#5#{}",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
        }
    },
    atlas = 'consumables',
    set = 'Gamble',
    cost = 4,

    pos = { x = 0, y = 0 },
    config = {
        extra = {
            roundCount = 0, 
            maxroundCount = 1,
            odds = 100,
            jackpotMoney = 100, lossMoney = -10, hugeWinMoney = 25, 
            bigWinMoney = 15, smallWinMoney = 8,
            jackpot = 2,
            loss = 10,
            hugeWin = 15, 
            bigWin = 30,
            smallWin = 40,
            hasDone = false,
        }
    },

    check_for_unlock = function(self, args)
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.roundCount, 
                card.ability.extra.maxroundCount, 
                card.ability.extra.odds,
                card.ability.extra.jackpotMoney, card.ability.extra.lossMoney, card.ability.extra.hugeWinMoney, 
                card.ability.extra.bigWinMoney, card.ability.extra.smallWinMoney,
                card.ability.extra.jackpot,
                card.ability.extra.loss,
                card.ability.extra.hugeWin,
                card.ability.extra.bigWin,
                card.ability.extra.smallWin,
                card.ability.extra.hasDone
            }
        }
    end,

    calculate = function(self, card, context)
        if G.consumeables and G.consumeables.cards then
            if card.ability.extra.created_by_jackpot and not card.ability.extra.hasDone then
                card.ability.extra.maxroundCount = card.ability.extra.maxroundCount + 1
                card.ability.extra.hasDone = true
            end
        end

        if context.end_of_round and not context.repetition and context.game_over == false then
            card.ability.extra.roundCount = card.ability.extra.roundCount + 1

            if card.ability.extra.roundCount >= card.ability.extra.maxroundCount then
                local number = math.random(1, card.ability.extra.odds)
                local amount = 0

                if number <= card.ability.extra.jackpot then
                    amount = card.ability.extra.jackpotMoney
                elseif number <= card.ability.extra.jackpot + card.ability.extra.loss then
                    amount = card.ability.extra.lossMoney
                elseif number <= card.ability.extra.jackpot + card.ability.extra.loss + card.ability.extra.hugeWin then
                    amount = card.ability.extra.hugeWinMoney
                elseif number <= card.ability.extra.jackpot + card.ability.extra.loss + card.ability.extra.hugeWin + card.ability.extra.bigWin then
                    amount = card.ability.extra.bigWinMoney
                else
                    amount = card.ability.extra.smallWinMoney
                end
                G.E_MANAGER:add_event(Event({
                    ease_dollars(amount)
                }))
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
                return { message = "$" .. amount }
            end
            if card.ability.extra.roundCount < 2 then
                return { message = card.ability.extra.roundCount .. "/" .. card.ability.extra.maxroundCount}
            else
                return {  }
            end
        end
    end,

    can_use = function(self, card)
        if G.consumeables and G.consumeables.cards then
            -- Check if card is already in consumables
            for _, c in ipairs(G.consumeables.cards) do
                if c == card then
                    return false
                end
            end
            -- Check if there is room in consumables deck
            if #G.consumeables.cards >= G.consumeables.config.card_limit then
                return false
            end
        end
        return true
    end,


    use = function(self, card, area, copier)
        -- Create the new consumable card
        local new_card = create_card("Consumable", G.consumeables, nil, nil, true, true, "c_finnmod_wager")
        new_card:start_materialize()

        new_card:add_to_deck()
        G.consumeables:emplace(new_card)

        -- Remove the original consumable that was used
        G.E_MANAGER:add_event(Event({
            func = function()
                G.consumeables:remove_card(card)
                card:remove()
                return true
            end
        }))
    end
}

-- Roulette gamble card
if (SMODS.Mods["Cryptid"] or {}).can_load then -- cryptid version
    SMODS.Consumable {
        key = 'roulette',
        loc_txt = {
            name = 'Roulette',
            text = {
                "After {C:attention}#2# rounds{} it has a",
                "{C:green}#4#%{} chance to get {C:cry_exotic,E:1}exotic{}",
                "{C:green}#5#%{} chance to get {C:legendary,E:1}legendary{}",
                "{C:green}#6#%{} chance to get {C:cry_epic}epic{}",
                "{C:green}#7#%{} chance to get {C:rare}rare{}",
                "{C:green}#8#%{} chance to get {C:uncommon}uncommon{}",
                "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
            }
        },
        atlas = 'consumables',
        set = 'Gamble',
        cost = 4,
        pools = { },

        pos = { x = 1, y = 0 },
        config = {
            extra = {
                roundCount = 0,
                maxroundCount = 2, 
                odds = 100,
                exoticOdds = 2,
                legendaryOdds = 5,
                epicOdds = 20,
                rareOdds = 35,
                uncommenOdds = 40,
                hasDone = false
            }
        },

        check_for_unlock = function(self, args)
            unlock_card(self)
        end,

        loc_vars = function(self, info_queue, card)
            return {
                vars = {
                    card.ability.extra.roundCount, 
                    card.ability.extra.maxroundCount, 
                    card.ability.extra.odds,
                    card.ability.extra.exoticOdds,
                    card.ability.extra.legendaryOdds,
                    card.ability.extra.epicOdds,
                    card.ability.extra.rareOdds,
                    card.ability.extra.uncommenOdds,
                    card.ability.extra.hasDone
                }
            }
        end,

        calculate = function(self, card, context)
            if G.consumeables and G.consumeables.cards then
                if card.ability.extra.created_by_jackpot and not card.ability.extra.hasDone then
                    card.ability.extra.maxroundCount = card.ability.extra.maxroundCount + 1
                    card.ability.extra.hasDone = true
                end
            end

            if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
                card.ability.extra.roundCount = card.ability.extra.roundCount + 1

                if card.ability.extra.roundCount >= card.ability.extra.maxroundCount then
                    local number = math.random(card.ability.extra.odds)
                    if number <= card.ability.extra.exoticOdds then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1,
                            blockable = false,
                            func = function()
                                
                                -- Create and add the Joker card
                                local card = create_card("Joker", G.jokers, nil, "cry_exotic", nil, nil, nil)
					            card:add_to_deck()
                                card:start_materialize()
                                G.jokers:emplace(card)
                            return true
                            end,
                        }))
                    elseif number <= card.ability.extra.exoticOdds + card.ability.extra.legendaryOdds then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1,
                            blockable = false,
                            func = function()
                                
                                -- Create and add the Joker card
                                local new_card = create_card("Joker", G.jokers, true, nil, nil, nil)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                            return true
                            end,
                        }))
                    elseif number <= card.ability.extra.exoticOdds + card.ability.extra.legendaryOdds + card.ability.extra.epicOdds then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1,
                            blockable = false,
                            func = function()
                                
                                -- Create and add the Joker card
                                local new_card = create_card("Joker", G.jokers, nil, "cry_epic", nil, nil)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                            return true
                            end,
                        }))
                    elseif number <= card.ability.extra.exoticOdds + card.ability.extra.legendaryOdds + card.ability.extra.epicOdds + card.ability.extra.rareOdds then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1,
                            blockable = false,
                            func = function()
                                -- Create and add the Joker card
                                local new_card = create_card("Joker", G.jokers, nil, 1, nil, nil)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                            return true
                            end,
                        }))
                    else
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1, 
                            blockable = false,
                            func = function()
                                local new_card = create_card("Joker", G.jokers, nil, 0.8, nil, nil)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                            return true
                            end,
                        }))
                    end
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
                    return {  }
                end
                if card.ability.extra.roundCount < 2 then
                    return { message = card.ability.extra.roundCount .. "/" .. card.ability.extra.maxroundCount}
                else
                    return {  }
                end
            end
        end,

        can_use = function(self, card)
            if G.consumeables and G.consumeables.cards then
                -- Check if card is already in consumables
                for _, c in ipairs(G.consumeables.cards) do
                    if c == card then
                        return false
                    end
                end
                -- Check if there is room in consumables deck
                if #G.consumeables.cards >= G.consumeables.config.card_limit then
                    return false
                end
            end
            return true
        end,

        use = function(self, card, area, copier)
            -- Create the new consumable card
            local new_card = create_card("Consumable", G.consumeables, nil, nil, true, true, "c_finnmod_roulette")
            new_card:start_materialize()

            new_card:add_to_deck()
            G.consumeables:emplace(new_card)

            -- Remove the original consumable that was used
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.consumeables:remove_card(card)
                    card:remove()
                    return true
                end
            }))
        end
    }
else -- normal version
    SMODS.Consumable {
        key = 'roulette',
        loc_txt = {
            name = 'Roulette',
            text = {
                "After {C:attention}#2# rounds{} it has a",
                "{C:green}#4#%{} chance to get {C:legendary,E:1}legendary{}",
                "{C:green}#5#%{} chance to get {C:rare}rare{}",
                "{C:green}#6#%{} chance to get {C:uncommon}uncommon{}",
                "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
            }
        },
        atlas = 'consumables',
        set = 'Gamble',
        cost = 4,
        pools = { },

        pos = { x = 1, y = 0 },
        config = {
            extra = {
                roundCount = 0, 
                maxroundCount =2,
                odds = 100,
                legendaryOdds = 2,
                rareOdds = 35,
                uncommenOdds = 65,
                hasDone = false
            }
        },

        check_for_unlock = function(self, args)
            unlock_card(self)
        end,

        loc_vars = function(self, info_queue, card)
            return {
                vars = {
                    card.ability.extra.roundCount,
                    card.ability.extra.maxroundCount, 
                    card.ability.extra.odds,
                    card.ability.extra.legendaryOdds,
                    card.ability.extra.rareOdds,
                    card.ability.extra.uncommenOdds,
                    card.ability.extra.hasDone
                }
            }
        end,

        calculate = function(self, card, context)
            if G.consumeables and G.consumeables.cards then
                if card.ability.extra.created_by_jackpot and not card.ability.extra.hasDone then
                    card.ability.extra.maxroundCount = card.ability.extra.maxroundCount + 1
                    card.ability.extra.hasDone = true
                end
            end

            if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
                card.ability.extra.roundCount = card.ability.extra.roundCount + 1

                if card.ability.extra.roundCount >= card.ability.extra.maxroundCount then
                    local number = math.random(card.ability.extra.odds)
                    if number <= card.ability.extra.legendaryOdds then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1,
                            blockable = false,
                            func = function()
                                
                                -- Create and add the Joker card
                                local new_card = create_card("Joker", G.jokers, true, nil, nil, nil)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                            return true
                            end,
                        }))
                    elseif number <= card.ability.extra.legendaryOdds + card.ability.extra.rareOdds then
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1,
                            blockable = false,
                            func = function()
                                -- Create and add the Joker card
                                local new_card = create_card("Joker", G.jokers, nil, 1, nil, nil)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                            return true
                            end,
                        }))
                    else
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = 0.1, 
                            blockable = false,
                            func = function()
                                local new_card = create_card("Joker", G.jokers, nil, 0.8, nil, nil)
                                new_card:add_to_deck()
                                G.jokers:emplace(new_card)
                            return true
                            end,
                        }))
                    end
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
                    return {  }
                end
                if card.ability.extra.roundCount < 2 then
                    return { message = card.ability.extra.roundCount .. "/" .. card.ability.extra.maxroundCount}
                else
                    return {  }
                end
            end
        end,

        can_use = function(self, card)
            if G.consumeables and G.consumeables.cards then
                -- Check if card is already in consumables
                for _, c in ipairs(G.consumeables.cards) do
                    if c == card then
                        return false
                    end
                end
                -- Check if there is room in consumables deck
                if #G.consumeables.cards >= G.consumeables.config.card_limit then
                    return false
                end
            end
            return true
        end,

        use = function(self, card, area, copier)
            -- Create the new consumable card
            local new_card = create_card("Consumable", G.consumeables, nil, nil, true, true, "c_finnmod_roulette")
            new_card:start_materialize()

            new_card:add_to_deck()
            G.consumeables:emplace(new_card)

            -- Remove the original consumable that was used
            G.E_MANAGER:add_event(Event({
                func = function()
                    G.consumeables:remove_card(card)
                    card:remove()
                    return true
                end
            }))
        end
    }
end

-- Cocktail gamble card
SMODS.Consumable {
    key = 'cocktail',
    loc_txt = {
        name = 'Cocktail',
        text = {
            "After {C:attention}#2# rounds{} it has a",
            "{C:green}#4#%{} chance to get {C:spectral}spectral card{}",
            "{C:green}#5#%{} chance to get {C:tarot}tarot card{}",
            "{C:green}#6#%{} chance to get {C:planet}planet card{}",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
        }
    },
    atlas = 'consumables',
    set = 'Gamble',
    cost = 4,
    pools = { },

    pos = { x = 2, y = 0 },
    config = {
        extra = {
            roundCount = 0,
            maxroundCount = 1,
            odds = 100,
            spectralOdds = 25,
            tarotOdds = 35,
            planetOdds = 40,
            hasDone = false
        }
    },

    check_for_unlock = function(self, args)
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.roundCount,
                card.ability.extra.maxroundCount, 
                card.ability.extra.odds,
                card.ability.extra.spectralOdds,
                card.ability.extra.tarotOdds,
                card.ability.extra.planetOdds,
                card.ability.extra.hasDone
            }
        }
    end,

    calculate = function(self, card, context)
        if G.consumeables and G.consumeables.cards then
            if card.ability.extra.created_by_jackpot and not card.ability.extra.hasDone then
                card.ability.extra.maxroundCount = card.ability.extra.maxroundCount + 1
                card.ability.extra.hasDone = true
            end
        end

        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            card.ability.extra.roundCount = card.ability.extra.roundCount + 1

            if card.ability.extra.roundCount >= card.ability.extra.maxroundCount then
                local number = math.random(card.ability.extra.odds)
                if number <= card.ability.extra.spectralOdds then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.6,
                        blockable = false,
                        func = function()
                            
                            -- Create and add the Joker card
                            local new_card = create_card("Spectral", G.consumeables, nil, nil, true, true, nil)
                            new_card:add_to_deck()
                            G.consumeables:emplace(new_card)
                        return true
                        end,
                    }))
                elseif number <= card.ability.extra.spectralOdds + card.ability.extra.tarotOdds then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.6,
                        blockable = false,
                        func = function()
                            -- Create and add the Joker card
                            local new_card = create_card("Tarot", G.consumeables, nil, nil, true, true, nil)
                            G.consumeables:emplace(new_card)
                        return true
                        end,
                    }))
                else
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.6,
                        blockable = false,
                        func = function()
                            local new_card = create_card("Planet", G.consumeables, nil, nil, true, true, nil)
                            G.consumeables:emplace(new_card)
                        return true
                        end,
                    }))
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        -- This part destroys the card.
                        G.E_MANAGER:add_event(Event({
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
                return {  }
            end
            if card.ability.extra.roundCount < 2 then
                return { message = card.ability.extra.roundCount .. "/" .. card.ability.extra.maxroundCount}
            else
                return {  }
            end
        end
    end,

    can_use = function(self, card)
        if G.consumeables and G.consumeables.cards then
            -- Check if card is already in consumables
            for _, c in ipairs(G.consumeables.cards) do
                if c == card then
                    return false
                end
            end
            -- Check if there is room in consumables deck
            if #G.consumeables.cards >= G.consumeables.config.card_limit then
                return false
            end
        end
        return true
    end,

    use = function(self, card, area, copier)
        -- Create the new consumable card
        local new_card = create_card("Consumable", G.consumeables, nil, nil, true, true, "c_finnmod_cocktail")
        new_card:start_materialize()

        new_card:add_to_deck()
        G.consumeables:emplace(new_card)

        -- Remove the original consumable that was used
        G.E_MANAGER:add_event(Event({
            func = function()
                G.consumeables:remove_card(card)
                card:remove()
                return true
            end
        }))
    end
}

-- edition gamble card
SMODS.Consumable {
    key = 'edition',
    loc_txt = {
        name = 'Edition',
        text = {
            "After {C:attention}#2# rounds{} it has a",
            "{C:green}#4#%{} chance to give a joker {C:dark_edition,E:1}negetive{}",
            "{C:green}#5#%{} chance to give a joker {C:enhanced}polychrome{}",
            "{C:green}#6#%{} chance to give a joker {C:rare}holographic{}",
            "{C:green}#7#%{} chance to give a joker {C:spectral}foil{}",
            "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
        }
    },
    atlas = 'consumables',
    set = 'Gamble',
    cost = 4,
    pools = { },

    pos = { x = 3, y = 0 },
    config = {
        extra = {
            roundCount = 0,
            maxroundCount = 3,
            odds = 100,
            negetiveOdds = 5,
            polychromeOdds = 10,
            holographicOdds = 35,
            foilOdds = 40,
            hasDone = false
        }
    },

    check_for_unlock = function(self, args)
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.roundCount,
                card.ability.extra.maxroundCount, 
                card.ability.extra.odds,
                card.ability.extra.negetiveOdds,
                card.ability.extra.polychromeOdds,
                card.ability.extra.holographicOdds,
                card.ability.extra.foilOdds,
                card.ability.extra.hasDone
            }
        }
    end,

    calculate = function(self, card, context)
        if G.consumeables and G.consumeables.cards then
            if card.ability.extra.created_by_jackpot and not card.ability.extra.hasDone then
                card.ability.extra.maxroundCount = card.ability.extra.maxroundCount + 1
                card.ability.extra.hasDone = true
            end
        end

        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            card.ability.extra.roundCount = card.ability.extra.roundCount + 1

            if card.ability.extra.roundCount >= card.ability.extra.maxroundCount then
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
                    if number <= card.ability.extra.negetiveOdds then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local target = pseudorandom_element(eligibleJokers, pseudoseed("finnmod_edition"))
                                target:set_edition({ negative = true }, true)
                                target:juice_up(0.4, 0.6) -- Optional: visual feedback
                                return true
                            end
                        }))
                    elseif number <= card.ability.extra.negetiveOdds + card.ability.extra.polychromeOdds then
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local target = pseudorandom_element(eligibleJokers, pseudoseed("finnmod_edition"))
                                target:set_edition({ polychrome = true }, true)
                                target:juice_up(0.4, 0.6) -- Optional: visual feedback
                                return true
                            end
                        }))
                    elseif number <= card.ability.extra.negetiveOdds + card.ability.extra.polychromeOdds + card.ability.extra.holographicOdds then
                    G.E_MANAGER:add_event(Event({
                        func = function()
                            local target = pseudorandom_element(eligibleJokers, pseudoseed("finnmod_edition"))
                            target:set_edition({ holo = true }, true)
                            target:juice_up(0.4, 0.6) -- Optional: visual feedback
                            return true
                        end
                    }))
                    else
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                local target = pseudorandom_element(eligibleJokers, pseudoseed("finnmod_edition"))
                                target:set_edition({ foil = true }, true)
                                target:juice_up(0.4, 0.6) -- Optional: visual feedback
                                return true
                            end
                        }))
                    end
                end
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        -- This part destroys the card.
                        G.E_MANAGER:add_event(Event({
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
                return {  }
            end
            if card.ability.extra.roundCount < 2 then
                return { message = card.ability.extra.roundCount .. "/" .. card.ability.extra.maxroundCount}
            else
                return {  }
            end
        end
    end,

    can_use = function(self, card)
        if G.consumeables and G.consumeables.cards then
            -- Check if card is already in consumables
            for _, c in ipairs(G.consumeables.cards) do
                if c == card then
                    return false
                end
            end
            -- Check if there is room in consumables deck
            if #G.consumeables.cards >= G.consumeables.config.card_limit then
                return false
            end
        end
        return true
    end,

    use = function(self, card, area, copier)
        -- Create the new consumable card
        local new_card = create_card("Consumable", G.consumeables, nil, nil, true, true, "c_finnmod_edition")
        new_card:start_materialize()

        new_card:add_to_deck()
        G.consumeables:emplace(new_card)

        -- Remove the original consumable that was used
        G.E_MANAGER:add_event(Event({
            func = function()
                G.consumeables:remove_card(card)
                card:remove()
                return true
            end
        }))
    end
}

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