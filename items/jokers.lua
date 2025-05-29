-- Gamble
SMODS.Atlas {
    key = 'gamble',
    path = 'gamble.png',
    px = 71,
    py = 95
}

SMODS.Joker {
    key = 'gamble',
    loc_txt = {
        name = 'Gamble',
        text = {
            "After {C:attention}#1# rounds{} it has a",
            "{C:attention}#6#% chance{} to get {C:green}uncommen{}",
            "and a {C:attention}#5#% chance{} to get {C:red}rare{}",
            "and a {C:attention}#4#% chance{} to get {C:purple}legendary{}",
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
            roundCount = 2, 
            odds = 100,
            legendaryOdds = 2,
            rareOdds = 23,
            uncommenOdds = 75
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
                card.ability.extra.legendaryOdds,
                card.ability.extra.rareOdds,
                card.ability.extra.uncommenOdds
            }
        }
    end,

    calculate = function(self, card, context)
    if context.end_of_round and not context.repetition and context.game_over == false and not context.blueprint then
        card.ability.extra.roundCount = card.ability.extra.roundCount - 1

        if card.ability.extra.roundCount <= 0 then
            -- Remove the card
            G.E_MANAGER:add_event(Event({
                func = function()
                    play_sound('tarot1')
                    card.T.r = -0.2
                    card:juice_up(0.3, 0.4)
                    card.states.drag.is = true
                    card.children.center.pinch.x = true

                    -- Schedule actual removal after 0.3 seconds delay
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.3,
                        blockable = false,
                        func = function()
                            G.jokers:remove_card(card)
                            card:remove()
                            card = nil
                            return true
                        end
                    }))
                    return true
                end,
            }))

            -- Get a new card after the fact
            local number = math.random(card.ability.extra.odds)
            if number <= card.ability.extra.legendaryOdds then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,  -- slightly after removal to avoid overlap
                    blockable = false,
                    func = function()
                        if G.consumeables then
                        -- Define your list of possible Joker IDs
                        local legendary_joker_ids = {
                            "j_caino",
                            "j_chicot",
                            "j_perkeo",
                            "j_triboulet",
                            "j_yorick",
                        }

                        local random_id = legendary_joker_ids[math.random(#legendary_joker_ids)]

                        -- Create and add the Joker card
                        local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil, random_id)
                        new_card:add_to_deck()
                        G.jokers:emplace(new_card)
                    end
                    return true
                    end,
                }))
            elseif number <= card.ability.extra.rareOdds then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,  -- slightly after removal to avoid overlap
                    blockable = false,
                    func = function()
                        if G.consumeables then
                        -- Define your list of possible Joker IDs
                        local rare_joker_ids = {
                            "j_ancient",
                            "j_baron",
                            "j_baseball",
                            "j_blueprint",
                            "j_brainstorm",
                            "j_burnt",
                            "j_campfire",
                            "j_dna",
                            "j_drivers_license",
                            "j_duo",
                            "j_family",
                            "j_hit_the_road",
                            "j_obelisk",
                            "j_order",
                            "j_stuntman",
                            "j_tribe",
                            "j_trio",
                            "j_vagabond",
                            "j_wee", 
                        }

                        -- Filter only the unlocked Jokers
                        local rare_unlocked_jokers = {}
                        for _, id in ipairs(rare_joker_ids) do
                            if G.P_CENTERS[id] and G.P_CENTERS[id].unlocked then
                                table.insert(rare_unlocked_jokers, id)
                            end
                        end

                        -- Only proceed if we have any unlocked Jokers
                        if #rare_unlocked_jokers > 0 then
                            local random_id = rare_unlocked_jokers[math.random(#rare_unlocked_jokers)]

                            -- Create and add the Joker card
                            local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil, random_id)
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        else
                            local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_joker")
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        end
                    end
                    return true
                    end,
                }))
            else
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.5,  -- slightly after removal to avoid overlap
                    blockable = false,
                    func = function()
                        if G.consumeables then
                        -- Define your list of possible Joker IDs
                        local uncommen_joker_ids = {
                            "j_acrobat",
                            "j_astronomer",
                            "j_blackboard",
                            "j_bloodstone",
                            "j_bootstraps",
                            "j_bull",
                            "j_burglar",
                            "j_card_sharp",
                            "j_cartomancer",
                            "j_castle",
                            "j_certificate",
                            "j_cloud_9",
                            "j_constellation",
                            "j_diet_cola",
                            "j_dusk",
                            "j_erosion",
                            "j_fibonacci",
                            "j_flash",
                            "j_flower_pot",
                            "j_gift",
                            "j_glass",
                            "j_hack",
                            "j_hiker",
                            "j_hologram",
                            "j_idol",
                            "j_loyalty_card",
                            "j_luchador",
                            "j_lucky_cat",
                            "j_madness",
                            "j_marble",
                            "j_matador",
                            "j_merry_andy",
                            "j_midas_mask",
                            "j_mime",
                            "j_mr_bones",
                            "j_onyx_agate",
                            "j_oops",
                            "j_pareidolia",
                            "j_ramen",
                            "j_ring_master",
                            "j_rocket",
                            "j_rough_gem",
                            "j_seance",
                            "j_seeing_double",
                            "j_selzer",
                            "j_shortcut",
                            "j_smeared",
                            "j_sock_and_buskin",
                            "j_space",
                            "j_steel_joker",
                            "j_stencil",
                            "j_stone",
                            "j_throwback",
                            "j_to_the_moon",
                            "j_trading",
                            "j_trousers",
                            "j_troubadour",
                            "j_turtle_bean",
                            "j_vampire",
                            "j_sixth_sense",
                            "j_ceremonial",

                            "j_finnmod_dog",
                        }

                        -- Filter only the unlocked Jokers
                        local uncommen_unlocked_jokers = {}
                        for _, id in ipairs(uncommen_joker_ids) do
                            if G.P_CENTERS[id] and G.P_CENTERS[id].unlocked then
                                table.insert(uncommen_unlocked_jokers, id)
                            end
                        end

                        -- Only proceed if we have any unlocked Jokers
                        if #uncommen_unlocked_jokers > 0 then
                            local random_id = uncommen_unlocked_jokers[math.random(#uncommen_unlocked_jokers)]

                            -- Create and add the Joker card
                            local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil, random_id)
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        else
                            local new_card = create_card("Joker", G.jokers, nil, nil, nil, nil, "j_joker")
                            new_card:add_to_deck()
                            G.jokers:emplace(new_card)
                        end
                    end
                    return true
                    end,
                }))
            end
        end
        return { message = "-1 round" }
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

-- Happy Pou joker
SMODS.Atlas {
    key = 'HappyPou',
    path = 'happyPou.png',
    px = 71,
    py = 95,
}

SMODS.Joker {
    key = 'HappyPou',
    loc_txt = {
        name = 'Happy Pou',
        text = { 'awww :)',
                "{X:mult,C:white}x#2#{} Mult",
                "if played hand",
                "contains a {C:attention}Flush{}",
                'Currently {X:mult,C:white}X#1#{} Mult' }
    },
    atlas = 'HappyPou',
    rarity = 1,
    cost = 5,
    pools = {["FinnmodAddition"] = true},

    unlocked = true,
    discovered = false,
    blueprint_compact = true,
    eternal_compact = false,
    preishable_compact = false,

    pos = {x = 0, y = 0},
    config = { extra = { Xmult = 1, gain = 2 }},

    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.Xmult, center.ability.extra.gain}}
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
                Xmult_mod = card.ability.extra.Xmult,
                message = 'X' .. card.ability.extra.Xmult,
                colour = G.C.MULT
            }
        end

        if context.before and next(context.poker_hands['Flush']) and not context.blueprint then
            card.ability.extra.Xmult = card.ability.extra.Xmult * card.ability.extra.gain
            return {
                message = 'Upgraded!',
                colour = G.C.MULT,
                card = card
            }
        end
    end,
}

-- -- Sad Pou jocker
-- SMODS.Atlas {
--     key = 'sadPou',
--     path = 'sadPou.png',
--     px = 71,
--     py = 95,
-- }

-- SMODS.Joker {
--     key = 'sadPou',
--     loc_txt = {
--         name = 'Sad Pou',
--         text = { 'awww :(',
--                 "{X:mult,C:white}x#2#{} Mult",
--                 "if played hand",
--                 "contains a {C:attention}Flush{}",
--                 'Currently {X:mult,C:white}X#1#{} Mult' }
--     },
--     atlas = 'sadPou',
--     rarity = 1,
--     cost = 4,
--     pools = {["FinnmodAddition"] = true},

--     unlocked = true,
--     discovered = false,
--     blueprint_compact = true,
--     eternal_compact = false,
--     preishable_compact = false,

--     pos = {x = 0, y = 0},
--     config = { extra = { Xmult = 1, gain = 2 }},

--     loc_vars = function(self, info_queue, center)
--         return {vars = {center.ability.extra.Xmult, center.ability.extra.gain}}
--     end,

--     check_for_unlock = function(self, args)
--         if args.type == 'test' then --not a real type, just a joke
--             unlock_card(self)
--         end
--         unlock_card(self) --unlocks the card if it isnt unlocked
--     end,

--     calculate = function(self, card, context)
--         if context.joker_main then
--             return {
--                 Xmult_mod = card.ability.extra.Xmult,
--                 message = 'X' .. card.ability.extra.Xmult,
--                 colour = G.C.MULT
--             }
--         end

--         if context.before and next(context.poker_hands['Flush']) and not context.blueprint then
--             card.ability.extra.Xmult = card.ability.extra.Xmult * card.ability.extra.gain
--             return {
--                 message = 'Upgraded!',
--                 colour = G.C.MULT,
--                 card = card
--             }
--         end
--     end,
-- }

-- -- Dog bones
-- SMODS.Atlas {
--     key = 'dogBones',
--     path = 'dogBones.png',
--     px = 71,
--     py = 95,
-- }

-- SMODS.Joker {
--     key = 'dogBones',
--     loc_txt = {
--         name = 'Dog Remains',
--         text = { 'arf',
--                 "{C:mult}+#1# {} extra Mult", }
--     },
--     -- This also searches G.GAME.pool_flags to see if dog went extinct. If so, enables the ability to show up in shop.
-- 	yes_pool_flag = 'dog_extinct',
--     atlas = 'dogBones',
--     rarity = 1,
--     cost = 5,
--     pools = {["FinnmodAddition"] = true},

--     unlocked = true,
--     discovered = false,
--     blueprint_compact = true,
--     eternal_compact = false,
--     preishable_compact = false,

--     pos = {x = 0, y = 0},
--     config = { extra = { odds = 10 } },

--     check_for_unlock = function(self, args)
--         if args.type == 'test' then
--             unlock_card(self)
--         end
--         unlock_card(self)
--     end,

--     loc_vars = function(self, info_queue, card)
-- 		return { vars = { card.ability.extra.odds } }
-- 	end,

--      calculate = function(self, card, context)
--         if context.individual and context.cardarea == G.play then
--             context.other_card.ability.perma_mult = context.other_card.ability.perma_mult or 0
--             context.other_card.ability.perma_mult = context.other_card.ability.perma_mult + card.ability.extra.odds
--             return {
--                 extra = { message = localize('k_upgrade_ex'), colour = G.C.MULT },
--                 card = card
--             }
--         end
--     end
-- }