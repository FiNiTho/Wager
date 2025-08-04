-- tags atlas
SMODS.Atlas {
    key = 'tags',
    path = 'tags.png',
    px = 34,
    py = 34,
}

-- Gamble Tag
SMODS.Tag {
    key = "gambleTag",
    loc_txt = {
        name = 'Gamble Tag',
        text = {
            "Gives a free",
            "{C:gamble}Mega Gamble Pack{}"
        }
    },
    atlas = 'tags',
    pos = { x = 0, y = 0 },
    loc_vars = function(self, info_queue, tag)
        info_queue[#info_queue + 1] = G.P_CENTERS.p_wager_gambleMega
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.GAMBLE, function()
                local booster = SMODS.create_card { key = 'p_wager_gambleMega', area = G.play }
                booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
                booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
                booster.T.w = G.CARD_W * 1.27
                booster.T.h = G.CARD_H * 1.27
                booster.cost = 0
                booster.from_tag = true
                G.FUNCS.use_card({ config = { ref_table = booster } })
                booster:start_materialize()
                G.CONTROLLER.locks[lock] = nil
                return true
            end)
            tag.triggered = true
            return true
        end
    end
}

-- Booster Tag
SMODS.Tag {
    key = "boosterTag",
    loc_txt = {
        name = 'Booster Tag',
        text = {
            "Next shop has {C:attention}1{} more",
            "{C:attention}booster{} pack",
        }
    },
    atlas = 'tags',
    pos = { x = 1, y = 0 },
    apply = function(self, tag, context)
        if context.type == "store_joker_create" then
            tag:yep("+", G.C.RED, function()
                G.GAME.modifiers.extra_boosters = (G.GAME.modifiers.extra_boosters or 0) + 1
                SMODS.add_booster_to_shop()
                G.GAME.modifiers.extra_boosters = (G.GAME.modifiers.extra_boosters or 0) - 1
                return true
			end)
            tag.triggered = true
        end
    end
}

-- food jokers
if (SMODS.Mods["Cryptid"] or {}).can_load then
    SMODS.Tag {
        key = "foodTag",
        loc_txt = {
            name = 'Food Tag',
            text = {
                "Create up to {C:attention}2{}",
                "{C:attention}Food{} Jokers",
                "{C:inactive}(Must have room){}"
            }
        },
        atlas = 'tags',
        pos = { x = 2, y = 0 },
        config = { spawn_jokers = 2 },
        loc_vars = function(self, info_queue, tag)
            return { vars = { tag.config.spawn_jokers } }
        end,
        apply = function(self, tag, context)
            if context.type == 'immediate' then
                local lock = tag.ID
                G.CONTROLLER.locks[lock] = true
                tag:yep('+', G.C.PURPLE, function()
                    for _ = 1, tag.config.spawn_jokers do
                        if G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
                            local card = create_card("Food", G.jokers, nil, nil, nil, nil, nil, "wager_foodTag")
                            card:add_to_deck()
                            G.jokers:emplace(card)
                        end
                    end
                    G.CONTROLLER.locks[lock] = nil
                    return true
                end)
                tag.triggered = true
                return true
            end
        end
    }
end