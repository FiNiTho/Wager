-- Gamble
SMODS.Atlas {
    key = 'gamble',
    path = 'gamble.png',
    px = 71,
    py = 95
}
if (SMODS.Mods["Cryptid"] or {}).can_load then -- cryptid version
    SMODS.Joker {
        key = 'gamble',
        loc_txt = {
            name = 'Gamble',
            text = {
                "After {C:attention}#2# rounds{} it has a",
                "{C:green}#8#%{} chance to get {C:uncommon}uncommon{}",
                "{C:green}#7#%{} chance to get {C:rare}rare{}",
                "{C:green}#6#%{} chance to get {C:cry_epic}epic{}",
                "{C:green}#5#%{} chance to get {C:legendary,E:1}legendary{}",
                "{C:green}#4#%{} chance to get {C:cry_exotic,E:1}exotic{}",
                "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
            }
        },
        atlas = 'gamble',
        rarity = 2,
        cost = 6,
        pools = { ["FinnmodAddition"] = true },
        unlocked = true,
        discovered = false,
        blueprint_compact = true,
        eternal_compact = false,
        preishable_compact = false,

        pos = { x = 0, y = 0 },
        config = {
            extra = {
                roundCount = 0,
                maxroundCount = 2, 
                odds = 100,
                exoticOdds = 2,
                legendaryOdds = 5,
                epicOdds = 20,
                rareOdds = 35,
                uncommenOdds = 40
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
                    card.ability.extra.uncommenOdds
                }
            }
        end,

        calculate = function(self, card, context)
            if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
                card.ability.extra.roundCount = card.ability.extra.roundCount + 1

                if card.ability.extra.roundCount >= 2 then
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
                    elseif number <= card.ability.extra.legendaryOdds then
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
                    elseif number <= card.ability.extra.legendaryOdds then
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
                    elseif number <= card.ability.extra.rareOdds then
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
                    return {  }
                end
                if card.ability.extra.roundCount < 2 then
                    return { message = card.ability.extra.roundCount .. "/" .. card.ability.extra.maxroundCount}
                else
                    return {  }
                end
            end
        end
    }
else -- normal version
    SMODS.Joker {
        key = 'gamble',
        loc_txt = {
            name = 'Gamble',
            text = {
                "After {C:attention}#2# rounds{} it has a",
                "{C:green}#6#%{} chance to get {C:uncommon}uncommon{}",
                "{C:green}#5#%{} chance to get {C:rare}rare{}",
                "{C:green}#4#%{} chance to get {C:legendary,E:1}legendary{}",
                "{C:inactive}(Currently {}{C:attention}#1#{}{C:inactive} of #2#){}"
            }
        },
        atlas = 'gamble',
        rarity = 2,
        cost = 6,
        pools = { ["FinnmodAddition"] = true },
        unlocked = true,
        discovered = false,
        blueprint_compact = true,
        eternal_compact = false,
        preishable_compact = false,

        pos = { x = 0, y = 0 },
        config = {
            extra = {
                roundCount = 0, 
                maxroundCount =2,
                odds = 100,
                legendaryOdds = 2,
                rareOdds = 35,
                uncommenOdds = 65
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
                    card.ability.extra.uncommenOdds
                }
            }
        end,

        calculate = function(self, card, context)
            if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
                card.ability.extra.roundCount = card.ability.extra.roundCount + 1

                if card.ability.extra.roundCount >= 2 then
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
                    elseif number <= card.ability.extra.rareOdds then
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
                    return {  }
                end
                if card.ability.extra.roundCount < 2 then
                    return { message = card.ability.extra.roundCount .. "/" .. card.ability.extra.maxroundCount}
                else
                    return {  }
                end
            end
        end
    }
end

-- GambleMoney
SMODS.Atlas {
    key = 'wager',
    path = 'wager.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'wager',
    loc_txt = {
        name = 'Wager',
        text = {
            "After {C:attention}#1# round{} it has a",
            "{C:green}#8#%{} chance to get {C:money,E:1}$#3#{}",
            "{C:green}#10#%{} chance to get {C:money}$#5#{}",
            "{C:green}#11#%{} chance to get {C:money}$#6#{}",
            "{C:green}#12#%{} chance to get {C:money}$#7#{}",
            "{C:green}#9#%{} chance to get {C:red}$#4#{}",
        }
    },
    atlas = 'wager',
    rarity = 1,
    cost = 5,
    pools = { ["FinnmodAddition"] = true },
    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = { x = 0, y = 0 },
    config = {
        extra = {
            roundCount = 1, 
            odds = 100,
            jackpotMoney = 100, lossMoney = -10, hugeWinMoney = 25, 
            bigWinMoney = 15, smallWinMoney = 8,
            jackpot = 2,
            loss = 10,
            hugeWin = 15, 
            bigWin = 30,
            smallWin = 40,
        }
    },

    check_for_unlock = function(self, args)
        unlock_card(self)
    end,

    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.roundCount, 
                card.ability.extra.odds,
                card.ability.extra.jackpotMoney, card.ability.extra.lossMoney, card.ability.extra.hugeWinMoney, 
                card.ability.extra.bigWinMoney, card.ability.extra.smallWinMoney,
                card.ability.extra.jackpot,
                card.ability.extra.loss,
                card.ability.extra.hugeWin,
                card.ability.extra.bigWin,
                card.ability.extra.smallWin
            }
        }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
            card.ability.extra.roundCount = card.ability.extra.roundCount - 1

            if card.ability.extra.roundCount <= 0 then
                local number = math.random(1, card.ability.extra.odds)
                local amount = 0

                if number <= card.ability.extra.jackpot then
                    amount = card.ability.extra.jackpotMoney
                elseif number <= card.ability.extra.loss then
                    amount = card.ability.extra.lossMoney
                elseif number <= card.ability.extra.hugeWin then
                    amount = card.ability.extra.hugeWinMoney
                elseif number <= card.ability.extra.bigWin then
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
        end
    end
}

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
    pools = {["FinnmodAddition"] = true},

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

-- Pou joker
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
    pools = {["FinnmodAddition"] = true},

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

-- freaky joker
SMODS.Atlas {
    key = 'freaky',
    path = 'pou.png',
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = 'freaky',
    loc_txt = {
        name = 'Freaky',
        text = {
            "RAAAAAAGH"
        }
    },
    atlas = 'freaky',
    rarity = 4,
    pools = { ["FinnmodAddition"] = true },

    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = { x = 0, y = 0 },
    config = {
        extra = {
            increase = 1.2
        }
    },
    loc_vars = function(self, info_queue, card)
        return {vars = { card.ability.extra.Xchips, card.ability.extra.hunger, card.ability.extra.maxHunger}}
    end,

    calculate = function(self, card, context)
        
    end
}