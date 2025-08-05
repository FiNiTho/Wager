SMODS.Atlas {
    key = 'misc',
    path = 'misc.png',
    px = 71,
    py = 95
}
-- gamble seal/auburn seal
SMODS.Seal {
    key = 'auburnSeal',
    badge_colour = G.C.SET.gamble,
    loc_txt = {
        label = 'Auburn Seal',
        name = 'Auburn Seal',
        text = {
            "Creates a {C:gamble}Gamble{} card",
            "when played hand only",
            "contains this card",
            "{C:inactive}(Must have room){}"
        }
    },
    atlas = 'misc',
    unlocked = true,
    discovered = true,

    calculate = function(self, card, context)
        if context.before and #context.full_hand == 1 then
            if #G.consumeables.cards < G.consumeables.config.card_limit then
                card_eval_status_text(card, "extra", nil, nil, nil, {
                    message = "+1 Gamble card",
                    colour = G.C.SET.gamble
                })

                G.E_MANAGER:add_event(Event({
                    trigger = "after",
                    delay = 0.2,
                    func = function()
                        local new_card = create_card("Gamble", G.consumeables, nil, nil, true, true, nil)
                        G.consumeables:emplace(new_card)
                        return true
                    end
                }))
            end
        end
    end
}

