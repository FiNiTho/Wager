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
        info_queue[#info_queue + 1] = G.P_CENTERS.p_finnmod_gambleMega
    end,
    apply = function(self, tag, context)
        if context.type == 'new_blind_choice' then
            local lock = tag.ID
            G.CONTROLLER.locks[lock] = true
            tag:yep('+', G.C.GAMBLE, function()
                local booster = SMODS.create_card { key = 'p_finnmod_gambleMega', area = G.play }
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

-- -- Booster Tag
-- SMODS.Tag {
--     key = "boosterTag",
--     loc_txt = {
--         name = 'Booster Tag',
--         text = {
--             "Next shop has double the",
--             "{C:attention}booster{} packs",
--         }
--     },
--     atlas = 'tags',
--     pos = { x = 1, y = 0 },
--     loc_vars = function(self, info_queue, tag)
--         info_queue[#info_queue + 1] = G.P_CENTERS.p_finnmod_gambleMega
--     end,
--     apply = function(self, tag, context)
--         if context.type == 'new_blind_choice' then
--             local lock = tag.ID
--             G.CONTROLLER.locks[lock] = true
--             tag:yep('+', G.C.GAMBLE, function()
--                 local booster = SMODS.create_card { key = 'p_finnmod_gambleMega', area = G.play }
--                 booster.T.x = G.play.T.x + G.play.T.w / 2 - G.CARD_W * 1.27 / 2
--                 booster.T.y = G.play.T.y + G.play.T.h / 2 - G.CARD_H * 1.27 / 2
--                 booster.T.w = G.CARD_W * 1.27
--                 booster.T.h = G.CARD_H * 1.27
--                 booster.cost = 0
--                 booster.from_tag = true
--                 G.FUNCS.use_card({ config = { ref_table = booster } })
--                 booster:start_materialize()
--                 G.CONTROLLER.locks[lock] = nil
--                 return true
--             end)
--             tag.triggered = true
--             return true
--         end
--     end
-- }