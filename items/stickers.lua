SMODS.Atlas {
  key = 'stickers',
  path = 'Stickers.png',
  px = 71,
  py = 95
}

SMODS.Sticker {
    key = "investment",
    badge_colour = HEX 'b18f43',
    loc_txt = {
        label = 'Investment',
        name = 'Investment',
        text = {
                "Gain {C:money}$3{} at",
                "end of the round"
             }
    },
    atlas = 'stickers',
    pos = { x = 0, y = 0 },
    discovered = true,

    should_apply = function(self, card, center, area, bypass_roll)
        return G.GAME.modifiers.enable_rentals_in_shop
    end,
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