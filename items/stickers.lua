SMODS.Atlas {
  key = 'stickers',
  path = 'Stickers.png',
  px = 71,
  py = 95
}

-- investment
SMODS.Sticker {
    key = "investment",
    badge_colour = HEX '459373',
    loc_txt = {
        label = 'Investment',
        name = 'Investment',
        text = {
                "Gain {C:money}$3{} at",
                "end of round"
             }
    },
    atlas = 'stickers',
    pos = { x = 0, y = 0 },
    discovered = true,

    -- should_apply = function(self, card, center, area, bypass_roll)
    --     return G.GAME.modifiers.enable_rentals_in_shop
    -- end,

    apply = function(self, card, val)
        card.ability[self.key] = val
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,

    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual then
            G.E_MANAGER:add_event(Event({
                ease_dollars(3)
            }))
            return {
                message = "+$3",
                colour = G.C.MONEY
            }
        end
    end
}

-- guardian
SMODS.Sticker {
    key = "guardian",
    badge_colour = HEX 'cc4846',
    loc_txt = {
        label = 'Guardian',
        name = 'Guardian',
        text = {
                "Can't be debuffed",
             }
    },
    atlas = 'stickers',
    pos = { x = 1, y = 0 },
    discovered = true,

    -- should_apply = function(self, card, center, area, bypass_roll)
    --     return G.GAME.modifiers.enable_rentals_in_shop
    -- end,

    apply = function(self, card, val)
        card.ability[self.key] = val
    end,

    loc_vars = function(self, info_queue, card)
        return { vars = {  } }
    end,

    calculate = function(self, card)
        if card.debuff then card:set_debuff(false) end
    end
}

-- SMODS.Sticker {
--     key = "negative",
--     badge_colour = HEX 'cc4846',
--     loc_txt = {
--         label = 'Negative',
--         name = 'Negative',
--         text = {
--                 "Can't be debuffed",
--              }
--     },
--     atlas = 'stickers',
--     pos = { x = 2, y = 0 },
--     discovered = true,

--     should_apply = function(self, card, center, area, bypass_roll)
--         return G.GAME.modifiers.enable_rentals_in_shop
--     end,

--     apply = function(self, card, val)
--         card.ability[self.key] = val
--     end,

--     loc_vars = function(self, info_queue, card)
--         return { vars = {  } }
--     end,

--     calculate = function(self, card)
--         if card.debuff then card:set_debuff(false) end
--     end
-- }